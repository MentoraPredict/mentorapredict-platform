# Module C QA data layer

This composition adds the resources that belong to Module C on top of the Module A QA infrastructure. It never creates or modifies Module A resources: the VPC, subnets, EKS cluster, OIDC provider, MSK cluster, ECR registry and Helm chart stay owned by Module A.

## What it creates

- One shared RDS PostgreSQL 16 instance for QA with a separate database per Module C service. Production uses one instance per service; QA keeps one instance to control cost.
- One ElastiCache Valkey replication group for the services that use the cache (AUL and CNT).
- One KMS key for the shared data resources and one KMS key per service.
- One Secrets Manager secret for the runtime database role and one for the migration role of each service, plus one secret for the Valkey auth token.
- One IRSA role and least-privilege IAM policy per service, bound to `system:serviceaccount:modulo-c:mentora-qa-<code>`.
- SSM Parameter Store entries for the PostgreSQL, Valkey and Kafka endpoints, and for each service role, secret, database, topic list, level and `replicas_min`.
- The Module C Kafka topic catalogue. Topics are created by the `82-modulo-c-topics` composition.

The service catalogue lives in `../../modules/modulo-c-catalog` and is the single source of truth for names, levels, databases, topics and cache usage.

## Prerequisites

The composition consumes outputs from Module A. Fill `qa.tfvars` with:

| Input | Module A source |
| --- | --- |
| `vpc_id` | Network composition output `vpc_id` |
| `data_subnet_ids` | Network composition output `subnet_ids_by_tier["datos"]` |
| `client_security_group_ids` | EKS node security group |
| `oidc_provider_arn` | EKS OIDC provider ARN |
| `oidc_issuer` | EKS OIDC issuer without `https://` |
| `kafka_bootstrap_brokers` | MSK IAM bootstrap brokers on port 9098 |
| `kafka_cluster_arn` | MSK cluster ARN |
| `content_bucket_arns` | S3 buckets used by CNT, ASG, ANL and RPT |
| `content_kms_key_arns` | KMS keys used by those buckets |

`account_id` is required so IAM policies can be built without calling STS during plan.

The MSK cluster and the Helm chart are delivered by Module A tasks MPC-161 and MPC-160. Until those outputs exist, leave `kafka_bootstrap_brokers` and `kafka_cluster_arn` empty: the composition plans and applies the data layer, but it does not create topics or Kafka IAM statements.

## Apply order

Run the layers in this order:

1. `80-modulo-c`: KMS keys, RDS, Valkey, secrets, IRSA roles, SSM parameters.
2. `81-modulo-c-databases`: databases, runtime roles, migration roles, grants and the `pgcrypto` extension.
3. `82-modulo-c-topics`: Module C topics on the Module A MSK cluster.
4. Helm values: deploy the services with the Module A chart and the files in `infra/helm/modulo-c/values`.

Layer 81 must run where it can reach the private RDS endpoint (a CI runner inside the VPC, a bastion with Session Manager port forwarding, or a Kubernetes job). Layer 82 needs an IAM principal with `kafka-cluster:*` on the Module A cluster; the provider assumes the role in `kafka_admin_role_arn` or uses the runner credentials.

```bash
terraform -chdir=infra/terraform/compositions/80-modulo-c init -backend-config=backend.hcl
terraform -chdir=infra/terraform/compositions/80-modulo-c plan -var-file=qa.tfvars -out=80-modulo-c.tfplan
terraform -chdir=infra/terraform/compositions/80-modulo-c apply 80-modulo-c.tfplan

terraform -chdir=infra/terraform/compositions/81-modulo-c-databases init -backend-config=backend.hcl
terraform -chdir=infra/terraform/compositions/81-modulo-c-databases plan -var-file=qa.tfvars -out=81-modulo-c-databases.tfplan
terraform -chdir=infra/terraform/compositions/81-modulo-c-databases apply 81-modulo-c-databases.tfplan

terraform -chdir=infra/terraform/compositions/82-modulo-c-topics init -backend-config=backend.hcl
terraform -chdir=infra/terraform/compositions/82-modulo-c-topics plan -var-file=qa.tfvars -out=82-modulo-c-topics.tfplan
terraform -chdir=infra/terraform/compositions/82-modulo-c-topics apply 82-modulo-c-topics.tfplan
```

The PowerShell helper runs the three layers in order and writes each `terraform output -json` to `infra/terraform/artifacts/`:

