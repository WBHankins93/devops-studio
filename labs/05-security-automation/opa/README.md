# OPA Gatekeeper - Policy Enforcement

OPA (Open Policy Agent) Gatekeeper is a policy controller for Kubernetes that enforces policies on resources before they're created.

## Overview

OPA Gatekeeper provides:
- **Admission Control** - Validate resources before creation
- **Policy as Code** - Version-controlled policies (Rego language)
- **Pre-built Templates** - Common security policies
- **Custom Policies** - Create your own policies
- **Automatic Enforcement** - No manual intervention needed

## Installation

### Using Helm

```bash
# Add Gatekeeper Helm repository
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm repo update

# Install Gatekeeper
helm install gatekeeper gatekeeper/gatekeeper \
  --namespace gatekeeper-system \
  --create-namespace
```

### Verify Installation

```bash
# Check Gatekeeper pods
kubectl get pods -n gatekeeper-system

# Check constraint templates
kubectl get constrainttemplate
```

## How It Works

1. **User creates resource** (e.g., `kubectl apply -f deployment.yaml`)
2. **Gatekeeper intercepts** the request
3. **Policy evaluated** using Rego
4. **Decision made**: Allow or deny
5. **Resource created** (if allowed) or **rejected** (if denied)

## Policy Examples

### Require Resource Limits

**Constraint Template** (`policies/require-resource-limits.yaml`):

```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredresources
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredResources
      validation:
        openAPIV3Schema:
          type: object
          properties:
            limits:
              type: object
            requests:
              type: object
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredresources
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          not container.resources.limits
          msg := sprintf("Container '%v' is missing resource limits", [container.name])
        }
```

**Constraint** (`constraints/require-resource-limits.yaml`):

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredResources
metadata:
  name: must-have-resource-limits
spec:
  match:
    kinds:
      - apiGroups: ["apps"]
        kinds: ["Deployment"]
  parameters:
    limits:
      cpu: "500m"
      memory: "512Mi"
```

### Block Privileged Containers

**Constraint Template** (`policies/block-privileged.yaml`):

```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredsecuritycontext
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredSecurityContext
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredsecuritycontext
        
        violation[{"msg": msg}] {
          container := input.review.object.spec.containers[_]
          container.securityContext.privileged == true
          msg := sprintf("Container '%v' must not run as privileged", [container.name])
        }
```

**Constraint**:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredSecurityContext
metadata:
  name: no-privileged-containers
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
```

### Require Labels

**Constraint Template** (`policies/require-labels.yaml`):

```yaml
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
      validation:
        openAPIV3Schema:
          type: object
          properties:
            labels:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlabels
        
        violation[{"msg": msg}] {
          required := input.parameters.labels[_]
          not input.review.object.metadata.labels[required]
          msg := sprintf("Missing required label: %v", [required])
        }
```

**Constraint**:

```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: must-have-labels
spec:
  match:
    kinds:
      - apiGroups: ["apps"]
        kinds: ["Deployment"]
  parameters:
    labels:
      - "app"
      - "environment"
```

## Usage

### Apply Policies

```bash
# Apply constraint template
kubectl apply -f opa/policies/require-resource-limits.yaml

# Apply constraint
kubectl apply -f opa/constraints/require-resource-limits.yaml

# Verify constraint is active
kubectl get constraint
```

### Test Policy Enforcement

```bash
# Try to create a pod without resource limits (should be rejected)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test
    image: nginx:latest
EOF

# Should see error: "Container 'test' is missing resource limits"
```

### View Policy Violations

```bash
# Check constraint status
kubectl describe constraint must-have-resource-limits

# View all violations
kubectl get constraint --all-namespaces
```

## Rego Policy Language

### Basic Syntax

```rego
package policy_name

# Rule that produces violations
violation[{"msg": msg}] {
  # Condition
  condition == true
  msg := "Error message"
}
```

### Common Patterns

```rego
# Check if field exists
not input.review.object.spec.containers[_].resources

# Check field value
input.review.object.spec.containers[_].securityContext.privileged == true

# Iterate over array
container := input.review.object.spec.containers[_]
container.name == "test"

# String operations
sprintf("Message: %v", [variable])
```

## Best Practices

### Policy Design

1. **Start Simple**: Begin with basic policies
2. **Test Thoroughly**: Test policies before enforcing
3. **Document Policies**: Explain why policies exist
4. **Version Control**: Keep policies in Git

### Common Policies

- Require resource limits
- Block privileged containers
- Require security contexts
- Enforce label requirements
- Restrict image registries
- Require network policies

## Troubleshooting

### Policies Not Enforcing

```bash
# Check Gatekeeper is running
kubectl get pods -n gatekeeper-system

# Check constraint templates
kubectl get constrainttemplate

# Check constraints
kubectl get constraint

# View Gatekeeper logs
kubectl logs -n gatekeeper-system -l control-plane=controller-manager
```

### Policy Syntax Errors

```bash
# Validate Rego syntax
# Use OPA CLI or online validator
opa test policies/
```

## Additional Resources

- [OPA Documentation](https://www.openpolicyagent.org/docs/)
- [Gatekeeper Documentation](https://open-policy-agent.github.io/gatekeeper/)
- [Rego Language Guide](https://www.openpolicyagent.org/docs/latest/policy-language/)

