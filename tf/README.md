# Wiz Tech Exercise - Terraform

This repository contains a modular Terraform layout to deploy the Wiz exercise environment on AWS.
Structure:
- Root contains reusable modules and environment-agnostic orchestration files.
- `env/<env>` contains `terraform.tfvars` and backend/provider overrides per environment.

How to use:
1. cd tf
2. terraform init -backend-config=env/prod/backend_override.tf
3. terraform workspace new prod || terraform workspace select prod
4. terraform plan -var-file=env/prod/terraform.tfvars
5. terraform apply -var-file=env/prod/terraform.tfvars

Notes:
- The EC2 module intentionally creates a publicly SSH-accessible VM and an overly permissive IAM policy (exercise requirement). Do NOT use this in production.
- Replace the `locals.outdated_ami_id` constant with an actual outdated AMI id for your target region before apply.
