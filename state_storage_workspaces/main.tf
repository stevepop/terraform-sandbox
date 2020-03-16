provider "aws" {
    region = "eu-west-2"
}

resource "aws_instance" "tac_example" {
    ami = "ami-0a590332f9f499197"
    instance_type ="t2.micro"
}


resource "aws_s3_bucket" "accountancycloud-terraform-state" {
  bucket = "accountancycloud-terraform-state"

  force_destroy = true

  # Enable versioning so we can see the full revision history of our state files
  versioning {
      enabled = true
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
      rule {
          apply_server_side_encryption_by_default {
              sse_algorithm = "AES256"
          }
      }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
    name = "tac-db-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}

terraform {
    backend "s3" {
        bucket = "accountancycloud-terraform-state"
        key = "workspaces-tac/s3/terraform.tfstate"
        region = "eu-west-2"
        dynamodb_table = "tac-db-locks"
        encrypt = true
    }
}

output "s3_bucket_arn" {
  value = "aws_s3_bucket.terraform_state.arn"
  description = "The ARN of the S3 bucket"
}


output "dynamodb_table_name" {
  value = "aws_s3_bucket.terraform_state.arn"
  description = "The name of the DynamoDB table"
}


