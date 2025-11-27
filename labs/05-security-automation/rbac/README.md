# RBAC - Role-Based Access Control

RBAC (Role-Based Access Control) controls who can perform what actions in Kubernetes. It's essential for securing your cluster and following the principle of least privilege.

## Overview

RBAC provides:
- **Role Definitions** - What actions can be performed
- **Role Bindings** - Who can perform those actions
- **Service Account Security** - Secure pod-to-API access
- **Least Privilege** - Minimal required permissions
- **Audit Trail** - Track who did what

## RBAC Components

### Roles and ClusterRoles

**Role**: Namespace-scoped permissions
**ClusterRole**: Cluster-wide permissions

### RoleBindings and ClusterRoleBindings

**RoleBinding**: Binds role to user/group in namespace
**ClusterRoleBinding**: Binds cluster role cluster-wide

## Common Roles

### Developer Role

Allows developers to manage resources in their namespace:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: developer
  namespace: devops-studio
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps"]
  verbs: ["get", "list", "create", "update", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "create", "update", "delete"]
```

### Read-Only Role

Allows viewing resources without modification:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: viewer
  namespace: devops-studio
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
```

### Admin Role

Full access to namespace:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: admin
  namespace: devops-studio
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["*"]
```

## Service Accounts

### Create Service Account

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-service-account
  namespace: devops-studio
```

### Bind Role to Service Account

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-role-binding
  namespace: devops-studio
subjects:
- kind: ServiceAccount
  name: app-service-account
  namespace: devops-studio
roleRef:
  kind: Role
  name: developer
  apiGroup: rbac.authorization.k8s.io
```

### Use Service Account in Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  serviceAccountName: app-service-account
  containers:
  - name: app
    image: nginx:latest
```

## Best Practices

### Least Privilege

1. **Start with minimal permissions**
2. **Add permissions only when needed**
3. **Review permissions regularly**
4. **Remove unused permissions**

### Service Account Security

1. **Use dedicated service accounts** for each application
2. **Don't use default service account**
3. **Limit service account permissions**
4. **Rotate service account tokens**

### Role Design

1. **Namespace-scoped when possible**
2. **Group related permissions**
3. **Document why permissions are needed**
4. **Review and audit regularly**

## Common Patterns

### Read-Only Access

```yaml
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["get", "list", "watch"]
```

### Deployment Management

```yaml
rules:
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "create", "update", "delete", "patch"]
```

### Secret Access

```yaml
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "list"]
  resourceNames: ["app-secret"]  # Specific secret only
```

## Troubleshooting

### Permission Denied

```bash
# Check user's permissions
kubectl auth can-i create deployments --namespace devops-studio

# Check service account permissions
kubectl auth can-i create pods --as=system:serviceaccount:devops-studio:app-service-account

# View role bindings
kubectl get rolebindings -n devops-studio
kubectl get clusterrolebindings
```

### Debug Access Issues

```bash
# Describe role binding
kubectl describe rolebinding <name> -n <namespace>

# Check service account
kubectl get serviceaccount -n <namespace>
kubectl describe serviceaccount <name> -n <namespace>
```

## Additional Resources

- [Kubernetes RBAC Documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [RBAC Best Practices](https://kubernetes.io/docs/concepts/security/rbac-good-practices/)

