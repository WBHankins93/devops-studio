# DevOps Studio — Showcase Image Prompts

Detailed, paste-ready prompts for generating the lab architecture images in an
image model (e.g. ChatGPT / GPT Image). Each prompt is self-contained — the
shared style block is already baked into every one, so you can copy a single
prompt straight into the tool.

## How to use

1. Open ChatGPT (or your image tool) and paste one **FULL PROMPT** block below.
2. Generate at the recommended size (landscape `1536×1024` unless the image notes portrait).
3. Save the result to `assets/diagrams/<filename>.png` (filenames are given per image).
4. Embed it in the target file, replacing that lab's ASCII `## Architecture` block:
   ```markdown
   ![<alt text>](../../assets/diagrams/<filename>.png)
   ```
5. After generating, **self-review against the EXACT LABEL LIST** — every label
   must appear, spelled exactly, with no invented boxes or arrows. Regenerate if not.

> Style and palette follow the same standard as the
> [solutions-playbook](https://github.com/WBHankins93/solutions-playbook) showcase
> diagrams: flat vector infographic, white background, navy ink, teal active path,
> status colors used deliberately.

## Shared style block (already included in every prompt)

> Create a clean, modern technical system-architecture diagram in flat vector
> infographic style. White background, generous whitespace, precise alignment, airy
> spacing. Render each system as a soft rounded rectangle with a thin border and a
> very light tint fill; group related systems inside labeled boundary containers;
> connect them with thin arrows carrying short labels where direction is meaningful.
> Flat line icons only — no photorealism, no 3D, no gradients, no drop shadows, no
> decorative noise. Clean sans-serif type, short bold labels, high contrast, fully
> legible. Color palette: ink/text deep navy `#0f1923`; primary/active path teal
> `#0f766e`; success green `#1a6b35`; warning amber `#b8860b`; failure red `#8b1a1a`;
> control/platform layer purple `#6b21a8`; fills are light tints of these only.
> CRITICAL: render every text label EXACTLY as written, correct spelling, no added
> words, no invented boxes, no extra arrows.

---

## 00 — Curriculum dependency map

- **File:** `assets/diagrams/00-curriculum-map.png`
- **Embed in:** `labs/README.md` (top) and optionally `index.md`
- **Size:** landscape `1536×1024`
- **One job:** show how the eight labs relate and build on one another.

**FULL PROMPT**

> Create a clean, modern technical system-architecture diagram in flat vector infographic style. White background, generous whitespace, precise alignment, airy spacing. Render each item as a soft rounded rectangle with a thin border and a very light tint fill; connect with thin arrows where direction is meaningful. Flat line icons only — no photorealism, no 3D, no gradients, no drop shadows. Clean sans-serif type, short bold labels, high contrast, fully legible. Palette: ink/text deep navy `#0f1923`; primary path teal `#0f766e`; soft tints only. CRITICAL: render every label EXACTLY as written, no invented boxes or arrows.
>
> TITLE: "DevOps Studio — Learning Path Map". SUBTITLE: "How the eight labs build on each other".
> Lay out as a left-to-right dependency graph in three tiers. Tier 1 (Foundations): "01 Terraform Foundations" and "03 CI/CD Pipelines". Tier 2 (Core platform): "02 Kubernetes Platform". Tier 3 (Advanced): "04 Observability Stack", "05 Security Automation", "06 GitOps Workflows", "07 Serverless Operations", "08 Platform Engineering".
> Arrows (teal, labeled "builds on"): 01 → 02; 01 → 07; 02 → 04; 02 → 05; 02 → 06; 03 → 02 (label "deploys to"); 06 → 02 (label "deploys to"); 01 → 08; 02 → 08. Give each box a small difficulty tag: 01 Beginner, 02 Intermediate, 03 Beginner, 04 Advanced, 05 Advanced, 06 Intermediate, 07 Intermediate, 08 Expert.
> EXACT LABEL LIST: DevOps Studio — Learning Path Map; How the eight labs build on each other; 01 Terraform Foundations; 02 Kubernetes Platform; 03 CI/CD Pipelines; 04 Observability Stack; 05 Security Automation; 06 GitOps Workflows; 07 Serverless Operations; 08 Platform Engineering; builds on; deploys to; Beginner; Intermediate; Advanced; Expert.

---

## 01 — Terraform Foundations: three-tier VPC

- **File:** `assets/diagrams/01-vpc-foundation.png`
- **Embed in:** `labs/01-terraform-foundations/README.md` (`## Architecture`)
- **Size:** landscape `1536×1024`
- **One job:** the multi-AZ, three-tier AWS network this lab provisions.

**FULL PROMPT**

> Create a clean, modern technical system-architecture diagram in flat vector infographic style. White background, generous whitespace, precise alignment. Soft rounded rectangles, thin borders, very light tint fills; group related systems inside labeled boundary containers; thin labeled arrows where direction matters. Flat line icons only — no photorealism, 3D, gradients, or shadows. Clean sans-serif, short bold labels, high contrast, fully legible. Palette: ink deep navy `#0f1923`; active path teal `#0f766e`; success green `#1a6b35`; fills are light tints only. CRITICAL: render every label EXACTLY as written, no invented boxes or arrows.
>
> TITLE: "Lab 01 — Terraform Foundations". SUBTITLE: "Multi-AZ three-tier VPC on AWS".
> Top: a box "Internet Gateway". Below it, three stacked horizontal boundary containers spanning two availability zones (label the two columns "us-west-2a" and "us-west-2b"):
> 1. Container "Public Subnets (Web Tier)" containing "Application Load Balancer" and "NAT Gateway" in each AZ.
> 2. Container "Private Subnets (App Tier)" containing "EC2 Instance (Auto Scaling Group)" in each AZ.
> 3. Container "Database Subnets (Data Tier)" containing "RDS Primary" (left) and "RDS Standby" (right), with a horizontal double-headed arrow between them labeled "Multi-AZ replication".
> Vertical teal arrows connect Internet Gateway → Public → App → Data tiers. Add a small side note box "Remote state: S3 + DynamoDB lock".
> EXACT LABEL LIST: Lab 01 — Terraform Foundations; Multi-AZ three-tier VPC on AWS; Internet Gateway; us-west-2a; us-west-2b; Public Subnets (Web Tier); Application Load Balancer; NAT Gateway; Private Subnets (App Tier); EC2 Instance (Auto Scaling Group); Database Subnets (Data Tier); RDS Primary; RDS Standby; Multi-AZ replication; Remote state: S3 + DynamoDB lock.

---

## 02 — Kubernetes Platform: EKS architecture

- **File:** `assets/diagrams/02-eks-platform.png`
- **Embed in:** `labs/02-kubernetes-platform/README.md` (`## Architecture`)
- **Size:** landscape `1536×1024`
- **One job:** EKS control plane, worker node groups, and how traffic reaches a pod.

**FULL PROMPT**

> Create a clean, modern technical system-architecture diagram in flat vector infographic style. White background, generous whitespace, precise alignment. Soft rounded rectangles, thin borders, light tint fills; labeled boundary containers; thin labeled arrows. Flat line icons only — no photorealism, 3D, gradients, or shadows. Clean sans-serif, short bold labels, fully legible. Palette: ink deep navy `#0f1923`; active path teal `#0f766e`; fills light tints only. CRITICAL: render every label EXACTLY as written, no invented boxes or arrows.
>
> TITLE: "Lab 02 — Kubernetes Platform". SUBTITLE: "Amazon EKS cluster and traffic path".
> Top: boundary "Public Subnets" containing "EKS Control Plane (managed by AWS)" with three small chips inside: "API Server", "etcd", "Scheduler".
> Middle: boundary "Private Subnets (Node Groups)" with two boxes side by side, "Node Group A" and "Node Group B", each listing chips "Worker Nodes", "kubelet", "kube-proxy".
> Bottom: boundary "Application Layer" with a left-to-right flow of three boxes connected by teal arrows: "Ingress Controller" → "Service (ClusterIP)" → "Deployment (Pods)". Label the arrow entering Ingress Controller "HTTPS traffic".
> Connect Control Plane → Node Groups (label "schedules pods") and Node Groups → Application Layer.
> EXACT LABEL LIST: Lab 02 — Kubernetes Platform; Amazon EKS cluster and traffic path; Public Subnets; EKS Control Plane (managed by AWS); API Server; etcd; Scheduler; Private Subnets (Node Groups); Node Group A; Node Group B; Worker Nodes; kubelet; kube-proxy; Application Layer; Ingress Controller; Service (ClusterIP); Deployment (Pods); HTTPS traffic; schedules pods.

---

## 03 — CI/CD Pipelines: build-to-deploy flow

- **File:** `assets/diagrams/03-cicd-pipeline.png`
- **Embed in:** `labs/03-cicd-pipelines/README.md` (`## Architecture`)
- **Size:** landscape `1536×1024`
- **One job:** the pipeline stages from commit to a verified deploy, across three CI tools.

**FULL PROMPT**

> Create a clean, modern technical system-architecture diagram in flat vector infographic style. White background, generous whitespace, precise alignment. Soft rounded rectangles, thin borders, light tint fills; thin labeled arrows; left-to-right flow. Flat line icons only — no photorealism, 3D, gradients, or shadows. Clean sans-serif, short bold labels, fully legible. Palette: ink deep navy `#0f1923`; active path teal `#0f766e`; success green `#1a6b35`; warning amber `#b8860b`; fills light tints only. CRITICAL: render every label EXACTLY as written, no invented boxes or arrows.
>
> TITLE: "Lab 03 — CI/CD Pipelines". SUBTITLE: "From commit to verified deploy".
> Far left: box "Source Code (Git Repository)". An arrow fans out to three parallel CI runners shown as a small grouped row: "GitHub Actions", "GitLab CI", "Jenkins" (label the group "Choose one CI runner"). The three converge into a single left-to-right pipeline of stages connected by teal arrows: "Build" → "Test" → "Security Scan" (tint amber) → "Docker Build & Push to ECR" → "Deploy to Kubernetes (Lab 02 EKS)" → "Verify (health checks)" (tint green).
> EXACT LABEL LIST: Lab 03 — CI/CD Pipelines; From commit to verified deploy; Source Code (Git Repository); Choose one CI runner; GitHub Actions; GitLab CI; Jenkins; Build; Test; Security Scan; Docker Build & Push to ECR; Deploy to Kubernetes (Lab 02 EKS); Verify (health checks).

---

## 04 — Observability Stack: three pillars

- **File:** `assets/diagrams/04-observability-stack.png`
- **Embed in:** `labs/04-observability-stack/README.md` (`## Architecture`)
- **Size:** landscape `1536×1024`
- **One job:** how metrics, logs, and traces flow from apps into a single pane.

**FULL PROMPT**

> Create a clean, modern technical system-architecture diagram in flat vector infographic style. White background, generous whitespace, precise alignment. Soft rounded rectangles, thin borders, light tint fills; thin labeled arrows where direction matters. Flat line icons only — no photorealism, 3D, gradients, or shadows. Clean sans-serif, short bold labels, fully legible. Palette: ink deep navy `#0f1923`; active path teal `#0f766e`; fills light tints only. CRITICAL: render every label EXACTLY as written, no invented boxes or arrows.
>
> TITLE: "Lab 04 — Observability Stack". SUBTITLE: "Metrics, logs, and traces in one pane".
> Top: a wide box "Application Services (Pods, Containers, Microservices)". From it, three labeled vertical paths descend (label them "Metrics", "Logs", "Traces"):
> - Metrics path: → "Prometheus".
> - Logs path: → "Fluent Bit" → "OpenSearch".
> - Traces path: → "Jaeger".
> All three paths converge with teal arrows into a single bottom box "Grafana (Visualization)". Add a small box off "Prometheus" labeled "Alertmanager" with an arrow labeled "alerts".
> EXACT LABEL LIST: Lab 04 — Observability Stack; Metrics, logs, and traces in one pane; Application Services (Pods, Containers, Microservices); Metrics; Logs; Traces; Prometheus; Fluent Bit; OpenSearch; Jaeger; Grafana (Visualization); Alertmanager; alerts.

---

## 05 — Security Automation: where each control fires

- **File:** `assets/diagrams/05-security-layers.png`
- **Embed in:** `labs/05-security-automation/README.md` (`## Architecture`)
- **Size:** landscape `1536×1024`
- **One job:** map each security tool to its enforcement point across build, deploy, and runtime.

**FULL PROMPT**

> Create a clean, modern technical system-architecture diagram in flat vector infographic style. White background, generous whitespace, precise alignment. Soft rounded rectangles, thin borders, light tint fills; labeled boundary containers; thin labeled arrows. Flat line icons only — no photorealism, 3D, gradients, or shadows. Clean sans-serif, short bold labels, fully legible. Palette: ink deep navy `#0f1923`; active path teal `#0f766e`; warning amber `#b8860b`; failure red `#8b1a1a`; control layer purple `#6b21a8`; fills light tints only. CRITICAL: render every label EXACTLY as written, no invented boxes or arrows.
>
> TITLE: "Lab 05 — Security Automation". SUBTITLE: "Defense in depth across the lifecycle".
> Left-to-right swimlane of three labeled stages, each with the control that fires there (tint controls purple):
> - Stage "Build (CI/CD)": control "Trivy — image & dependency scanning" and "OPA — policy checks".
> - Stage "Deploy (Admission)": control "OPA Gatekeeper — admission control" with two outcome chips "Allowed" (green) and "Denied" (red).
> - Stage "Runtime (Cluster)": controls "Falco — runtime threat detection" and "RBAC — least-privilege access".
> Center the three stages around a "Kubernetes Cluster" boundary that Deploy and Runtime act on. Teal arrow across the bottom labeled "software delivery lifecycle".
> EXACT LABEL LIST: Lab 05 — Security Automation; Defense in depth across the lifecycle; Build (CI/CD); Trivy — image & dependency scanning; OPA — policy checks; Deploy (Admission); OPA Gatekeeper — admission control; Allowed; Denied; Runtime (Cluster); Falco — runtime threat detection; RBAC — least-privilege access; Kubernetes Cluster; software delivery lifecycle.

---

## 06 — GitOps Workflows: the reconciliation loop

- **File:** `assets/diagrams/06-gitops-reconciliation.png`
- **Embed in:** `labs/06-gitops-workflows/README.md` (`## Architecture`)
- **Size:** landscape `1536×1024`
- **One job:** the continuous reconciliation between Git (desired state) and the cluster (actual state).

**FULL PROMPT**

> Create a clean, modern technical system-architecture diagram in flat vector infographic style. White background, generous whitespace, precise alignment. Soft rounded rectangles, thin borders, light tint fills; labeled boundary containers; thin labeled arrows forming a clear loop. Flat line icons only — no photorealism, 3D, gradients, or shadows. Clean sans-serif, short bold labels, fully legible. Palette: ink deep navy `#0f1923`; active path teal `#0f766e`; warning amber `#b8860b`; fills light tints only. CRITICAL: render every label EXACTLY as written, no invented boxes or arrows.
>
> TITLE: "Lab 06 — GitOps Workflows". SUBTITLE: "Continuous reconciliation of desired and actual state".
> Left boundary "Git Repository (desired state)" containing a small tree: "Kustomize base/", "overlays/staging/", "overlays/production/". Right boundary "Kubernetes Cluster (actual state)" containing "Argo CD / Flux controller" and below it "Application Pods".
> Draw a continuous loop with labeled teal arrows: Developer box → "git push" → Git Repository; Git Repository → "watch / pull" → Argo CD / Flux controller; controller → "apply" → Application Pods; Application Pods → "observe actual state" → controller; controller → "detect drift" (amber, dashed) back toward Git Repository comparison. Caption under the loop: "Git is the single source of truth".
> EXACT LABEL LIST: Lab 06 — GitOps Workflows; Continuous reconciliation of desired and actual state; Git Repository (desired state); Kustomize base/; overlays/staging/; overlays/production/; Kubernetes Cluster (actual state); Argo CD / Flux controller; Application Pods; Developer; git push; watch / pull; apply; observe actual state; detect drift; Git is the single source of truth.

---

## 07 — Serverless Operations: three patterns

- **File:** `assets/diagrams/07-serverless-architecture.png`
- **Embed in:** `labs/07-serverless-operations/README.md` (`## Architecture`)
- **Size:** landscape `1536×1024` (three vertical frames side by side)
- **One job:** the three serverless patterns the lab builds — request API, event processing, and orchestration.

**FULL PROMPT**

> Create a clean, modern technical system-architecture diagram in flat vector infographic style, composed as three side-by-side frames separated by thin dividers, each with its own subtitle. White background, generous whitespace, precise alignment. Soft rounded rectangles, thin borders, light tint fills; thin labeled arrows, top-to-bottom within each frame. Flat line icons only — no photorealism, 3D, gradients, or shadows. Clean sans-serif, short bold labels, fully legible. Palette: ink deep navy `#0f1923`; active path teal `#0f766e`; fills light tints only. CRITICAL: render every label EXACTLY as written, no invented boxes or arrows.
>
> TITLE (spanning the top): "Lab 07 — Serverless Operations". SUBTITLE: "Three event-driven patterns".
> Frame 1 subtitle "Request API": "Client (Browser)" → (arrow "HTTP request") "API Gateway (REST/HTTP API)" → (arrow "invoke") "Lambda Function" → (arrow "query / write") "DynamoDB Table".
> Frame 2 subtitle "Event processing": "S3 Bucket (file upload)" → (arrow "event") "Lambda (Processor)" → (arrow "store result") "DynamoDB".
> Frame 3 subtitle "Orchestration": "Step Functions (State Machine)" branching with arrows to "Lambda 1 (Validate)", "Lambda 2 (Process)", "Lambda 3 (Notify)".
> EXACT LABEL LIST: Lab 07 — Serverless Operations; Three event-driven patterns; Request API; Client (Browser); HTTP request; API Gateway (REST/HTTP API); invoke; Lambda Function; query / write; DynamoDB Table; Event processing; S3 Bucket (file upload); event; Lambda (Processor); store result; DynamoDB; Orchestration; Step Functions (State Machine); Lambda 1 (Validate); Lambda 2 (Process); Lambda 3 (Notify).

---

## 08 — Platform Engineering: the internal developer platform

- **File:** `assets/diagrams/08-idp-platform.png`
- **Embed in:** `labs/08-platform-engineering/README.md` (`## Architecture`)
- **Size:** portrait `1024×1536` (four stacked layers)
- **One job:** the four-layer IDP and the self-service provisioning flow through it.

**FULL PROMPT**

> Create a clean, modern technical system-architecture diagram in flat vector infographic style, arranged as four stacked horizontal layers connected top-to-bottom. White background, generous whitespace, precise alignment. Soft rounded rectangles, thin borders, light tint fills; labeled boundary containers for each layer; thin labeled arrows. Flat line icons only — no photorealism, 3D, gradients, or shadows. Clean sans-serif, short bold labels, fully legible. Palette: ink deep navy `#0f1923`; active path teal `#0f766e`; control/platform layer purple `#6b21a8`; fills light tints only. CRITICAL: render every label EXACTLY as written, no invented boxes or arrows.
>
> TITLE: "Lab 08 — Platform Engineering". SUBTITLE: "Internal Developer Platform (IDP)".
> Four stacked boundary layers, each containing three boxes, with a teal vertical arrow running down the right edge labeled "self-service request":
> 1. Layer "Developer Portal": "Service Catalog", "Provision Infrastructure", "Monitor Resources".
> 2. Layer "Platform API Layer" (tint purple): "Provisioning API", "CI/CD API", "Monitoring API".
> 3. Layer "Infrastructure Automation Layer": "Terraform Automation", "GitHub Actions", "CloudWatch Metrics".
> 4. Layer "AWS Infrastructure": "VPC / EC2 / ASG", "EKS / RDS", "Lambda / S3 / DynamoDB".
> Arrows top-to-bottom between layers labeled, in order: "select template", "call API", "provision", so the flow reads Portal → Platform API → Automation → AWS.
> EXACT LABEL LIST: Lab 08 — Platform Engineering; Internal Developer Platform (IDP); self-service request; Developer Portal; Service Catalog; Provision Infrastructure; Monitor Resources; Platform API Layer; Provisioning API; CI/CD API; Monitoring API; Infrastructure Automation Layer; Terraform Automation; GitHub Actions; CloudWatch Metrics; AWS Infrastructure; VPC / EC2 / ASG; EKS / RDS; Lambda / S3 / DynamoDB; select template; call API; provision.

---

## Platform connection map (how it all connects)

- **File:** `assets/diagrams/overview-connections.png`
- **Embed in:** `index.md` (home) and the top of `labs/README.md`
- **Size:** landscape `1536×1024`
- **One job:** show how the eight labs' systems compose into one platform — *not* every internal detail.

> **Readability is the point.** This replaces the dense "everything at once" overview. Keep it to ~10 boxes (one headline system per lab) and only the connections below. Big labels, lots of whitespace, legible at a glance.

**FULL PROMPT**

> Create a clean, modern technical system-architecture diagram in flat vector infographic style. White background, generous whitespace, precise alignment, large legible labels. Render each system as a soft rounded rectangle with a thin border and a very light tint fill; connect with thin arrows carrying short labels where direction is meaningful. Flat line icons only — no photorealism, no 3D, no gradients, no drop shadows, no decorative noise. Clean sans-serif type, short bold labels, high contrast. Keep it uncluttered: about ten boxes and only the arrows listed — do not add internal sub-components. Palette: ink/text deep navy `#0f1923`; primary/active path teal `#0f766e`; control/platform layer purple `#6b21a8`; soft tints only. CRITICAL: render every label EXACTLY as written, no invented boxes or arrows.
>
> TITLE: "DevOps Studio — How It All Connects". SUBTITLE: "Eight labs, one platform".
> Layout in horizontal bands:
> - TOP band — a single wide box spanning the width: "Lab 08 · Platform Engineering (self-service portal)" (tint purple). A downward arrow labeled "provisions & orchestrates" points into the platform below.
> - CENTER — the hub box "Lab 02 · Kubernetes Platform (EKS)".
> - LEFT of center — a "Delivery" group with two boxes, "Lab 03 · CI/CD Pipelines" and "Lab 06 · GitOps Workflows", each with a teal arrow into the EKS hub. Label the CI/CD arrow "build & deploy" and the GitOps arrow "sync from Git".
> - RIGHT of center — "Lab 04 · Observability" with an arrow from EKS labeled "metrics, logs, traces", and "Lab 05 · Security Automation" with an arrow into EKS labeled "scan & enforce".
> - BESIDE the hub — "Lab 07 · Serverless Operations" sitting on the same foundation as EKS (no arrow into EKS; it shares the base).
> - BOTTOM band — a single wide box spanning the width: "Lab 01 · Terraform Foundations (VPC, network, IAM)" with upward arrows labeled "runs on" feeding both the EKS hub and the Serverless box.
> EXACT LABEL LIST: DevOps Studio — How It All Connects; Eight labs, one platform; Lab 08 · Platform Engineering (self-service portal); provisions & orchestrates; Lab 02 · Kubernetes Platform (EKS); Delivery; Lab 03 · CI/CD Pipelines; Lab 06 · GitOps Workflows; build & deploy; sync from Git; Lab 04 · Observability; metrics, logs, traces; Lab 05 · Security Automation; scan & enforce; Lab 07 · Serverless Operations; Lab 01 · Terraform Foundations (VPC, network, IAM); runs on.

## Optional second wave (sequence diagrams)

These teach *dynamic* behavior over time and pair well with the architecture
images above. Generate them with the same style block; compose as a UML-style
sequence diagram (vertical lifelines, numbered messages left-to-right in time).

| Image | File | Lifelines / messages |
|-------|------|----------------------|
| Serverless request lifecycle | `07b-serverless-sequence.png` | Client → API Gateway → Lambda → DynamoDB → response (success + throttled/error path) |
| OPA admission decision | `05b-opa-admission-sequence.png` | kubectl apply → API Server → OPA Gatekeeper webhook → Allowed / Denied |
| IDP self-service provisioning | `08b-idp-self-service-sequence.png` | Developer → Service Catalog → Platform API → Terraform Automation → AWS → returns endpoint |

## Suggested generation order

1. `06-gitops-reconciliation` and `04-observability-stack` — the two concepts hardest to grasp from text.
2. `07-serverless-architecture` and `00-curriculum-map` — high reuse in interviews/demos.
3. The remaining per-lab architecture images (`01`, `02`, `03`, `05`, `08`).
4. Optional second-wave sequence diagrams once the architecture set looks consistent.
