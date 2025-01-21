# AWS ECS Infrastructure with Terraform

This project provisions an AWS infrastructure for running containerized applications using ECS (Elastic Container Service) with Fargate.

## Infrastructure Components

- VPC with public and private subnets across 2 availability zones
- Application Load Balancer (ALB)
- ECS Cluster with Fargate
- CloudWatch Log Groups
- Security Groups
- IAM Roles and Policies

## Prerequisites

- Terraform >= 1.7.0
- AWS CLI configured with appropriate credentials
- AWS Account

## Project Structure
├── compute.tf # ECS, ALB and security group configurations 
├── networking.tf # VPC and subnet configurations 
├── outputs.tf # Infrastructure output values 
├── provider.tf # AWS provider configuration 
├── shared_locals.tf # Common local variables 
├── terraform.tfvars # Variable values 
└── variables.tf # Variable definitions


## Usage

1. Initialize Terraform:
```sh
terraform init
terraform plan
terraform apply
```

## Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| project_name | The name of the project | string | - |
| vpc_cidr | The CIDR block for the VPC | string | "10.0.0.0/16" |
| subnet_config | Map of subnet configurations | map(object) | See below |
| container_image | The container image for ECS service | string | - |
| ecs_cluster_name | Name of the ECS cluster | string | - |
| task_definition_family | Family name of task definition | string | - |
| ecs_service_name | Name of the ECS service | string | - |

### Default subnet_config

```hcl
{
  subnet1 = {
    cidr_block = "10.0.1.0/24"
    public     = true
  }
  subnet2 = {
    cidr_block = "10.0.2.0/24"
    public     = true
  }
  subnet3 = {
    cidr_block = "10.0.100.0/24"
    public     = false
  }
  subnet4 = {
    cidr_block = "10.0.101.0/24"
    public     = false
  }
}
```

## Outputs

| Output Name | Description |
|-------------|-------------|
| vpc_id | The ID of the created VPC |
| public_subnet_ids | List of IDs of public subnets |
| private_subnet_ids | List of IDs of private subnets |
| alb_dns_name | DNS name of the Application Load Balancer |
| ecs_cluster_name | Name of the created ECS cluster |
| ecs_service_name | Name of the created ECS service |
| cloudwatch_log_group | Name of the CloudWatch Log Group |
| task_definition_arn | ARN of the ECS Task Definition |