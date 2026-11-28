param(
    [ValidateSet("plan", "apply", "destroy")]
    [string]$Action = "plan",

    [string]$BackendConfig = "backend.hcl",

    [string]$VarFile = "qa.tfvars",

    [string]$OutputDirectory = "artifacts"
)

$ErrorActionPreference = "Stop"

$terraform = Get-Command terraform -ErrorAction SilentlyContinue
if (-not $terraform) {
    throw "terraform is not on PATH"
}

$root = Split-Path -Parent $PSScriptRoot
$outputRoot = Join-Path $root $OutputDirectory
$stages = @(
    "80-modulo-c",
    "81-modulo-c-databases",
    "82-modulo-c-topics"
)

New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null

foreach ($stage in $stages) {
    $directory = Join-Path $root "compositions/$stage"
    $backendPath = Join-Path $directory $BackendConfig
    $varPath = Join-Path $directory $VarFile

    if (-not (Test-Path $backendPath)) {
        throw "Missing $backendPath. Copy backend.hcl.example and fill it."
    }

    if (-not (Test-Path $varPath)) {
        throw "Missing $varPath. Copy qa.tfvars.example and fill it."
    }

    Write-Host "==> $stage ($Action)"

    Push-Location $directory
    try {
        & $terraform.Source init "-backend-config=$BackendConfig" -input=false
        if ($LASTEXITCODE -ne 0) {
            throw "terraform init failed for $stage"
        }

        switch ($Action) {
            "plan" {
                $planPath = Join-Path $outputRoot "$stage.tfplan"
                & $terraform.Source plan "-var-file=$VarFile" -input=false "-out=$planPath"
            }
            "apply" {
                & $terraform.Source apply "-var-file=$VarFile" -input=false -auto-approve
                if ($LASTEXITCODE -eq 0) {
                    & $terraform.Source output -json |
                        Set-Content -Path (Join-Path $outputRoot "$stage-outputs.json") -Encoding utf8
                }
            }
            "destroy" {
                & $terraform.Source destroy "-var-file=$VarFile" -input=false -auto-approve
            }
        }

        if ($LASTEXITCODE -ne 0) {
            throw "terraform $Action failed for $stage"
        }
    }
    finally {
        Pop-Location
    }
}

Write-Host "Artifacts: $outputRoot"
