# CI/CD Tools Comparison
*Understanding GitHub Actions, GitLab CI, and Jenkins in Lab 03*

> **Navigation**: [Lab 03 - CI/CD Pipelines](README.md) > CI/CD Tools Comparison

---

## Overview

Lab 03 demonstrates the same CI/CD pipeline using three different tools:
- **GitHub Actions** - Cloud-hosted CI/CD for GitHub repositories
- **GitLab CI** - Built-in CI/CD for GitLab repositories  
- **Jenkins** - Self-hosted, open-source automation server

All three tools perform the **same workflow** but with different syntax and execution models.

---

## The Common Workflow

All three tools execute this pipeline:

```
1. Test → 2. Build → 3. Security Scan → 4. Deploy Staging → 5. Deploy Production
```

### Stage Breakdown

| Stage | What It Does | Why It Matters |
|-------|--------------|---------------|
| **Test** | Runs unit and integration tests | Catches bugs before deployment |
| **Build** | Creates Docker image and pushes to ECR | Packages application for deployment |
| **Security Scan** | Scans Docker image for vulnerabilities | Ensures security compliance |
| **Deploy Staging** | Deploys to staging environment | Tests deployment process |
| **Deploy Production** | Deploys to production (with approval) | Releases to users |

---

## What Each Tool Does

### 🔵 GitHub Actions

**What it's doing:**

1. **CI Pipeline** (`ci.yml`):
   - **Test Job**: Runs unit and integration tests on every push/PR
   - **Build Job**: Builds Docker image and pushes to AWS ECR (only on push)
   - **Security Scan Job**: Scans Docker image with Trivy

2. **CD Pipeline** (`cd.yml`):
   - **Deploy Staging**: Automatically deploys to staging on push to `main`
   - **Deploy Production**: Manual deployment via workflow dispatch

