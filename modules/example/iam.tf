# ---------------------------------------------------------------------------
# Shared assume-role policy document
# ---------------------------------------------------------------------------
data "aws_iam_policy_document" "ecr_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [var.trusted_principal]
    }
  }
}

# ---------------------------------------------------------------------------
# ECR Writer Role
# Grants full push access to all ECR repositories in the account.
# ---------------------------------------------------------------------------
resource "aws_iam_role" "ecr_writer" {
  name               = "${var.project_name}-${var.environment}-ecr-writer"
  assume_role_policy = data.aws_iam_policy_document.ecr_assume_role.json
  description        = "Allows the trusted principal to push images to ECR."
}

data "aws_iam_policy_document" "ecr_writer" {
  # Token required by the Docker CLI before any registry operation
  statement {
    sid     = "GetAuthToken"
    effect  = "Allow"
    actions = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  # Push (write) permissions scoped to all repositories
  statement {
    sid    = "PushImages"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
    resources = ["arn:aws:ecr:${var.aws_region}:*:repository/*"]
  }

  # Read-only repository metadata (useful for CI tooling)
  statement {
    sid    = "DescribeRepositories"
    effect = "Allow"
    actions = [
      "ecr:DescribeRepositories",
      "ecr:ListImages",
    ]
    resources = ["arn:aws:ecr:${var.aws_region}:*:repository/*"]
  }
}

resource "aws_iam_role_policy" "ecr_writer" {
  name   = "ecr-writer-policy"
  role   = aws_iam_role.ecr_writer.id
  policy = data.aws_iam_policy_document.ecr_writer.json
}

# ---------------------------------------------------------------------------
# ECR Read-Only Role
# Grants pull-only access to all ECR repositories in the account.
# ---------------------------------------------------------------------------
resource "aws_iam_role" "ecr_read_only" {
  name               = "${var.project_name}-${var.environment}-ecr-read-only"
  assume_role_policy = data.aws_iam_policy_document.ecr_assume_role.json
  description        = "Allows the trusted principal to pull images from ECR."
}

data "aws_iam_policy_document" "ecr_read_only" {
  # Token required by the Docker CLI before any registry operation
  statement {
    sid       = "GetAuthToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  # Pull (read) permissions
  statement {
    sid    = "PullImages"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]
    resources = ["arn:aws:ecr:${var.aws_region}:*:repository/*"]
  }

  # Read-only repository metadata
  statement {
    sid    = "DescribeRepositories"
    effect = "Allow"
    actions = [
      "ecr:DescribeRepositories",
      "ecr:ListImages",
    ]
    resources = ["arn:aws:ecr:${var.aws_region}:*:repository/*"]
  }
}

resource "aws_iam_role_policy" "ecr_read_only" {
  name   = "ecr-read-only-policy"
  role   = aws_iam_role.ecr_read_only.id
  policy = data.aws_iam_policy_document.ecr_read_only.json
}
