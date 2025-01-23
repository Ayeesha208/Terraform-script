#Terraform script to create apprunner service ( for cross account in AWS):
# Provider for the source account
provider "aws" {
  profile = "source-account"  # Ensure this profile is configured in your AWS credentials file
  region  = "ap-south-1"
}
# Provider for the target account
provider "aws" {
  alias   = "target"  # Alias for distinguishing target account
  profile = "target-account"  # Ensure this profile is configured in your AWS credentials file
  region  = "ap-south-1"
}
# 1. Source Account: IAM Role for Cross-Account ECR Access
resource "aws_iam_role" "cross_account_ecr_role" {
  provider = aws
  name     = "cross-account-ecr-role"
 
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::590183857776:root"  # Target account's ARN
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
} 
# 2. Source Account: Attach Permissions to the Role
resource "aws_iam_role_policy" "ecr_access_policy" {
  provider = aws
  name     = "allow-ecr-access"
  role     = aws_iam_role.cross_account_ecr_role.id
 
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories"
        ],
        Resource = "arn:aws:ecr:ap-south-1:662378284496:repository/test"
      }
    ]
  })
} 
# 3. Target Account: IAM Role for App Runner
resource "aws_iam_role" "apprunner_role" {
  provider = aws.target
  name     = "apprunner-execution-role"
 
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
 
# 4. Target Account: Attach a Policy to the IAM Role to Allow Access to the Cross-Account ECR
resource "aws_iam_role_policy" "apprunner_policy" {
  provider = aws.target
  name     = "cross_account_ecr_pull_policy"
  role     = aws_iam_role.apprunner_role.id
 
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sts:AssumeRole"
        ],
        Resource = "arn:aws:iam::662378284496:role/cross-account-ecr-role"  # Source account role
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
      }
    ]
  })
}
 
# 5. Target Account: Reference the external ECR repository and image (from source account)
data "aws_ecr_repository" "test" {
  provider = aws  # Use the source account provider
  name     = "test"  # The repository name in the source account
}
 
data "aws_ecr_image" "test" {
  provider        = aws  # Use the source account provider
  repository_name = data.aws_ecr_repository.test.name
  image_tag       = "latest"  # Change if using another tag
}
 
# 6. Target Account: AWS App Runner Service
resource "aws_apprunner_service" "my_apprunner" {
  provider     = aws.target
  service_name = "my_apprunner"
 
  source_configuration {
    image_repository {
      image_identifier      = "${data.aws_ecr_repository.test.repository_url}@${data.aws_ecr_image.test.image_digest}"
      image_repository_type = "ECR"
 
      image_configuration {
        port = 5000  # Adjust based on your app's configuration
      }
    }
 
    auto_deployments_enabled = false
 
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_role.arn  # Correct ARN for App Runner access
    }
  }
 
  instance_configuration {
    cpu    = "1024"
    memory = "2048"
  }
 
  tags = {
    Environment = "production"
    Project     = "AppRunner"
  }
 
  depends_on = [aws_iam_role.apprunner_role]
} 
# 7. Output block to display the App Runner service URL
output "apprunner_service_url" {
  value = aws_apprunner_service.my_apprunner.service_url
}
