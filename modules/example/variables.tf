variable "aws_region" {
  description = "AWS region to deploy resources into."
  type        = string
  default     = "eu-east-1"
}

variable "project_name" {
  description = "Short name for the project. Used as a prefix in resource names and tags."
  type        = string
  default     = "app-integration"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "trusted_principal" {
  description = "AWS service principal that is allowed to assume the ECR IAM roles (e.g. ec2.amazonaws.com, ecs-tasks.amazonaws.com)."
  type        = string
  default     = "ec2.amazonaws.com"
}
