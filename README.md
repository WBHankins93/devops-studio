# DevOps Studio

[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Great Solution Architects don't stop at diagrams.

They understand what happens after the customer signs: every architecture eventually becomes infrastructure, and every decision eventually becomes code.

**This is not a DevOps course.** It's a collection of implementation patterns I've used to bridge customer architecture into production-ready systems.

These labs document the implementation patterns, deployment strategies, operational tradeoffs, and production considerations that separate a successful design from a failed deployment. They come directly from enterprise customer work spanning cloud migrations, hybrid environments, regulated industries, and production platform deployments.

## What This Demonstrates

- Translating customer requirements into infrastructure
- Designing production-ready deployment strategies
- Evaluating architectural tradeoffs
- Implementation planning
- Platform modernization
- Operational readiness
- Reliability engineering
- Customer enablement

**New here?** Read the [Prerequisites](./docs/prerequisites.md), then pick a [Learning Path](./docs/learning-paths.md) and start with [Lab 01](./labs/01-terraform-foundations/).

> **You'll need an AWS account.** Most labs deploy real AWS resources, so they cost money while running. Use a sandbox account, set a [budget alert](./docs/cost-management.md), and run `make destroy` when you're done — completing a lab and tearing it down is typically a few dollars. You can read the code and run `terraform validate` without an account, but deploying requires one.

> Full docs are also published as a browsable site (VitePress). See [Documentation site](#documentation-site) to run it locally.

**On this page:** [Labs](#labs) · [How each lab is framed](#how-each-lab-is-framed) · [Quick start](#quick-start) · [Documentation](#documentation) · [Repository structure](#repository-structure) · [Docs site](#documentation-site) · [Contributing](#contributing)

## Labs

| Lab | Customer problem | Implementation details | Time | Difficulty |
|-----|-------|--------------|------|------------|
| [01 · Terraform Foundations](./labs/01-terraform-foundations/) | Establish a secure, repeatable AWS foundation for application workloads | Terraform, AWS VPC, ASG, RDS | 1-2 h | Beginner |
| [02 · Kubernetes Platform](./labs/02-kubernetes-platform/) | Provide a managed container platform while balancing cost, control, and operational burden | EKS, Helm, kubectl, Ingress | 2-3 h | Intermediate |
| [03 · CI/CD Pipelines](./labs/03-cicd-pipelines/) | Standardize software delivery from commit to deployment with auditable automation | GitHub Actions, GitLab CI, Jenkins | 1-2 h | Beginner |
| [04 · Observability Stack](./labs/04-observability-stack/) | Give operators enough telemetry to detect, investigate, and respond to production issues | Prometheus, Grafana, Jaeger, OpenSearch | 2-3 h | Advanced |
| [05 · Security Automation](./labs/05-security-automation/) | Enforce guardrails without slowing delivery teams or relying on manual review alone | Trivy, OPA, Falco, RBAC | 1-2 h | Advanced |
| [06 · GitOps Workflows](./labs/06-gitops-workflows/) | Make environment changes reviewable, repeatable, and recoverable through declarative delivery | Kustomize, Argo CD, Flux | 1-2 h | Intermediate |
| [07 · Serverless Operations](./labs/07-serverless-operations/) | Run event-driven workloads with clear ownership, monitoring, and failure handling | Lambda, API Gateway, Step Functions, DynamoDB | 1-2 h | Intermediate |
| [08 · Platform Engineering](./labs/08-platform-engineering/) | Turn repeatable infrastructure patterns into self-service capabilities for delivery teams | Service catalog, platform APIs, automation | 3-4 h | Expert |

See [labs/](./labs/README.md) for the suggested order, or follow a role-based [Learning Path](./docs/learning-paths.md).

## How Each Lab Is Framed

Each lab starts from a customer scenario, then moves through:

1. Customer requirement
2. Architecture decision
3. Tradeoffs
4. Implementation
5. Validation
6. Operations

Every lab should answer four questions:

- Why would a customer need this?
- When should this be recommended?
- What tradeoffs exist?
- What happens in production?

## Quick start

```bash
git clone https://github.com/WBHankins93/devops-studio.git
cd devops-studio

# Check tools and AWS access (see Prerequisites guide for the full list)
./tools/validate.sh

# Start a lab — each one is driven by its Makefile
cd labs/01-terraform-foundations
make init && make plan && make apply

# Always tear down when finished
make destroy
```

The [Getting Started guide](./docs/getting-started.md) walks through tool installation, AWS configuration, and an interactive setup (`./tools/setup.sh`). Costs are per-lab and small when you destroy promptly — see [Cost Management](./docs/cost-management.md).

## Documentation

| Guide | What it covers |
|-------|----------------|
| [Prerequisites](./docs/prerequisites.md) | Required tools, AWS account setup, IAM permissions, system requirements |
| [Getting Started](./docs/getting-started.md) | Step-by-step setup and your first lab |
| [Learning Paths](./docs/learning-paths.md) | Role-based sequences (Cloud-Native, DevSecOps, Platform, Cloud Architect) with skill progression |
| [Cost Management](./docs/cost-management.md) | Per-lab estimates, optimization, budget alerts |
| [Makefile Guide](./docs/makefile-guide.md) | The common `make` targets used across labs |
| [Observability Tools](./docs/observability-tools-explained.md) | Prometheus, Grafana, Jaeger, and OpenSearch explained |
| [Troubleshooting](./docs/troubleshooting.md) | Common setup and lab-specific issues |
| [Architecture Decisions](./docs/architecture-decisions/001-terraform-structure.md) | ADRs recording why key choices were made |

## How it all connects

The labs compose into one implementation path: infrastructure foundation, workload platform, delivery pipeline, observability, security automation, GitOps, serverless operations, and internal platform enablement.

![How the eight labs connect into one platform](./assets/diagrams/overview-platform.png)

## Repository structure

```
devops-studio/
├── index.md             # Docs-site home (VitePress)
├── .vitepress/          # Docs-site config
├── labs/                # Eight customer-scenario labs (each: code, README, Makefile, scripts)
├── docs/                # Guides + architecture-decisions/ (ADRs)
├── tools/               # bootstrap / setup / validate / cleanup / cost-estimate scripts
└── .github/workflows/   # CI: terraform validation, lab tests, security scan, docs build
```

## Documentation site

The guides and lab READMEs are published as a searchable site built with [VitePress](https://vitepress.dev). The build fails on any broken internal link, so it doubles as link-check CI.

```bash
npm install
npm run docs:dev      # local preview at /devops-studio/
npm run docs:build    # production build (also the link check)
```

## Contributing

Contributions are welcome — new labs, fixes, and documentation improvements. See [CONTRIBUTING.md](./CONTRIBUTING.md) for the process and lab guidelines. Report bugs or ask questions via [GitHub Issues](https://github.com/WBHankins93/devops-studio/issues) and [Discussions](https://github.com/WBHankins93/devops-studio/discussions).

## License

MIT — see [LICENSE](LICENSE).