**Key Characteristics:**
- ✅ Cloud-hosted (runs on GitHub's servers)
- ✅ Integrated with GitHub repositories
- ✅ YAML-based workflow files
- ✅ Free tier: 2,000 minutes/month for private repos
- ✅ Uses "actions" (reusable components)

**Trigger**: Automatically on git push/pull request

---

### 🟠 GitLab CI

**What it's doing:**

1. **Test Stage**:
   - `test:unit`: Runs unit tests in parallel
   - `test:integration`: Runs integration tests in parallel
   - Both run in Docker containers (`node:18-alpine`)

2. **Build Stage**:
   - Builds Docker image using Docker-in-Docker (dind)
   - Pushes to AWS ECR with commit SHA and `latest` tags
   - Only runs on `main` and `develop` branches

3. **Security Stage**:
   - Runs Trivy vulnerability scanner
   - Allows failure (non-blocking)

4. **Deploy Stage**:
   - `deploy:staging`: Automatically deploys to staging on `main` branch
   - `deploy:production`: Manual approval required (`when: manual`)

**Key Characteristics:**
- ✅ Built into GitLab (no separate service)
- ✅ Runs on GitLab Runners (shared or self-hosted)
- ✅ YAML-based configuration (`.gitlab-ci.yml`)
- ✅ Free tier includes CI/CD minutes
- ✅ Uses Docker containers for each job

**Trigger**: Automatically on git push to configured branches

---

### 🔴 Jenkins

**What it's doing:**

1. **Checkout Stage**:
   - Checks out source code from repository

2. **Test Stage** (Parallel):
   - **Unit Tests**: Runs unit tests, publishes results
   - **Integration Tests**: Runs integration tests
   - Both run in parallel for speed

3. **Build Stage**:
   - Logs into AWS ECR
   - Builds Docker image with commit SHA tag
   - Pushes to ECR (only on `main`/`develop` branches)

4. **Security Scan Stage**:
   - Runs Trivy scanner on Docker image
   - Only on `main`/`develop` branches

5. **Deploy to Staging**:
   - Configures kubectl for EKS
   - Updates Kubernetes manifests
   - Deploys to staging (only on `main` branch)

6. **Deploy to Production**:
   - **Requires manual approval** (interactive prompt)
   - Deploys to production after approval
   - Runs smoke tests after deployment

**Key Characteristics:**
- ✅ Self-hosted (you run the server)
- ✅ Highly customizable with plugins
- ✅ Groovy-based pipeline syntax (Jenkinsfile)
- ✅ Free and open-source
- ✅ Can run on any infrastructure

**Trigger**: Can be triggered by webhooks, scheduled, or manually

---

## Key Differences

### 1. **Hosting Model**

| Tool | Hosting | Setup Complexity |
|------|---------|------------------|
| **GitHub Actions** | Cloud (GitHub) | ⭐ Easiest - Just add files |
| **GitLab CI** | Cloud (GitLab) or Self-hosted | ⭐⭐ Easy - Built-in |
| **Jenkins** | Self-hosted | ⭐⭐⭐ Moderate - Need to install |

### 2. **Configuration Syntax**

| Tool | Syntax | File Location |
|------|--------|---------------|
| **GitHub Actions** | YAML | `.github/workflows/*.yml` |
| **GitLab CI** | YAML | `.gitlab-ci.yml` (root) |
| **Jenkins** | Groovy (Declarative) | `Jenkinsfile` (root) |

### 3. **Execution Environment**

| Tool | Where Jobs Run | Container Support |
|------|----------------|-------------------|
| **GitHub Actions** | GitHub-hosted runners | ✅ Yes (specify in workflow) |
| **GitLab CI** | GitLab Runners | ✅ Yes (Docker images) |
| **Jenkins** | Jenkins agents/nodes | ✅ Yes (via plugins) |

### 4. **Cost Model**

| Tool | Free Tier | Paid Plans |
|------|----------|------------|
| **GitHub Actions** | 2,000 min/month (private) | Pay per minute |
| **GitLab CI** | 400 min/month (free tier) | Included in GitLab plans |
| **Jenkins** | Unlimited (self-hosted) | Infrastructure costs only |

### 5. **Integration**

| Tool | Repository Integration | External Services |
|------|----------------------|-------------------|
| **GitHub Actions** | ✅ Native GitHub | Via actions marketplace |
| **GitLab CI** | ✅ Native GitLab | Via Docker images |
| **Jenkins** | ⚠️ Via plugins | Via plugins/extensions |

### 6. **Approval Process**

| Tool | How Approvals Work |
|------|-------------------|
| **GitHub Actions** | Environment protection rules (UI) |
| **GitLab CI** | `when: manual` (button in UI) |
| **Jenkins** | `input` step (interactive prompt) |

---

## Side-by-Side Comparison

### Test Stage

**GitHub Actions:**
```yaml
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
    - run: npm ci
    - run: npm test
```

**GitLab CI:**
```yaml
test:unit:
  stage: test
  image: node:18-alpine
  script:
    - npm ci
    - npm run test:unit
```

**Jenkins:**
```groovy
stage('Test') {
    parallel {
        stage('Unit Tests') {
            steps {
                sh 'npm ci && npm run test:unit'
            }
        }
    }
}
```

### Build Stage

**GitHub Actions:**
```yaml
build:
  needs: test
  steps:
    - uses: aws-actions/amazon-ecr-login@v2
    - run: docker build -t $IMAGE:$TAG .
    - run: docker push $IMAGE:$TAG
```

**GitLab CI:**
```yaml
build:
  stage: build
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker build -t $IMAGE:$CI_COMMIT_SHA .
    - docker push $IMAGE:$CI_COMMIT_SHA
```

**Jenkins:**
```groovy
stage('Build') {
    steps {
        sh 'aws ecr get-login-password | docker login'
        sh 'docker build -t $IMAGE:$TAG .'
        sh 'docker push $IMAGE:$TAG'
    }
}
```

---

## When to Use Which?

### Use **GitHub Actions** if:
- ✅ Your code is on GitHub
- ✅ You want the simplest setup
- ✅ You need cloud-hosted CI/CD
- ✅ You want tight GitHub integration
- ✅ You're okay with usage limits

### Use **GitLab CI** if:
- ✅ Your code is on GitLab
- ✅ You want built-in CI/CD (no separate service)
- ✅ You need Docker-based workflows
- ✅ You want integrated DevOps platform
- ✅ You prefer YAML configuration

### Use **Jenkins** if:
- ✅ You need self-hosted solution
- ✅ You want unlimited, free execution
- ✅ You need maximum customization
- ✅ You have on-premises requirements
- ✅ You want full control over infrastructure

---

## Real-World Scenarios

### Scenario 1: Small Startup
**Best Choice**: GitHub Actions
- Simple setup
- Free tier sufficient
- No infrastructure to manage

### Scenario 2: Enterprise with GitLab
**Best Choice**: GitLab CI
- Already using GitLab
- Built-in CI/CD
- Integrated DevOps platform

### Scenario 3: Large Enterprise (On-Prem)
**Best Choice**: Jenkins
- Self-hosted control
- No cloud dependencies
- Unlimited scalability

### Scenario 4: Hybrid Approach
**Best Choice**: Multiple tools
- GitHub Actions for open-source projects
- GitLab CI for internal projects
- Jenkins for sensitive/on-prem workloads

---

## Summary

All three tools accomplish the **same goal**: automate testing, building, and deployment. The differences are:

| Aspect | GitHub Actions | GitLab CI | Jenkins |
|--------|---------------|-----------|---------|
| **Ease of Use** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Flexibility** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Cost** | Pay per use | Included | Free (self-hosted) |
| **Setup Time** | Minutes | Minutes | Hours |
| **Best For** | GitHub repos | GitLab repos | Self-hosted needs |

**The Bottom Line**: Choose based on where your code lives and your infrastructure preferences. All three will get the job done!

---

## Next Steps

- Try each tool in Lab 03
- Compare the configuration files
- Understand which fits your use case
- See [Lab 03 README](README.md) for detailed setup instructions

---

**Questions?** Check the individual tool documentation:
- [GitHub Actions README](github-actions/README.md)
- [GitLab CI README](gitlab-ci/README.md)
- [Jenkins README](jenkins/README.md)

