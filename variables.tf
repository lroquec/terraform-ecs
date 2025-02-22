variable "project_name" {
  description = "The name of the project"
  type        = string

}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "The VPC CIDR block is not a valid CIDR block"
  }
}

variable "subnet_config" {
  type = map(object({
    cidr_block = string
    public     = optional(bool, false)
  }))

  default = {
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

  validation {
    condition = alltrue([
      for config in values(var.subnet_config) : can(cidrnetmask(config.cidr_block))
    ])
    error_message = "The cidr_block config option must contain a valid CIDR block."
  }
}

variable "container_image" {
  description = "The container image to use for the ECS service"
  type        = string

}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  type        = string

}

variable "task_definition_family" {
  description = "The family name of the task definition"
  type        = string
}

variable "ecs_service_name" {
  description = "The name of the ECS service"
  type        = string

}

variable "container_port" {
  description = "The port the container listens on"
  type        = number
}