# Official AWS VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.0" # Always pin the module version for stability

  name = "cubic-defense-vpc-${var.environment}"
  cidr = var.vpc_cidr

  # Deploy across two Availability Zones for High Availability (HA)
  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  # Enable NAT Gateway for private subnets to access the internet securely
  enable_nat_gateway = true
  # Use a single NAT gateway to save costs in Dev environment (FinOps best practice)
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Security and Routing Tags
  public_subnet_tags = {
    "Tier" = "Public"
    "Role" = "LoadBalancers-and-Bastions"
  }

  private_subnet_tags = {
    "Tier" = "Private"
    "Role" = "Mission-Critical-Apps-and-DBs"
  }
}