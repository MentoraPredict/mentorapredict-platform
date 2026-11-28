# Module C service module

Creates the per-service security resources for Module C:

- One KMS key and alias per service.
- One runtime database secret and one migration database secret per service, encrypted with the service key.
- Optional Secrets Manager rotation when the platform supplies a Lambda ARN.
- One IRSA role named `mentora-qa-<code>` bound to `system:serviceaccount:modulo-c:mentora-qa-<code>`.
- One least-privilege policy: own secrets, own KMS keys, Module C SSM paths, own Kafka topics and consumer group, and the content buckets when the service uses S3.
- SSM parameters for the role ARN, both secret ARNs, database name, topics, level, `replicas_min` and service account.

No static access key is created. The service account annotation comes from the role ARN, and the pod receives only short-lived credentials through IRSA.

`replicas_min` is derived from the service level: 3 for level 1 and 2 for level 2.
