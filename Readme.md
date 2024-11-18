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
├── main.tf
├── variables.tf
├── outputs.tf
├── README.md
└── modules/
   ├── vpc/
   ├── ecs/
   └── security-groups/
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

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
