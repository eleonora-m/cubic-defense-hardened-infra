# ------------------------------------------------------
# 1. Global Project Variables
# ------------------------------------------------------

variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "The name of the environment (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

# ------------------------------------------------------
# 2. Network (VPC) Variables for Cubic Defense
# ------------------------------------------------------

variable "vpc_cidr" {
  description = "The main CIDR block for the entire VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets (accessible from the internet)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets (internal use only)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}
