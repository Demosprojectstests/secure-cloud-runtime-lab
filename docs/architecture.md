# Architecture

## Network tiers

| Tier     | Purpose                         | Internet                  |
|----------|---------------------------------|---------------------------|
| Public   | ALB, NAT only                   | IGW in, NAT out           |
| Private  | EKS nodes, app workloads        | Egress via NAT            |
| Isolated | Data stores (RDS placeholder)   | No IGW, no NAT            |

VPC endpoints for S3 reduce NAT hairpin and keep data-plane AWS API calls private.

## Identity

- GitHub Actions assumes an IAM role via OIDC. No access keys in CI.
- Permission boundary caps every workload and pipeline role.
- App roles are resource-scoped. No `Action = "*"` and no `Resource = "*"` on identity policies.

## Runtime

- EKS node groups land in private subnets.
- Falco DaemonSet uses the eBPF probe and custom rules in `k8s/falco/`.
- Demo API can be scheduled with non-privileged securityContext.

## Data flow (happy path)

User → ALB (public) → Service (private) → data in isolated subnet.
