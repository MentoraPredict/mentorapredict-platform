# Administrative access (work in progress)

This composition prepares one private EC2 bastion per supplied management subnet. It has no inbound rules or public IP and permits outbound HTTPS for Systems Manager via the existing NAT. Use an AMI with the SSM agent and an existing instance profile authorized for Systems Manager. Obtain VPC and management subnet IDs from the network composition; supply one subnet per zone. Configure a separate S3 backend key for this composition.

The Learner Lab deployment was validated with one Session Manager session per instance. Subnet VPC and zone are checked during planning; select management subnets and an AMI with SSM Agent. The lab uses an existing instance profile and may limit IAM configuration. Least-privilege permissions, MFA, Session Manager logging and denial of unauthorized sessions remain to be implemented and verified in MPC-536. EKS connectivity is deferred until MPC-158.
