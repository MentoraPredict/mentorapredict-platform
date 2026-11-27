# Shared ECR repositories (MPC-190)

This composition defines private ECR repositories. Names and permitted consumer accounts are inputs; do not commit AWS account IDs. It uses immutable tags, encryption, scan on push and optional cross-account pull policies. The current Learner Lab delivery uses a single account; cross-account access is outside MPC-190. Consumer identities still need their own IAM permissions, including registry authentication.

Replication is registry-wide, not per repository. It is disabled by default: enable it only after inspecting and adopting any existing registry replication configuration and confirming that this composition owns the whole configuration. The intended destination is `us-west-2`; configure the destination registry ID locally. Cross-account replication may require a destination registry policy.

In the lab, the `hello-world` repository was created and a test image was pushed using the current lab identity. Registry replication to `us-west-2` was configured, and the `lab-v2` test image was observed in the destination with the same digest as the source. This verifies the sample repository, not every future repository. A retention policy and cross-account access are outside the current delivery. No image lifecycle deletion policy is enabled. Learner Lab documents read-only ECR access for LabRole; permissions of other lab identities can differ.

Copy `backend.hcl.example` to ignored `backend.hcl` and `shared.tfvars.example` to ignored `shared.tfvars`; set values for the intended account locally. Initialize and review with `terraform init '-backend-config=backend.hcl'`, `terraform validate`, and `terraform plan '-var-file=shared.tfvars'`. Review account ownership, replication and permissions before applying.
