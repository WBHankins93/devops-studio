#!/usr/bin/env python3
"""
Publish platform metrics to CloudWatch.
"""

import boto3
import json
from datetime import datetime
from typing import Dict, Any

cloudwatch = boto3.client('cloudwatch')

def publish_metric(namespace: str, metric_name: str, value: float, unit: str = "Count", dimensions: Dict[str, str] = None):
    """Publish a single metric to CloudWatch."""
    metric_data = {
        "MetricName": metric_name,
        "Value": value,
        "Unit": unit,
        "Timestamp": datetime.utcnow()
    }
    
    if dimensions:
        metric_data["Dimensions"] = [{"Name": k, "Value": v} for k, v in dimensions.items()]
    
    cloudwatch.put_metric_data(
        Namespace=namespace,
        MetricData=[metric_data]
    )

def publish_provisioning_metric(success: bool, duration: float = None):
    """Publish provisioning metrics."""
    namespace = "Platform"
    
    if success:
        publish_metric(namespace, "Provisioning.Success", 1.0)
    else:
        publish_metric(namespace, "Provisioning.Failure", 1.0)
    
    if duration:
        publish_metric(namespace, "Provisioning.Duration", duration, "Seconds")

def publish_api_metric(requests: int, errors: int = 0, latency: float = None):
    """Publish API metrics."""
    namespace = "Platform"
    
    publish_metric(namespace, "API.Requests", float(requests))
    
    if errors > 0:
        publish_metric(namespace, "API.Errors", float(errors))
    
    if latency:
        publish_metric(namespace, "API.Latency", latency, "Milliseconds")

def publish_resource_metric(count: int, cost: float = None):
    """Publish resource metrics."""
    namespace = "Platform"
    
    publish_metric(namespace, "Resources.Count", float(count))
    
    if cost:
        publish_metric(namespace, "Resources.Cost", cost, "None")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python publish_metrics.py <metric_type> [args...]")
        sys.exit(1)
    
    metric_type = sys.argv[1]
    
    if metric_type == "provisioning":
        success = sys.argv[2].lower() == "true"
        duration = float(sys.argv[3]) if len(sys.argv) > 3 else None
        publish_provisioning_metric(success, duration)
    elif metric_type == "api":
        requests = int(sys.argv[2])
        errors = int(sys.argv[3]) if len(sys.argv) > 3 else 0
        latency = float(sys.argv[4]) if len(sys.argv) > 4 else None
        publish_api_metric(requests, errors, latency)
    elif metric_type == "resource":
        count = int(sys.argv[2])
        cost = float(sys.argv[3]) if len(sys.argv) > 3 else None
        publish_resource_metric(count, cost)
    else:
        print(f"Unknown metric type: {metric_type}")
        sys.exit(1)
    
    print("Metric published successfully")

