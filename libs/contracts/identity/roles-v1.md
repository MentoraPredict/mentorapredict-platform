# Role catalogue — proposal for MPC-136

Status: the user accepted the proposed base codes for module A. Review with
modules B and C remains pending. These codes are not evidence of roles
configured in Keycloak or permissions granted by AWS.

| Context | Code | Role | Actor reference | Source status |
| --- | --- | --- | --- | --- |
| Institution | `ADM` | Institution administrator | ACT-02 | Appears in DOC-A-ARQ-04; scope clarified here. |
| Institution | `AUT` | Authority | ACT-03 | Proposed; accepted by user. |
| Institution | `SEC` | Secretary | ACT-04 | Proposed; accepted by user. |
| Institution | `INS` | Inspector | ACT-05 | Proposed; accepted by user. |
| Institution | `DOC` | Teacher | ACT-06, ACT-07 | Appears in DOC-A-ARQ-04. |
| Institution | `EST` | Student | ACT-08 | Appears in DOC-A-ARQ-04. |
| Institution | `REP` | Legal representative | ACT-09 | Appears in DOC-A-ARQ-04. |
| Institution | `DEC` | DECE counsellor | ACT-10 | Proposed; accepted by user. |
| Institution | `FIN` | Financial staff | ACT-11 | Proposed; accepted by user. |
| Institution | `CTE` | Technical education coordinator | ACT-25 | Accepted by user; the relevant module must be active. |
| Platform | `PLT_ADMIN` | Platform administrator | ACT-01 | Accepted by user; distinct from institution `ADM`. |
| Platform | `PLT_SUPPORT` | Support | ACT-13 | Proposed; accepted by user. |
| Platform | `PLT_REGULATORY` | Regulatory manager | ACT-20, ACT-21 | Accepted by user; review/approval are separate permissions. |

These are role identifiers, not the actor identifiers or a permission matrix.
Tutor is `DOC` plus a parallel-scoped assignment, not `TUT`. Commission
membership is also an assignment; there is no active auditor role.

## Custom roles

An institution-defined role is represented in `roles` as `CUSTOM:<uuid>`,
where the UUID is its stable identifier. The user chose this convention; it
does not represent an existing Keycloak configuration. Renaming a role does not
change its identifier. The display name and permissions are resolved separately
from the authorized role catalogue; they are not embedded in the token.

The authorization service must verify that the custom role is active and belongs
to the validated `tid`, then evaluate current permissions, scope, validity and
explicit denials. A `CUSTOM:` identifier is not valid by itself as a grant and
must not be used for platform roles. Revocation and propagation of role changes
still need implementation and tests; a stable identifier does not solve them.

Platform support access to personal data needs separate time-limited and
recorded authorization. Privileged roles cannot be granted solely from an
external identity provider's groups. Actual authorization must check the
applicable permission, scope, validity and any explicit denial.

Sources: [DOC-REQ-02](https://axel-alex.atlassian.net/wiki/spaces/DMPC/pages/8224784),
[DOC-ARQ-07](https://axel-alex.atlassian.net/wiki/spaces/DMPC/pages/9371730),
[DOC-A-ARQ-04](https://axel-alex.atlassian.net/wiki/spaces/DMPC/pages/9240754),
[DOC-GOB-02](https://axel-alex.atlassian.net/wiki/spaces/DMPC/pages/7634950).
