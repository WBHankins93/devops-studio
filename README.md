# DevOps Studio

[![Terraform](https://img.shields.io/badge/Terraform-1.9+-7B68EE?logo=terraform)](https://terraform.io)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.32+-326CE5?logo=kubernetes)](https://kubernetes.io)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A hands-on DevOps learning platform: eight self-contained labs that build real infrastructure, automation, and platform-engineering systems using production patterns — deployable on AWS, with setup, validation, cost notes, and cleanup for each.

**New here?** Read the [Prerequisites](./docs/prerequisites.md), then pick a [Learning Path](./docs/learning-paths.md) and start with [Lab 01](./labs/01-terraform-foundations/).

> **You'll need an AWS account.** Most labs deploy real AWS resources, so they cost money while running. Use a sandbox account, set a [budget alert](./docs/cost-management.md), and run `make destroy` when you're done — completing a lab and tearing it down is typically a few dollars. You can read the code and run `terraform validate` without an account, but deploying requires one.

> Full docs are also published as a browsable site (VitePress). See [Documentation site](#documentation-site) to run it locally.

**On this page:** [Labs](#labs) · [Quick start](#quick-start) · [Documentation](#documentation) · [Repository structure](#repository-structure) · [Docs site](#documentation-site) · [Contributing](#contributing)

## Labs

| Lab | Focus | Technologies | Time | Difficulty |
|-----|-------|--------------|------|------------|
| [01 · Terraform Foundations](./labs/01-terraform-foundations/) | Infrastructure as Code | Terraform, AWS VPC, ASG, RDS | 1–2 h | Beginner |
| [02 · Kubernetes Platform](./labs/02-kubernetes-platform/) | Container orchestration | EKS, Helm, kubectl, Ingress | 2–3 h | Intermediate |
| [03 · CI/CD Pipelines](./labs/03-cicd-pipelines/) | Automation & delivery | GitHub Actions, GitLab CI, Jenkins | 1–2 h | Beginner |
| [04 · Observability Stack](./labs/04-observability-stack/) | Monitoring & alerting | Prometheus, Grafana, Jaeger, OpenSearch | 2–3 h | Advanced |
| [05 · Security Automation](./labs/05-security-automation/) | DevSecOps | Trivy, OPA, Falco, RBAC | 1–2 h | Advanced |
| [06 · GitOps Workflows](./labs/06-gitops-workflows/) | GitOps & CD | Kustomize, Argo CD, Flux | 1–2 h | Intermediate |
| [07 · Serverless Operations](./labs/07-serverless-operations/) | Serverless ops | Lambda, API Gateway, Step Functions, DynamoDB | 1–2 h | Intermediate |
| [08 · Platform Engineering](./labs/08-platform-engineering/) | Internal platforms | Service catalog, platform APIs, automation | 3–4 h | Expert |

See [labs/](./labs/README.md) for the suggested order, or follow a role-based [Learning Path](./docs/learning-paths.md).

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

The labs compose into one platform — a Terraform foundation beneath everything, EKS at the center, CI/CD and GitOps deploying into it, observability and security around it, serverless alongside, and a self-service platform layer on top.

![How the eight labs connect into one platform](./assets/diagrams/overview-platform.png)

## Repository structure

```
devops-studio/
├── index.md             # Docs-site home (VitePress)
├── .vitepress/          # Docs-site config
├── labs/                # Eight hands-on labs (each: code, README, Makefile, scripts)
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
