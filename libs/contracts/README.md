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

`avro/mp.smp.muestra.v1.avdl` is the example event. Topics are named `mp.<svc>.<aggregate>.v<N>`. The template does not generate Java classes from it, so the schema has not been compiled yet. The common event envelope belongs to MPC-133, and the compatibility checks in CI to MPC-135.

## Identity and institution contracts (MPC-101)

The following files are available in this repository for review. They are not
yet an approved cross-module contract or a deployed schema registry:

- [Identity and institution contract notes](identity-tenant-proposal.md):
  claims, events, decisions and outstanding questions.
- [Access token claims schema v1](identity/access-token-v1.schema.json): JSON
  Schema for the shape of decoded JWT claims; it does not verify a JWT or grant access.
- [Role catalogue v1](identity/roles-v1.md): base roles and custom-role identifiers.
- [Institution created v1](avro/tenant-institution-created-v1.avsc),
  [module activated v1](avro/tenant-module-activated-v1.avsc), and
  [module deactivated v1](avro/tenant-module-deactivated-v1.avsc): Avro schemas
  for event payloads, without the common envelope.

MPC-138 tracks review with modules B and C. Topic names and partition-key
encoding remain to be agreed. The common event envelope and automated
compatibility checks remain in MPC-133 and MPC-135. The `v1` file names identify
the proposed major version; they do not mean compatibility checks are active.
