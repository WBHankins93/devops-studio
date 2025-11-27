#!/usr/bin/env python3
"""
Terraform Runner
Executes Terraform plans and applies for service provisioning.
"""

import os
import sys
import json
import subprocess
import boto3
from pathlib import Path
from typing import Dict, Any

class TerraformRunner:
    def __init__(self, workspace: str, template_path: str, state_bucket: str, state_table: str):
        self.workspace = workspace
        self.template_path = template_path
        self.state_bucket = state_bucket
        self.state_table = state_table
        self.work_dir = Path(f"/tmp/terraform-workspaces/{workspace}")
        
    def setup_workspace(self):
        """Create isolated workspace directory."""
        self.work_dir.mkdir(parents=True, exist_ok=True)
        
        # Copy template to workspace
        subprocess.run(["cp", "-r", f"{self.template_path}/*", str(self.work_dir)], check=True)
        
        # Create backend configuration
        backend_config = f"""
terraform {{
  backend "s3" {{
    bucket         = "{self.state_bucket}"
    key            = "{self.workspace}/terraform.tfstate"
    region         = "{os.environ.get('AWS_REGION', 'us-west-2')}"
    dynamodb_table = "{self.state_table}"
    encrypt        = true
  }}
}}
"""
        (self.work_dir / "backend.tf").write_text(backend_config)
        
    def init(self):
        """Initialize Terraform workspace."""
        subprocess.run(
            ["terraform", "init"],
            cwd=self.work_dir,
            check=True
        )
        
    def plan(self, variables: Dict[str, Any]) -> Dict[str, Any]:
        """Generate Terraform plan."""
        # Write variables to tfvars file
        tfvars_content = "\n".join([f'{k} = "{v}"' for k, v in variables.items()])
        (self.work_dir / "terraform.tfvars").write_text(tfvars_content)
        
        # Run terraform plan
        result = subprocess.run(
            ["terraform", "plan", "-out=tfplan", "-json"],
            cwd=self.work_dir,
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            raise Exception(f"Terraform plan failed: {result.stderr}")
            
        return {
            "status": "planned",
            "plan_file": str(self.work_dir / "tfplan"),
            "output": result.stdout
        }
        
    def apply(self, plan_file: str = None) -> Dict[str, Any]:
        """Apply Terraform plan."""
        if plan_file:
            cmd = ["terraform", "apply", plan_file]
        else:
            cmd = ["terraform", "apply", "-auto-approve"]
            
        result = subprocess.run(
            cmd,
            cwd=self.work_dir,
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            raise Exception(f"Terraform apply failed: {result.stderr}")
            
        # Get outputs
        output_result = subprocess.run(
            ["terraform", "output", "-json"],
            cwd=self.work_dir,
            capture_output=True,
            text=True
        )
        
        outputs = json.loads(output_result.stdout) if output_result.returncode == 0 else {}
        
        return {
            "status": "applied",
            "outputs": outputs,
            "output": result.stdout
        }
        
    def destroy(self) -> Dict[str, Any]:
        """Destroy Terraform resources."""
        result = subprocess.run(
            ["terraform", "destroy", "-auto-approve"],
            cwd=self.work_dir,
            capture_output=True,
            text=True
        )
        
        if result.returncode != 0:
            raise Exception(f"Terraform destroy failed: {result.stderr}")
            
        return {
            "status": "destroyed",
            "output": result.stdout
        }

def main():
    """CLI entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(description="Terraform Runner")
    parser.add_argument("command", choices=["plan", "apply", "destroy"])
    parser.add_argument("--workspace", required=True)
    parser.add_argument("--template", required=True)
    parser.add_argument("--state-bucket", required=True)
    parser.add_argument("--state-table", required=True)
    parser.add_argument("--variables", type=json.loads, default="{}")
    
    args = parser.parse_args()
    
    runner = TerraformRunner(
        workspace=args.workspace,
        template_path=args.template,
        state_bucket=args.state_bucket,
        state_table=args.state_table
    )
    
    runner.setup_workspace()
    runner.init()
    
    if args.command == "plan":
        result = runner.plan(args.variables)
    elif args.command == "apply":
        result = runner.apply()
    elif args.command == "destroy":
        result = runner.destroy()
        
    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()

