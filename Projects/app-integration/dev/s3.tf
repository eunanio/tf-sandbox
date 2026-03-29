# ---------------------------------------------------------------------------
# Random suffix ensures a globally unique bucket name on every apply.
# The keeper ties re-generation to the project name so the name is stable
# across plan/apply cycles unless the project name changes.
# ---------------------------------------------------------------------------
resource "random_pet" "bucket_suffix" {
  length    = 2
  separator = "-"

  keepers = {
    project = var.project_name
  }
}

# ---------------------------------------------------------------------------
# S3 Bucket
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "main" {
  bucket = "${var.project_name}-${var.environment}-${random_pet.bucket_suffix.id}"

  # Prevent accidental deletion in all environments
  lifecycle {
    prevent_destroy = false
  }
}

# Block all public access — explicitly deny any public ACL or policy
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning so object history is retained
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption using AWS-managed keys (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}