```powershell
pwsh infra/terraform/scripts/apply-modulo-c.ps1 -Action plan
pwsh infra/terraform/scripts/apply-modulo-c.ps1 -Action apply
```

Outputs are also stored in the S3 state of each layer. The SSM parameters are the runtime contract for the services and Argo CD.

## Validation without AWS credentials

The tests use mocked providers, so they do not need an AWS account:

```bash
terraform -chdir=infra/terraform/modules/modulo-c-catalog test
terraform -chdir=infra/terraform/modules/modulo-c-data test
terraform -chdir=infra/terraform/modules/modulo-c-service test
terraform -chdir=infra/terraform/modules/modulo-c-databases test
terraform -chdir=infra/terraform/modules/modulo-c-topics test
terraform -chdir=infra/terraform/compositions/80-modulo-c test
```

`terraform validate` must also pass in every module and composition.

## Security model

- No password is written in Terraform, in a variable or in the repository. The RDS master password is managed by RDS (`manage_master_user_password`), and every service password is generated by `random_password` and stored in Secrets Manager encrypted with the service KMS key.
- Pods do not receive static AWS keys. Each pod assumes its IRSA role, reads only its own secrets and parameters, decrypts only its own keys, and reads or writes only its own Kafka topics and consumer group.
- The runtime database role does not own its database. Migrations run with the owner role, and the runtime role receives `SELECT`, `INSERT`, `UPDATE` and `DELETE` through default privileges. Migrations enable row-level security on tables with minors' data; because the migration role owns those tables, it keeps full access without the `BYPASSRLS` attribute, which the RDS master user cannot grant. Do not use `FORCE ROW LEVEL SECURITY` unless the owner must also be constrained; see `DOC-C-ARQ-10`.
- PostgreSQL requires TLS (`rds.force_ssl = 1`), Valkey uses in-transit and at-rest encryption, and Kafka uses TLS with IAM authentication.
- Secret rotation is enabled when the platform supplies a rotation Lambda in `rotation_lambda_arn`. The Lambda must rotate both the runtime and migration secrets.

## Tags

The shared tags module adds `modulo`, `servicio` and `entorno` to every resource. Shared data resources use `servicio = "compartido"`; each service resource uses its three-letter code. Per-service resources also carry the code through the `servicio` tag.

## Monthly additional cost in QA

List prices for `us-east-1`, on demand, rounded. Module A costs (EKS, MSK, NAT, ECR) are excluded because this composition does not create them.

| Item | Configuration | USD/month |
| --- | --- | ---: |
| RDS PostgreSQL `db.t4g.medium` | 1 instance, single-AZ, 730 h at 0.068 USD/h | 49.64 |
| RDS gp3 storage | 100 GiB at 0.115 USD/GiB-month | 11.50 |
| RDS backups | 7 days, within the free backup allowance | 0.00 |
| ElastiCache Valkey `cache.t4g.micro` | 1 node, 730 h at 0.016 USD/h | 11.68 |
| KMS | 11 customer-managed keys at 1 USD/key-month | 11.00 |
| KMS requests | Small QA volume | 1.00 |
| Secrets Manager | 21 secrets at 0.40 USD/secret-month | 8.40 |
| Secrets Manager requests | Small QA volume | 1.00 |
| CloudWatch Logs | PostgreSQL logs, about 2 GiB | 1.00 |
| SSM Parameter Store | Standard parameters | 0.00 |
| MSK topics | No additional broker capacity | 0.00 |
| **Estimated total** | | **95.22** |
| **Budget with 10 % buffer** | | **105.00** |

Multi-AZ RDS roughly doubles the RDS line to about 123 USD/month. Two Valkey nodes add about 12 USD/month. A production layout with one RDS instance per service starts at about 650 USD/month before EKS and MSK.

## Limitations

- Module A does not yet expose the EKS OIDC provider, MSK cluster or Helm chart in this repository. The inputs are explicit so the layer can be applied as soon as MPC-158, MPC-160 and MPC-161 land.
- The database layer cannot run from a laptop outside the VPC. Use a runner inside the VPC or a Session Manager port-forward.
- Topics are created only when the MSK IAM bootstrap brokers and cluster ARN are supplied.
- Row-level security policies are applied by the service migrations, not by Terraform. Terraform creates the roles, grants and default privileges that make those policies effective.
