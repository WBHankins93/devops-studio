---
layout: home

hero:
  name: Why this exists
  text: DevOps Studio
  tagline: Great Solution Architects don't stop at diagrams. They understand what happens after the customer signs, when every architecture eventually becomes infrastructure and every decision eventually becomes code.
  actions:
    - theme: brand
      text: Start With the Scenario
      link: /docs/getting-started
    - theme: alt
      text: Browse Labs
      link: /labs/
    - theme: alt
      text: View Architecture Paths
      link: /docs/learning-paths

features:
  - title: What this demonstrates
    details: Translating customer requirements into infrastructure; designing production-ready deployment strategies; evaluating architectural tradeoffs; implementation planning; platform modernization; operational readiness; reliability engineering; and customer enablement.
    link: /docs/learning-paths
  - title: Customer requirement to architecture decision
    details: Each lab starts from a customer scenario, then walks through when the pattern should be recommended and what constraints shape the design.
    link: /labs/
  - title: Tradeoffs before implementation
    details: The focus is not the command sequence. It is the reasoning behind managed services, security boundaries, network design, delivery models, cost, resilience, and handoff.
    link: /docs/architecture-decisions/001-terraform-structure
  - title: Production-ready operations
    details: Validation, monitoring, disaster recovery, reliability, cost controls, and ownership are treated as part of the architecture instead of afterthoughts.
    link: /docs/cost-management
---

## This is not a DevOps course

It's a collection of implementation patterns I've used to bridge customer architecture into production-ready systems.

These labs document the implementation patterns, deployment strategies, operational tradeoffs, and production considerations that separate a successful design from a failed deployment.

They come directly from enterprise customer work spanning cloud migrations, hybrid environments, regulated industries, and production platform deployments.

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
