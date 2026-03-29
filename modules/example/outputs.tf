output "s3_bucket_name" {
  description = "The name of the randomly generated S3 bucket."
  value       = aws_s3_bucket.main.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.main.arn
}

output "ecr_writer_role_arn" {
  description = "ARN of the IAM role that grants ECR push (write) access."
  value       = aws_iam_role.ecr_writer.arn
}

output "ecr_writer_role_name" {
  description = "Name of the IAM role that grants ECR push (write) access."
  value       = aws_iam_role.ecr_writer.name
}

output "ecr_read_only_role_arn" {
  description = "ARN of the IAM role that grants ECR pull (read-only) access."
  value       = aws_iam_role.ecr_read_only.arn
}

output "ecr_read_only_role_name" {
  description = "Name of the IAM role that grants ECR pull (read-only) access."
  value       = aws_iam_role.ecr_read_only.name
}
