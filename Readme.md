# Terraform ECS Project

This project sets up an Amazon ECS (Elastic Container Service) cluster using Terraform. The configuration includes creating the necessary infrastructure components such as VPC, subnets, security groups, ECS cluster, and task definitions.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) v1.0.0 or later
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate permissions
- [Docker](https://www.docker.com/products/docker-desktop) (optional, for building container images)

## Project Structure

```
/home/laura/tests/terraform-ecs/
├── compute.tf
├── externaldns.tf
├── networking.tf
├── provider.tf
├── shared_locals.tf
├── terraform.tfvars
├── variables.tf
├── outputs.tf
├── README.md
```

## Getting Started

1. **Clone the repository:**

   ```sh
   git clone https://github.com/yourusername/terraform-ecs.git
   cd terraform-ecs
   ```

2. **Initialize Terraform:**

   ```sh
   terraform init
   ```

3. **Review and modify variables:**

   Edit the `variables.tf` file to customize the configuration according to your requirements.

4. **Plan the infrastructure:**

   ```sh
   terraform plan
   ```

5. **Apply the configuration:**

   ```sh
   terraform apply
   ```

   Type `yes` when prompted to confirm the changes.

## Components

### VPC

The VPC module sets up a Virtual Private Cloud with public and private subnets across multiple availability zones.

### ECS

The ECS module creates an ECS cluster, task definitions, and services to run your containerized applications.

### Security Groups

The Security Groups module defines the necessary security groups to control inbound and outbound traffic to your ECS services.

## External DNS Service

The external DNS service is set up using the `externaldns.tf` file. This file contains the necessary resources and configurations to manage DNS records for your ECS services.

### Purpose

The `externaldns.tf` file is responsible for setting up the external DNS service, which automatically updates DNS records based on the state of your ECS services. This ensures that your services are always accessible via their domain names.

### Step-by-Step Instructions

1. **Review and modify variables:**

   Edit the `variables.tf` file to customize the external DNS configuration according to your requirements. Pay attention to the following variables:

   - `external_dns_image`: The container image to use for the external DNS service.
   - `external_dns_domain_filter`: The domain filter for the external DNS service.
   - `ecs_cluster_name`: The name of the ECS cluster.

2. **Apply the configuration:**

   ```sh
   terraform apply
   ```

   Type `yes` when prompted to confirm the changes.

### Required Variables

The following variables are required for the external DNS service:

- `external_dns_image`: The container image to use for the external DNS service.
- `external_dns_domain_filter`: The domain filter for the external DNS service.
- `ecs_cluster_name`: The name of the ECS cluster.

### Dependencies

The external DNS service depends on the following resources:

- ECS cluster: The external DNS service must be deployed in the same ECS cluster as your other services.
- VPC: The external DNS service requires a VPC with private subnets for its network configuration.

## Outputs

After applying the Terraform configuration, you can view the outputs using:

```sh
terraform output
```

This will display important information such as the ECS cluster name, VPC ID, and other relevant details.

## Cleanup

To destroy the infrastructure created by Terraform, run:

```sh
terraform destroy
```

Type `yes` when prompted to confirm the destruction.

## License

This project is licensed under the GNU General Public License. See the [LICENSE](LICENSE) file for details.
