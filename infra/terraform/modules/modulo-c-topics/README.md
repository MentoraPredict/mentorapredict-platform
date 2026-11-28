# Module C topics module

Creates Kafka topics from the Module C catalogue. Every topic uses the documented partition count, replication factor, retention and `min.insync.replicas = 2`.

The provider is configured in the `82-modulo-c-topics` composition with TLS and MSK IAM authentication. The module does not create the MSK cluster.
