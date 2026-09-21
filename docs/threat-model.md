# Threat model

Assets: tenant order data, workload IAM role, cluster node identity, Terraform state (out of band).

## API classes (lab)

### BOLA
`GET /orders/{id}` returns any row if the handler only checks "is logged in" and not "does this order belong to this user."

Impact: cross-tenant read.

### SQLi
Search concatenates user input into SQL. Classic `' OR '1'='1` style bypass / dump.

Impact: confidentiality and integrity of the orders table.

### SSRF
`POST /fetch` takes a URL and the server retrieves it. If the destination can be `http://169.254.169.254/`, the process may read instance metadata.

## Cloud credential-exposure path

1. SSRF or compromised pod reaches link-local metadata.
2. IMDSv1 returns role name + temporary keys. IMDSv2 requires a PUT token first — still reachable if the app can issue arbitrary HTTP methods/headers.
3. Stolen keys are used as the node/pod role: S3 list/get, `sts:AssumeRole` if the policy is sloppy, or lateral IAM.
4. Blast radius is defined by the **identity policy ∩ permission boundary ∩ SCP**.

Controls in this repo:
- Isolated/private placement, no public nodes.
- Least-privilege role + permission boundary.
- IMDSv2 hop limit discussion in findings (enforce `http_tokens = required` on nodes).
- Falco: unexpected process, priv-esc args, docker.sock.
- Hardened API: ownership checks, parameterized SQL, URL allowlist + blocked link-local/RFC1918.

## Out of scope

Org SCPs, production IRSA mapping for every controller, full EKS add-on hardening. Noted as follow-ups.
