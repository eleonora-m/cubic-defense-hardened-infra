terraform {
  backend "s3" {
    # The name of the S3 bucket we created in the bootstrap phase
    bucket = "cubic-defense-tf-state-nora-8899"

    # The path and name of the state file INSIDE the bucket
    key = "core/terraform.tfstate"

    # The AWS region
    region = "us-east-1"

    # Ensures the state file is encrypted at rest
    encrypt = true

    # The DynamoDB table we created for state locking
    dynamodb_table = "cubic-defense-tf-locks"
  }
}