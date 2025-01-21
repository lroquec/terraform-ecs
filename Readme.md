# AWS ECS Infrastructure with Terraform

This project provisions an AWS infrastructure for running containerized applications using ECS (Elastic Container Service) with Fargate. It sets up a complete production-ready environment with proper networking, security, and monitoring configurations.

## Infrastructure Components

- VPC with public and private subnets across multiple availability zones
- Application Load Balancer (ALB) with HTTP listener
- ECS Cluster running on Fargate
- CloudWatch Log Groups for container logs
- Security Groups for ALB and container traffic
- IAM Roles and Policies for ECS tasks
- Route53 DNS configuration
- Health checks and container monitoring

## Prerequisites

- Terraform >= 1.7.0
- AWS CLI configured with appropriate credentials
- AWS Account
- Domain registered in Route53 (currently configured for lroquec.com)

## Project Structure

```
├── compute.tf         # ECS, ALB, security groups, and Route53 configurations
├── networking.tf      # VPC and subnet configurations using AWS VPC module
├── outputs.tf         # Infrastructure output values
├── provider.tf        # AWS provider and terraform configuration
├── shared_locals.tf   # Common local variables
├── terraform.tfvars   # Variable values
└── variables.tf       # Variable definitions with validations
```

## Usage

1. Clone the repository
2. Update terraform.tfvars with your desired values
3. Initialize and apply the Terraform configuration:

```sh
terraform init
terraform plan
terraform apply
```

## Required Variables (terraform.tfvars)

| Name | Description | Example Value |
|------|-------------|---------------|
| project_name | Name prefix for all resources | "testing-ground" |
| container_image | Docker image to deploy | "lroquec/cicd-tests:latest" |
| ecs_cluster_name | Name of the ECS cluster | "myECSCluster" |
| task_definition_family | Family name for task definition | "myflaskApp" |
| ecs_service_name | Name of the ECS service | "myflaskapp" |
| container_port | Port exposed by the container | 5000 |

## Network Configuration

The infrastructure uses a VPC module with the following setup:
- CIDR: 10.0.0.0/16 (configurable)
- 2 public subnets for ALB
- 2 private subnets for ECS tasks
- NAT Gateway for private subnet internet access
- Internet Gateway for public subnets

Default subnet configuration:
```hcl
subnet_config = {
  subnet1 = { cidr_block = "10.0.1.0/24", public = true }
  subnet2 = { cidr_block = "10.0.2.0/24", public = true }
  subnet3 = { cidr_block = "10.0.100.0/24", public = false }
  subnet4 = { cidr_block = "10.0.101.0/24", public = false }
}
```

## Security

- ALB security group allows inbound HTTP (port 80) from anywhere
- Container security group only allows traffic from ALB
- Both security groups allow all outbound traffic
- ECS tasks run with minimal IAM permissions (ECR and CloudWatch logs)

## Monitoring and Logs

- Container logs are sent to CloudWatch Logs
- Log retention period: 7 days
- Container health checks configured with:
  - Interval: 30 seconds
  - Timeout: 5 seconds
  - Retries: 3
  - Start period: 60 seconds

## Outputs

| Name | Description |
|------|-------------|
| vpc_cidr | The VPC ID |
| first_public_subnet_id | ID of the first public subnet |
| alb_dns_name | DNS name of the Application Load Balancer |
| dns_name | Full DNS name for the service (format: {service_name}.lroquec.com) |

## Resource Specifications

- ECS Task Definition:
  - CPU: 256 units
  - Memory: 512 MB
  - Network Mode: awsvpc
  - Launch Type: FARGATE

- Service Configuration:
  - Desired Count: 1
  - Platform Version: LATEST
  - Deployment Circuit Breaker: Enabled

## Tags

All resources are tagged with:
- CreatedBy: lroquec
- Owner: DevOps Team
- env: dev
- managedby: Terraform