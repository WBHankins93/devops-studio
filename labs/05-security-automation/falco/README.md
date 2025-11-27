# Falco - Runtime Security Monitoring

Falco is a cloud-native runtime security tool that detects anomalous activity in your containers and Kubernetes clusters.

## Overview

Falco provides:
- **Real-time Threat Detection** - Monitor system calls and events
- **Custom Rules** - Create rules for your specific needs
- **Kubernetes Integration** - Native Kubernetes support
- **Alerting** - Integrate with notification systems
- **Compliance** - Meet security compliance requirements

## Installation

### Using Helm

```bash
# Add Falco Helm repository
helm repo add falcosecurity https://falcosecurity.github.io/charts
helm repo update

# Install Falco
helm install falco falcosecurity/falco \
  --namespace falco \
  --create-namespace \
  --values values.yaml
```

### Verify Installation

```bash
# Check Falco pods
kubectl get pods -n falco

# Check Falco logs
kubectl logs -n falco -l app=falco
```

## How It Works

Falco monitors system calls and events using eBPF or kernel modules:

1. **System call occurs** (e.g., shell execution, file access)
2. **Falco captures event** via eBPF/kernel
3. **Rules evaluated** against event
4. **Alert triggered** if rule matches
5. **Notification sent** (logs, webhook, etc.)

## Default Rules

Falco comes with pre-built rules that detect:

- Shell execution in containers
- Unauthorized file access
- Network connections
- Privilege escalations
- Sensitive file access
- Process anomalies

## Custom Rules

### Example: Detect Shell Execution

Create `rules/detect-shell.yaml`:

```yaml
- rule: Detect Shell in Container
  desc: Detect shell execution in containers
  condition: >
    spawned_process and container and
    shell_procs and proc.tty != 0 and
    not container_entrypoint
  output: >
    Shell spawned in container (user=%user.name %container.info
    shell=%proc.name parent=%proc.pname cmdline=%proc.cmdline terminal=%proc.tty container_id=%container.id image=%container.image.repository)
  priority: WARNING
  tags: [container, shell, mitre_execution]
```

### Example: Detect Unauthorized Network Connection

```yaml
- rule: Unexpected Outbound Network Connection
  desc: Detect unexpected outbound network connections
  condition: >
    outbound and not allowed_outbound_ips and
    not trusted_containers
  output: >
    Unexpected outbound network connection (user=%user.name
    connection=%fd.name direction=%evt.type %container.info)
  priority: NOTICE
  tags: [network, container]
```

## Configuration

### Falco Configuration

Edit `config.yaml`:

```yaml
# Falco configuration
rules_file:
  - /etc/falco/falco_rules.yaml
  - /etc/falco/falco_rules.local.yaml
  - /etc/falco/rules.d

# JSON output
json_output: true
json_include_output_property: true
json_include_tags_property: true

# Logging
log_stderr: true
log_syslog: false
log_level: info

# Outputs
syscall_event_drops:
  actions:
    - log
    - alert
```

## Usage

### View Falco Events

```bash
# View Falco logs
kubectl logs -n falco -l app=falco

# Follow logs in real-time
kubectl logs -n falco -l app=falco -f

# Filter by priority
kubectl logs -n falco -l app=falco | grep "Priority: CRITICAL"
```

### Test Falco Detection

```bash
# Execute shell in container (should trigger alert)
kubectl exec -it <pod-name> -- /bin/sh

# Access sensitive file (should trigger alert)
kubectl exec -it <pod-name> -- cat /etc/shadow
```

### List Loaded Rules

```bash
# List all rules
kubectl exec -n falco <falco-pod> -- falco --list-rules

# List rules by tag
kubectl exec -n falco <falco-pod> -- falco --list-rules -t container
```

## Integration

### Prometheus Integration

Falco can export metrics to Prometheus:

```yaml
# In values.yaml
metrics:
  enabled: true
  interval: 1m
```

### Webhook Integration

Send alerts to webhooks:

```yaml
# In values.yaml
webhook:
  enabled: true
  url: "https://your-webhook-url.com/alerts"
```

## Best Practices

### Rule Design

1. **Start with Defaults**: Use built-in rules first
2. **Tune for Your Environment**: Adjust rules to reduce false positives
3. **Test Rules**: Test rules before deploying
4. **Document Rules**: Explain why rules exist

### Common Rules

- Detect shell execution
- Monitor file access
- Detect privilege escalation
- Monitor network connections
- Detect process anomalies

## Troubleshooting

### Falco Not Detecting Events

```bash
# Check Falco pods are running
kubectl get pods -n falco

# Check Falco logs for errors
kubectl logs -n falco -l app=falco

# Verify rules are loaded
kubectl exec -n falco <falco-pod> -- falco --list-rules
```

### High False Positive Rate

```bash
# Review rules and adjust conditions
# Add exceptions for known good behavior
# Tune rule priorities
```

## Additional Resources

- [Falco Documentation](https://falco.org/docs/)
- [Falco Rules](https://github.com/falcosecurity/rules)
- [Falco Best Practices](https://falco.org/docs/rules/best-practices/)

