# Labs

Eight customer-scenario labs that translate architecture decisions into production-ready implementation patterns. Each includes working code, a detailed walkthrough, validation steps, cost notes, and cleanup automation.

![DevOps Studio learning path map — how the eight labs build on each other](../assets/diagrams/00-curriculum-map.png)

> [DevOps Studio](../README.md) › Labs
>
> New here? Read the [Prerequisites](../docs/prerequisites.md) and [Getting Started](../docs/getting-started.md) guides first, then pick a [Learning Path](../docs/learning-paths.md).

**On this page:** [Foundation labs](#foundation-labs-start-here) · [Advanced labs](#advanced-labs) · [How labs are framed](#how-labs-are-framed) · [Suggested order](#suggested-order)

## Foundation labs (start here)

| Lab | Customer problem | Implementation details | Time | Difficulty |
|-----|-------|--------------|------|------------|
| [01 · Terraform Foundations](01-terraform-foundations/) | Establish a secure, repeatable AWS foundation for application workloads | Terraform, AWS VPC, ASG, RDS | 1-2 h | Beginner |
| [02 · Kubernetes Platform](02-kubernetes-platform/) | Provide a managed container platform while balancing cost, control, and operational burden | EKS, Helm, kubectl, Ingress | 2-3 h | Intermediate |
| [03 · CI/CD Pipelines](03-cicd-pipelines/) | Standardize software delivery from commit to deployment with auditable automation | GitHub Actions, GitLab CI, Jenkins | 1-2 h | Beginner |

## Advanced labs

| Lab | Customer problem | Implementation details | Time | Difficulty |
|-----|-------|--------------|------|------------|
| [04 · Observability Stack](04-observability-stack/) | Give operators enough telemetry to detect, investigate, and respond to production issues | Prometheus, Grafana, Jaeger, OpenSearch | 2-3 h | Advanced |
| [05 · Security Automation](05-security-automation/) | Enforce guardrails without slowing delivery teams or relying on manual review alone | Trivy, OPA, Falco, RBAC | 1-2 h | Advanced |
| [06 · GitOps Workflows](06-gitops-workflows/) | Make environment changes reviewable, repeatable, and recoverable through declarative delivery | Kustomize, Argo CD, Flux | 1-2 h | Intermediate |
| [07 · Serverless Operations](07-serverless-operations/) | Run event-driven workloads with clear ownership, monitoring, and failure handling | Lambda, API Gateway, Step Functions, DynamoDB | 1-2 h | Intermediate |
| [08 · Platform Engineering](08-platform-engineering/) | Turn repeatable infrastructure patterns into self-service capabilities for delivery teams | Service catalog, platform APIs, automation | 3-4 h | Expert |

## How labs are framed

The implementation details matter, but they are not the point. Each lab should make the architectural reasoning visible:

1. Customer requirement
2. Architecture decision
3. Tradeoffs
4. Implementation
5. Validation
6. Operations

Every lab should answer:

- Why would a customer need this?
- When should this be recommended?
- What tradeoffs exist?
- What happens in production?

## Suggested order

For the complete curriculum, work the labs in order: **01 → 02 → 03 → 04 → 05 → 06 → 07 → 08**. To target a specific role instead, follow a [Learning Path](../docs/learning-paths.md).

## How the labs connect

The map above shows the learning order; this one shows how the labs' systems fit together as a single platform.

![How the eight labs connect into one platform](../assets/diagrams/overview-platform.png)
