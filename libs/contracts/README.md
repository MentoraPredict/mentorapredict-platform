# Contracts

Single versioned place for the contracts between services and clients. A contract is written and reviewed **before** the code that implements it. This folder holds files, not Java code, so a service never depends on another service to know its contract (rule H4).

```text
libs/contracts/
├── openapi/<svc>.yaml        HTTP API of a service, OpenAPI 3.1 (DOC-ARQ-09 section 8)
└── avro/<topic>.avdl         events of a Kafka topic, Avro IDL (DOC-ARQ-05 section 3)
```

## HTTP API

Each service generates its server interfaces and DTOs **only from its own file**, at build time, with openapi-generator. The generated code lives in `build/generated` and is never edited or committed. `services/sample-service/build.gradle.kts` shows the setup, and its `MuestraController` implements the generated `MuestrasApi`.

To change the API, edit the YAML first and then build: if the interface changed, the code stops compiling until it follows the contract. The major version goes in the path (`/v1`); compatible changes do not change it.

The sample is simplified: it does not use UUID v7 identifiers or `ETag`/`If-Match`, which DOC-ARQ-09 requires for real resources.

## gRPC

**Decision (MPC-390):** the service template does not include an example `.proto` yet. The base `.proto` is created in MPC-134, part of the contract registry (MPC-98).

- **Why:** MPC-134 already covers that file. Adding an example now would duplicate the work and bring the Buf setup into this task.
- **What it does not change:** gRPC remains the main synchronous protocol inside a module and between a facade and its services, and it is never used between modules (DOC-ARQ-09 section 8.2, ADR-0028). This only postpones the file.
- **What MPC-134 follows:** DOC-ARQ-09 section 8.2: `proto/<svc>/v1/<svc>.proto` in this folder, package `mentora.<svc>.v1`, and Buf `lint` and `breaking` on every pull request. Until then, the sample service has no gRPC interface.

## Events

`avro/mp.smp.muestra.v1.avdl` is the example event. Topics are named `mp.<svc>.<aggregate>.v<N>`. The Java classes are not generated yet: that arrives with the outbox (MPC-116), which will also be the first compile check of the schema. The common event envelope belongs to MPC-133, and the compatibility checks in CI to MPC-135.
