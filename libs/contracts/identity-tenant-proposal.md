# Identity and institution contracts — working proposal

Status: working agreement for MPC-101. The three event payloads have Avro v1
schema files, but cross-module review, transport configuration and compatibility
checks remain pending. The shared event envelope belongs to MPC-98.

## Access token

The architecture assigns token issuance to Keycloak. Tokens use RS256 and a
five-minute access-token lifetime. Consumers validate the issuer, audience,
signature and expiration. The token must not contain a person's name, email or
national identification number, nor object-level permissions.

| Claim                             | Documented meaning                                                              |
| --------------------------------- | ------------------------------------------------------------------------------- |
| `iss`, `aud`, `exp`, `iat`, `jti` | Standard issuer, audience, expiration, issuance time and token identifier.      |
| `sub`                             | Opaque user identifier.                                                         |
| `sid`                             | Session identifier, for revocation.                                             |
| `tid`                             | The single active institution.                                                  |
| `org`                             | Organization or network, when applicable.                                       |
| `roles`                           | Role codes for the active institution; fine-grained scope is not included.      |
| `acr`, `amr`                      | Authentication level and methods, including MFA.                                |
| `azp`                             | Client that requested the token.                                                |
| `idp`                             | Authentication connector: `propio`, `activedirectory` or a provider identifier. |

Open decisions: exact data types and required/optional claims for each flow,
issuer and audience values per environment, token validation and revocation
behavior, and the representation of platform users without an active institution.
Do not interpret absence of an agreed rule as authorization.

### Proposed JWT field types and presence

These are proposals for access tokens, not verified Keycloak configuration.
Presence rules for platform-only and pre-institution-selection flows require
agreement before implementation. The audience may be a string or an array.

| Claim               | Proposed JSON type         | Proposed presence                                                               |
| ------------------- | -------------------------- | ------------------------------------------------------------------------------- |
| `iss`               | string                     | Required; configured trusted issuer.                                            |
| `aud`               | string or array of strings | Required; must contain the intended API audience.                               |
| `exp`, `iat`        | number                     | Required; NumericDate in seconds since the Unix epoch.                          |
| `jti`, `sub`, `sid` | string                     | Required; `sub` is opaque and `sid` identifies the session.                     |
| `tid`               | string                     | Required for an institution-scoped request; platform-only flows are unresolved. |
| `org`               | string                     | Optional; present when the organization/network context applies.                |
| `roles`             | array of strings           | Required for an institution-scoped request; empty does not grant access.        |
| `acr`               | string                     | Conditional when an authentication level is required.                           |
| `amr`               | array of strings           | Conditional when authentication methods are required.                           |
| `azp`, `idp`        | string                     | Proposed required; compatibility with each login flow must be confirmed.        |

The configured resource server must reject an invalid signature, issuer,
audience or expired token. `tid` must not be taken from an untrusted request
parameter in place of the validated token context. Session revocation and
gateway behavior require a separate implementation decision and test.

## Roles

The actor catalogue describes institution roles such as administrator,
authority, secretary, inspector, teacher, student, representative, DECE
counsellor and financial staff, as well as platform administrator, support and
regulatory management. A tutor is a teacher with an assignment; auditor is not
an active role. The catalogue also identifies a technical-education coordinator.

The exact machine-readable role codes, scopes, assignment rules and treatment of
custom roles still need agreement with the consuming modules. Actor identifiers
are not automatically role codes. Privileged roles require explicit assignment;
external group mapping alone must not grant them.

### Codes found in existing documentation

`ADM`, `DOC`, `EST` and `REP` appear in DOC-A-ARQ-04 as codes for
administrator, teacher, student and representative. Their exact token format
and scope still need agreement. The same source lists `TUT`, while DOC-REQ-02
describes a tutor as a teacher with an assignment. The decision is to use `DOC`
and a separate assignment for the relevant parallel, not an independent `TUT`
JWT role. The assignment is resolved by the authorized service, not included as
an object-level permission in the token. The source catalogue still needs to be
reconciled with this decision. Codes for the remaining
roles and for custom roles are not established by these references; do not
invent them here.

## Institution events

