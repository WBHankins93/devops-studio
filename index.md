---
layout: home

hero:
  name: DevOps Studio
  text: Cloud-native platform labs, built like real systems.
  tagline: A hands-on studio for Terraform foundations, Kubernetes platforms, CI/CD, observability, security automation, GitOps, serverless operations, and internal developer platforms.
  actions:
    - theme: brand
      text: Start with your scenario
      link: /docs/getting-started
    - theme: alt
      text: Browse Labs
      link: /labs/
    - theme: alt
      text: Choose a Learning Path
      link: /docs/learning-paths

features:
  - title: Choose by platform layer
    details: Move through infrastructure foundations, workload platforms, delivery pipelines, observability, security, GitOps, serverless operations, and developer experience.
    link: /labs/
  - title: Work from real constraints
    details: Each lab starts with a customer scenario, then names the architecture decisions, tradeoffs, validation steps, and operating model behind the implementation.
    link: /docs/architecture-decisions/001-terraform-structure
  - title: Validate what you build
    details: Setup, execution, testing, cleanup, cost controls, monitoring, and handoff guidance are part of the lab path, not follow-up chores.
    link: /docs/cost-management
  - title: Build a portfolio platform
    details: The eight labs compose into one cloud-native reference platform that shows practical DevOps, DevSecOps, and platform engineering depth.
    link: /docs/learning-paths
---

## Choose by the work in front of you

DevOps Studio is organized around the platform work practitioners actually need to do: establish infrastructure, run containers, ship software, observe systems, automate security, reconcile with GitOps, operate serverless workloads, and expose self-service paths.

The labs document implementation patterns, deployment strategies, operational tradeoffs, and production considerations that turn architecture into something a team can run.

## Every Lab Answers Four Questions

- Why would a customer need this?
- When should this be recommended?
- What tradeoffs exist?
- What happens in production?

That framing changes the work from tool configuration to Solutions Architecture: customer requirement, architecture decision, tradeoffs, implementation, validation, and operations.

## Customer Scenario First

A lab should not begin with "Today we'll learn EKS." It should begin with a customer scenario:

> A healthcare organization needs to deploy workloads into AWS while maintaining HIPAA requirements and minimizing operational overhead.

From there, the evaluation covers managed vs. self-managed platforms, IAM design, networking, GitOps, monitoring, disaster recovery, and operational handoff.

## How It All Connects

The eight labs are not isolated exercises. They compose into one implementation path: infrastructure foundation, workload platform, delivery pipeline, observability, security automation, GitOps, serverless operations, and internal platform enablement.

![How the eight labs connect into one platform](./assets/diagrams/overview-platform.png)

New here? Read the [Prerequisites](/docs/prerequisites) and [Getting Started](/docs/getting-started) guides first, then browse the [Labs](/labs/).
