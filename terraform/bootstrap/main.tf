provider "aws" {
  region = "us-east-1"
  
  # Default tags applied to all resources created by this provider
  default_tags {
    tags = {
      Project     = "Cubic-Defense-Foundation"
      Environment = "Management"
      ManagedBy   = "Terraform"
      Owner       = "Eleonora Musaeva"
    }
  }
}

# 1. Create an S3 Bucket to store the Terraform state file securely
resource "aws_s3_bucket" "terraform_state" {
  bucket = "cubic-defense-tf-state-nora-8899" # IMPORTANT: Change these numbers to make it globally unique!

  # Prevent accidental deletion of this S3 bucket (Production best practice)
  lifecycle {
    prevent_destroy = true
  }
}

# Enable object versioning to keep a history of state files and recover from corruptions
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enforce Server-Side Encryption (SSE) by default - Critical for Defense/Gov compliance
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 2. Create a DynamoDB table for state locking to prevent concurrent team modifications
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "cubic-defense-tf-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}