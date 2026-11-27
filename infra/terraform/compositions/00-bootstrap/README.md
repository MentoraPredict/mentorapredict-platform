# Terraform state bootstrap

This composition creates the S3 bucket and KMS key for one account and region.
It starts with local state and migrates its own state to S3 after the bucket exists.
The GitHub OIDC provider and the Terraform roles are not implemented: a role could not be created in the AWS Academy Learner Lab.

## Prerequisites

- Terraform 1.10 or newer in the 1.x series and AWS credentials for the intended account.
- An agreed globally unique bucket name, KMS alias, region and resource tags. Do not commit account IDs, credentials, real backend files, or state.
- IAM permissions to create and manage the resources, including the KMS key. Verify the account and region before applying.

### AWS Academy Learner Lab

The lab described by the user allows `us-east-1` and `us-west-2`. The project uses `us-east-1` as the primary region and `us-west-2` for recovery, so set `us-east-1` in both local configuration files. The architecture documents still name `sa-east-1` and must be updated. The lab retains resources between sessions, but a reset or budget exhaustion can remove them. Credentials expire and must be renewed. Check the remaining lab budget before creating resources, including the ongoing cost of a customer-managed KMS key. The lab lists KMS and S3 as available but does not guarantee every required operation: verify actual permissions. IAM role creation is restricted: a test role with a GitHub OIDC trust policy could not be created.

In the observed lab, an SCP denies `s3:GetBucketObjectLockConfiguration` during `aws_s3_bucket` management, even though bucket creation succeeded. Do not run this QA composition against the lab while this restriction remains. The alternative below creates the bucket outside Terraform. This is a lab adaptation, not a substitute for automated bootstrap in QA.

To create a new lab bucket, first create or identify an accessible KMS key in the same region, then run the following from this directory using the locally configured AWS credentials:

```powershell
.\bootstrap-learner-lab.ps1 -Bucket "unique-bucket-name" -KmsKeyId "alias/mp-staging-estado-iac" -Region us-east-1
```

Add `-AwsProfile profile-name` when using a named AWS profile. The script checks that the KMS key exists and is enabled, uses its ARN for the bucket encryption, stops without changes if the account already owns the bucket, and otherwise creates a new bucket and configures versioning, encryption, public-access blocking and a TLS-only policy. It stops at the first error; an error after bucket creation may leave it partially configured, which must be inspected before retrying. Check the lab budget before creating a KMS key. Verify the bucket settings and permissions before storing state. The script does not configure a Terraform backend or prove state locking.

After a lab reset, do not reuse or apply the previous bootstrap's local state. Use a different backend key for each real composition. The local state saved before the reset does not describe the resources in the new lab session.

## Bootstrap and migration

Run these commands from this directory. `bootstrap.tfvars` is a local, untracked file; use `bootstrap.tfvars.example` as a template.

1. Create the ignored file `backend_override.tf` with the content below (HCL does not accept these nested blocks on a single line), then run `terraform init`. This temporary override makes the first state local.

   ```hcl
   terraform {
     backend "local" {}
   }
   ```
2. Run `terraform fmt -check`, `terraform validate` and `terraform plan -var-file=bootstrap.tfvars`. Review the plan and apply it with `terraform apply -var-file=bootstrap.tfvars`.
3. Copy `backend.hcl.example` to a local `backend.hcl`. Fill in the bucket name and KMS alias created above. The key for this composition is `00-bootstrap/terraform.tfstate`.
4. Remove `backend_override.tf`, then run `terraform init -migrate-state -backend-config=backend.hcl` and confirm the migration. Verify the state is in S3 and that `terraform plan -var-file=bootstrap.tfvars` reports no unexpected changes. Securely remove any local state backup after confirming recovery is possible.
5. Configure a separate backend key such as `40-red/terraform.tfstate` for each other composition; use the bucket belonging to the target account and region.

The KMS key uses the AWS default key policy, which delegates authorization to IAM in the account. The bucket policy denies non-TLS requests; **access is not yet restricted to the Terraform role**. This is a known gap in the lab. An environment that allows custom roles must add least-privilege IAM and bucket/key policies, preserving the bootstrap operator's access during the transition and testing recovery before removing it.

For acceptance, test locking with two controlled concurrent operations against the same state and record the results without exposing state contents. Do not run a destructive test against shared infrastructure.
