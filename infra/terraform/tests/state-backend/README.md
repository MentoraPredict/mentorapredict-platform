# State backend test: migration and locking (MPC-188)

This test shows that a local state migrates to the S3 backend and that two concurrent operations cannot use the same state. It uses only `terraform_data`, which is built into Terraform, so it downloads no provider and creates no AWS resources besides the state objects in the existing bucket.

It tests the backend. It does **not** test the code in `compositions/00-bootstrap`.

The example S3 key keeps its previous `pruebas/backend-estado/` prefix so renaming this directory does not silently select a different state.

## Prerequisites

- Terraform 1.10 or newer in the 1.x series.
- Current AWS credentials (Learner Lab credentials expire).
- An existing state bucket and KMS key in `us-east-1`, with versioning, encryption and public access block verified.

## Steps

Run them from this directory in PowerShell.

### 1. Start with local state

```powershell
Set-Content -Encoding ascii backend_override.tf @'
terraform {
  backend "local" {}
}
'@
terraform init
terraform validate
terraform apply
```

### 2. Migrate to S3

Copy `backend.hcl.example` to the ignored `backend.hcl` and set the bucket name and KMS alias. Do not change the key to one used by a real composition.

```powershell
Remove-Item backend_override.tf
terraform init -migrate-state '-backend-config=backend.hcl'
terraform state list
terraform plan
```

Expected: `init` asks to copy the existing state (answer `yes`), `state list` shows `terraform_data.prueba` and `plan` reports no changes.

### 3. Test the lock

In terminal A, start a change and **leave it at the confirmation prompt**:

```powershell
terraform apply '-var=marca=prueba-bloqueo'
```

In terminal B, in the same directory:

```powershell
terraform plan
aws s3api list-objects-v2 --bucket YOUR-BUCKET --prefix pruebas/backend-estado/ --query 'Contents[].Key'
```

Expected: `plan` fails with `Error acquiring the state lock`, and the listing shows the state object and a `.tflock` object.

Answer `no` in terminal A, then run `terraform plan` again in terminal B. Expected: it now works.

### 4. Clean up

```powershell
terraform destroy
```

The state object and its versions remain in the bucket.

## Evidence

Record the date, the Terraform version, and the output of steps 2 and 3. Remove account IDs, ARNs, bucket names and the lock ID details that identify a person or machine. Never attach the state file. Local `terraform.tfstate*` files remain after the migration; delete them once you have confirmed the state is in S3.

If a step fails with `AccessDenied`, record the denied action. Do not report the criterion as met.
