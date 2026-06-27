---
layout: home

hero:
  name: DevOps Studio
  text: Production-grade DevOps, hands-on.
  tagline: Eight self-contained labs that build real infrastructure, automation, and platform-engineering systems — the way they're run in production, not "hello world."
  actions:
    - theme: brand
      text: Start Here
      link: /docs/getting-started
    - theme: alt
      text: Browse Labs
      link: /labs/
    - theme: alt
      text: Choose a Learning Path
      link: /docs/learning-paths

features:
  - title: Cloud-Native DevOps Engineer
    details: Terraform → Kubernetes → CI/CD → Observability → GitOps. The modern cloud-native track.
    link: /docs/learning-paths
  - title: DevSecOps Engineer
    details: Secure infrastructure, automated scanning, policy-as-code, and security monitoring end to end.
    link: /docs/learning-paths
  - title: Platform Engineer
    details: Build internal developer platforms — service catalogs, self-service APIs, and golden paths.
    link: /docs/learning-paths
  - title: Infrastructure as Code
    details: Multi-environment Terraform with remote state (S3 + DynamoDB locking) and reusable modules.
    link: /labs/01-terraform-foundations/
  - title: Container Platforms
    details: Production EKS with Helm charts, ingress, and Kubernetes manifests.
    link: /labs/02-kubernetes-platform/
  - title: Platform Engineering
    details: Service catalog, platform APIs, and automation for an internal developer platform.
    link: /labs/08-platform-engineering/
---

## How it all connects

The eight labs aren't isolated exercises — they compose into one cloud-native platform: a Terraform foundation beneath everything, EKS at the center, CI/CD and GitOps delivering into it, observability and security wrapped around it, serverless alongside, and a self-service platform layer on top.

![How the eight labs connect into one platform](./assets/diagrams/overview-platform.png)

## What makes this different

Every lab here is **deployable, tested, and built on real production patterns** — not a toy. Each one is self-contained, with setup, execution, validation, and cleanup, plus the cost considerations to run it on a learning budget.

- **Actually works** — full IaC and code, runnable in real AWS environments
- **Production patterns** — enterprise architectures, not simplified demos
- **Progressive** — from foundations to advanced platform engineering
- **Cost-conscious** — right-sized resources with cleanup automation
- **Portfolio-ready** — demonstrates skills employers hire for

New here? Read the [Prerequisites](/docs/prerequisites) and [Getting Started](/docs/getting-started) guides first, then pick a [Learning Path](/docs/learning-paths).