The following fields summarize DOC-A-ARQ-05 and the user's decisions.
All events are published by `tenant-service`, version 1, with at-least-once
delivery. Consumers must handle duplicates. The common envelope and its field
names remain dependent on MPC-98.

| Event                       | Documented payload summary                                                          | Partition key           | Documented consumers                         |
| --------------------------- | ----------------------------------------------------------------------------------- | ----------------------- | -------------------------------------------- |
| `EVT-TEN-InstitucionCreada` | Institution ID, AMIE, name, plan, contracted modules, data location and start date. | Institution ID          | IDN, PEO, ACA, CNV, AUL; n8n is also planned |
| `EVT-TEN-ModuloActivado`    | Institution ID, module, validity and parameters.                                    | Institution ID + module | IDN, ENR, WEL, RSK, BIL, CNV                 |
| `EVT-TEN-ModuloDesactivado` | Institution ID, module, time and data policy.                                       | Institution ID + module | IDN, RSK, BIL, CNV                           |

The payload field names, types and nullability are defined in the Avro files
below. Open decisions include allowed identifier and plan/module values, topic
names, composite-key encoding and compatibility policy.
The same events document describes `InstitucionCreada` differently for the n8n
flow (AMIE, name, plan and timestamp). The decision is to include AMIE and name
in the shared event, protect access to authorized consumers and reconcile the
source document. Confirm consumer lists with modules B and C. The documented
activation/deactivation topics are compacted by key.

### Payload schemas for review

- [`tenant-institution-created-v1.avsc`](avro/tenant-institution-created-v1.avsc)
- [`tenant-module-activated-v1.avsc`](avro/tenant-module-activated-v1.avsc)
- [`tenant-module-deactivated-v1.avsc`](avro/tenant-module-deactivated-v1.avsc)

The following proposed names use `camelCase` in `data` to match the event
catalogue; the common envelope already contains `tenantid`. If the payload also
contains `tenantId`, producer and consumer must verify that both values match.
Tenant IDs use Avro's UUID logical type, dates use its `date` logical type and
timestamps use `timestamp-millis` (UTC). All schema fields are required. An
empty list or map is valid; it is not equivalent to an absent field. Avro alone
does not validate non-empty strings, AMIE syntax or authorization.

| Event               | Field                | Proposed type         | Proposed presence                                                            |
| ------------------- | -------------------- | --------------------- | ---------------------------------------------------------------------------- |
| `InstitucionCreada` | `tenantId`           | UUID string           | Required.                                                                    |
| `InstitucionCreada` | `plan`               | string                | Required.                                                                    |
| `InstitucionCreada` | `modulosContratados` | array of strings      | Required; may be empty if no modules are contracted.                         |
| `InstitucionCreada` | `ubicacionDatos`     | string                | Required; allowed values to be agreed.                                       |
| `InstitucionCreada` | `fechaInicio`        | Avro date             | Required; institution start date.                                            |
| `InstitucionCreada` | `amie`, `nombre`     | string                | Required in the proposed shared event; validation rules remain to be agreed. |
| `ModuloActivado`    | `tenantId`, `modulo` | UUID string, string   | Required.                                                                    |
| `ModuloActivado`    | `fechaInicio`        | Avro date             | Required; the user selected a start date only.                               |
| `ModuloActivado`    | `parametros`         | map of strings        | Required; may be empty and must not contain secrets or sensitive data.       |
| `ModuloDesactivado` | `tenantId`, `modulo` | UUID string, string   | Required.                                                                    |
| `ModuloDesactivado` | `instante`           | Avro timestamp-millis | Required, UTC.                                                               |
| `ModuloDesactivado` | `politicaDatos`      | enum                  | Required: `CONSERVAR` or `ARCHIVAR`.                                         |

The common envelope is specified as CloudEvents 1.0 in DOC-ARQ-05, including
`id`, `type`, `source`, `time`, `tenantid`, `subject` and other metadata. Its
implementation belongs to MPC-98; no duplicate envelope schema is introduced
here. The inclusion of AMIE and institution name is recorded as a user decision;
it has not yet been reconciled in the source documentation.
