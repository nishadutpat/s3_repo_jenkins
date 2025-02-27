provider "aws" {
  region = "us-east-1"
}

# IAM Role for EC2
resource "aws_iam_role" "s3_admin_role" {
  name = "S3AdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach Administrator Policy to the Role
resource "aws_iam_role_policy_attachment" "admin_policy" {
  role       = aws_iam_role.s3_admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Create IAM Instance Profile and Attach to EC2
resource "aws_iam_instance_profile" "s3_admin_profile" {
  name = "s3_admin_profile"
  role = aws_iam_role.s3_admin_role.name
}

# S3 Bucket
resource "aws_s3_bucket" "example_bucket" {
  bucket = "buckforjenkins"
}

# Attach IAM Role to the S3 Bucket Policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.example_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { AWS = aws_iam_role.s3_admin_role.arn }
      Action    = "s3:*"
      Resource  = [
        "arn:aws:s3:::buckforjenkins",
        "arn:aws:s3:::buckforjenkins/*"
      ]
    }]
  })
}
