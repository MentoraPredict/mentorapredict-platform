# Module C Kafka topics

This composition creates the eleven Module C topics on the Module A MSK cluster. It does not create brokers, storage or the cluster.

The topic catalogue is defined once in `../../modules/modulo-c-catalog`:

| Topic | Partitions | Replication | Retention | Cleanup |
| --- | ---: | ---: | ---: | --- |
| `mp.aul.aula.v1` | 6 | 3 | 90 days | delete |
| `mp.aul.contenido.v1` | 6 | 3 | 30 days | delete |
| `mp.aul.tarea.v1` | 6 | 3 | 30 days | delete |
| `mp.aul.entrega.v1` | 6 | 3 | 365 days | delete |
| `mp.aul.cuestionario.v1` | 6 | 3 | 30 days | delete |
| `mp.aul.intento.v1` | 6 | 3 | 30 days | delete |
| `mp.aul.anuncio.v1` | 6 | 3 | 30 days | delete |
| `mp.aul.actividad.v1` | 6 | 3 | 7 days | delete |
| `mp.grd.libreta-datos.v1` | 6 | 3 | 365 days | delete |
| `mp.rsk.riesgo-conductual.v1` | 6 | 3 | 90 days | delete |
| `mp.rsk.alerta-conductual.v1` | 6 | 3 | 90 days | delete |

Every topic sets `min.insync.replicas = 2`, matching `DOC-C-ARQ-05`.

## Apply

Use the MSK IAM bootstrap brokers (port 9098) and a principal with `kafka-cluster:*` on the cluster.

```bash
cp backend.hcl.example backend.hcl
cp qa.tfvars.example qa.tfvars
terraform init -backend-config=backend.hcl
terraform plan -var-file=qa.tfvars -out=82-modulo-c-topics.tfplan
terraform apply 82-modulo-c-topics.tfplan
```

The provider uses `sasl_mechanism = "aws-iam"` and the standard AWS credential chain. Set `kafka_admin_role_arn` to assume a dedicated role; leave it empty to use the runner credentials. No static Kafka password is stored.
