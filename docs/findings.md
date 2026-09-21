# Findings (lab write-up)

Use this file as the "I actually tested it" artifact.

## API-vulnerable

| ID | Class | Evidence | Fix in api-hardened |
|----|--------|----------|---------------------|
| F-01 | BOLA | `GET /orders/2` as user 1 returns another user's order | owner check vs `X-User-Id` |
| F-02 | SQLi | `q=' OR '1'='1` returns all rows | parameterized `LIKE` |
| F-03 | SSRF | `{"url":"http://127.0.0.1:8080/health"}` fetched by server | allowlist + block metadata/link-local |

## Cloud path (modeled)

SSRF → `169.254.169.254` → IAM creds for the instance/node role → actions allowed by that role.

Mitigations to cite in interviews:
- IMDSv2 required, hop limit 1 on nodes.
- No `s3:*` or `iam:*` on the node role.
- IRSA so the app role is not the node role.
- NetworkPolicy / egress deny to link-local (defense in depth).

## Falco (expected signals)

- Shell in container when you `kubectl exec` into the demo pod.
- `sudo`/`nsenter`/`--privileged` style exec.
- Open of `/var/run/docker.sock`.

Tune exceptions for real sidecars before production.
