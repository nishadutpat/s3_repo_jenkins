provider "aws" {
  region = "us-east-1"
}

# IAM Role
resource "aws_iam_role" "s3_admin_role" {
  name = "S3AdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"  # Change this if used for Lambda, ECS, etc.
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach Administrator Policy to the Role
resource "aws_iam_policy_attachment" "admin_policy" {
  name       = "s3_admin_policy_attachment"
  roles      = [aws_iam_role.s3_admin_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# (Optional) Create an S3 Bucket
resource "aws_s3_bucket" "example_bucket" {
  bucket = "buckforjenkins"
}

# (Optional) Attach IAM Role to the S3 Bucket Policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.example_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = aws_iam_role.s3_admin_role.arn }
      Action    = "s3:*"
      Resource  = [
        "arn:aws:s3:::my-example-s3-bucket",
        "arn:aws:s3:::my-example-s3-bucket/*"
      ]
    }]
  })
}
