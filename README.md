# secure-cloud-runtime-lab

Portfolio lab: secure multi-tier AWS + EKS as code, Checkov in CI, Falco/eBPF runtime detection, and documented OWASP API paths that become cloud credential exposure.

**Do not deploy the vulnerable API to a public network.** It exists to teach detection and fixes.

## What this repo demonstrates

- Terraform VPC with public / private / isolated subnets, least-privilege IAM, permission boundaries, GitHub OIDC (no long-lived keys).

- Checkov gates on PRs (`CKV_AWS_1`, `CKV_AWS_49`, `CKV_AWS_110`, open SGs, unencrypted volumes).

- Falco custom rules for anomalous `execve`, privilege escalation patterns, and runtime socket abuse.

- REST API lab: BOLA, SQLi, SSRF → instance-metadata / IAM credential path, plus a hardened twin.

## Layout

```
***## Run without AWS**


***```bash**

***make local          # both APIs on 127.0.0.1**

***make attacks        # vulnerable behavior**

***make attacks-hard   # fixed behavior**

***make checkov        # scans Terraform, no cloud account**

***make kind-up        # optional local cluster**
```

