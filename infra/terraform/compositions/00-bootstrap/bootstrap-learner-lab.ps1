param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$')]
    [string]$Bucket,

    [Parameter(Mandatory = $true)]
    [string]$KmsKeyId,

    [ValidateSet('us-east-1', 'us-west-2')]
    [string]$Region = 'us-east-1',

    [string]$AwsProfile
)

$ErrorActionPreference = 'Stop'
$awsOptions = @('--region', $Region, '--no-cli-pager')
if ($AwsProfile) { $awsOptions += @('--profile', $AwsProfile) }

function Invoke-Aws {
    param([string[]]$Arguments)
    & aws @Arguments @awsOptions
    if ($LASTEXITCODE -ne 0) { throw 'AWS CLI failed. Stop and review the error before retrying.' }
}

Write-Host 'Checking the active AWS identity...'
Invoke-Aws @('sts', 'get-caller-identity', '--query', 'Arn', '--output', 'text')

Write-Host 'Checking that the KMS key exists and is enabled...'
$keyJson = & aws kms describe-key --key-id $KmsKeyId --query 'KeyMetadata.{Arn:Arn,State:KeyState}' --output json @awsOptions
if ($LASTEXITCODE -ne 0) { throw 'Cannot access the KMS key. No bucket was created.' }
$key = $keyJson | Out-String | ConvertFrom-Json
if ($key.State -ne 'Enabled') { throw 'The KMS key is not enabled. No bucket was created.' }
# Use the ARN from here on: S3 resolves an alias in the account of the caller that writes the object.
$kmsKeyArn = $key.Arn
if ($kmsKeyArn -notmatch '^arn:[^:]+:kms:[^:]+:\d{12}:key/.+$') { throw 'AWS did not return a KMS key ARN. No bucket was created.' }

Write-Host 'Checking that this account does not already own the bucket...'
$bucketList = & aws s3api list-buckets --query 'Buckets[].Name' --output json @awsOptions
if ($LASTEXITCODE -ne 0) { throw 'Cannot check existing buckets. No changes were made.' }
# Windows PowerShell 5.1 emits a JSON array as a single pipeline object, so parse first and wrap afterwards.
$ownedBuckets = $bucketList | Out-String | ConvertFrom-Json
if (@($ownedBuckets) -contains $Bucket) { throw 'This account already owns that bucket. No changes were made.' }

Write-Host 'Creating a new bucket. Existing buckets are not modified by this script.'
$createArgs = @('s3api', 'create-bucket', '--bucket', $Bucket)
if ($Region -ne 'us-east-1') {
    $createArgs += @('--create-bucket-configuration', "LocationConstraint=$Region")
}
Invoke-Aws $createArgs

Write-Host 'Enabling versioning and blocking public access...'
Invoke-Aws @('s3api', 'put-bucket-versioning', '--bucket', $Bucket, '--versioning-configuration', 'Status=Enabled')
Invoke-Aws @('s3api', 'put-public-access-block', '--bucket', $Bucket, '--public-access-block-configuration', 'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true')

$encryption = @{ Rules = @(@{ ApplyServerSideEncryptionByDefault = @{ SSEAlgorithm = 'aws:kms'; KMSMasterKeyID = $kmsKeyArn }; BucketKeyEnabled = $true }) } | ConvertTo-Json -Compress -Depth 5
$policy = @{ Version = '2012-10-17'; Statement = @(@{ Sid = 'DenyInsecureTransport'; Effect = 'Deny'; Principal = '*'; Action = 's3:*'; Resource = @("arn:aws:s3:::$Bucket", "arn:aws:s3:::${Bucket}/*"); Condition = @{ Bool = @{ 'aws:SecureTransport' = 'false' } } }) } | ConvertTo-Json -Compress -Depth 7
$encryptionFile = Join-Path $env:TEMP ("mentora-encryption-" + [guid]::NewGuid().ToString() + '.json')
$policyFile = Join-Path $env:TEMP ("mentora-policy-" + [guid]::NewGuid().ToString() + '.json')
try {
    [System.IO.File]::WriteAllText($encryptionFile, $encryption, [System.Text.UTF8Encoding]::new($false))
    [System.IO.File]::WriteAllText($policyFile, $policy, [System.Text.UTF8Encoding]::new($false))
    Write-Host 'Configuring KMS encryption and denying insecure transport...'
    Invoke-Aws @('s3api', 'put-bucket-encryption', '--bucket', $Bucket, '--server-side-encryption-configuration', "file://$encryptionFile")
    Invoke-Aws @('s3api', 'put-bucket-policy', '--bucket', $Bucket, '--policy', "file://$policyFile")
} finally {
    Remove-Item -LiteralPath $encryptionFile, $policyFile -ErrorAction SilentlyContinue
}

Write-Host 'Bucket created. Verify versioning, encryption, public access block and policy before using it.'
Write-Host 'The Terraform backend and concurrent state locking still need to be tested.'
