# app-integration / dev — Terraform Example

This Terraform configuration provisions a minimal but production-ready AWS environment for the `app-integration` project in the `dev` environment.

## What it creates

| Resource | Description |
|---|---|
| `aws_iam_role.ecr_writer` | IAM role that allows a trusted AWS service principal to **push** Docker images to ECR |
| `aws_iam_role.ecr_read_only` | IAM role that allows a trusted AWS service principal to **pull** Docker images from ECR |
| `aws_s3_bucket.main` | S3 bucket with a randomly generated name (`<project>-<env>-<adjective>-<animal>`) |
| `aws_s3_bucket_versioning` | Versioning enabled on the S3 bucket |
| `aws_s3_bucket_server_side_encryption_configuration` | AES-256 server-side encryption on the S3 bucket |
| `aws_s3_bucket_public_access_block` | All public access blocked on the S3 bucket |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with credentials that have permission to create IAM roles and S3 buckets
- An AWS account with ECR enabled in the target region

## File layout

```
dev/
├── main.tf        # Terraform + AWS + random provider configuration
├── variables.tf   # Input variable declarations
├── outputs.tf     # Output value declarations
├── iam.tf         # IAM roles and inline policies for ECR
├── s3.tf          # S3 bucket with random name, versioning, and encryption
└── README.md      # This file
```

## Usage

### 1. Initialise

Download the required provider plugins:

```bash
terraform init
```

### 2. Review the plan

Preview what Terraform will create (no changes are made at this step):

```bash
terraform plan
```

To override any default variable inline:

```bash
terraform plan \
  -var="aws_region=us-east-1" \
  -var="trusted_principal=ecs-tasks.amazonaws.com"
```

### 3. Apply

Create the resources:

```bash
terraform apply
```

Terraform will display a summary of changes and prompt for confirmation before proceeding.

### 4. Destroy

To tear down all resources created by this configuration:

```bash
terraform destroy
```

> **Note:** The S3 bucket must be empty before it can be destroyed. Empty it manually or add a lifecycle rule before running `destroy`.

## Variables

| Name | Type | Default | Description |
|---|---|---|---|
| `aws_region` | `string` | `"eu-west-1"` | AWS region to deploy resources into |
| `project_name` | `string` | `"app-integration"` | Short project name — used as a prefix in resource names and tags |
| `environment` | `string` | `"dev"` | Deployment environment (e.g. `dev`, `staging`, `prod`) |
| `trusted_principal` | `string` | `"ec2.amazonaws.com"` | AWS service principal allowed to assume the ECR IAM roles |

### Common values for `trusted_principal`

| Use case | Value |
|---|---|
| EC2 instances | `ec2.amazonaws.com` |
| ECS tasks (Fargate / EC2) | `ecs-tasks.amazonaws.com` |
| Lambda functions | `lambda.amazonaws.com` |
| CodeBuild projects | `codebuild.amazonaws.com` |

## Outputs

| Name | Description |
|---|---|
| `s3_bucket_name` | The generated name of the S3 bucket |
| `s3_bucket_arn` | The ARN of the S3 bucket |
| `ecr_writer_role_arn` | ARN of the IAM role with ECR push access |
| `ecr_writer_role_name` | Name of the IAM role with ECR push access |
| `ecr_read_only_role_arn` | ARN of the IAM role with ECR pull access |
| `ecr_read_only_role_name` | Name of the IAM role with ECR pull access |

View outputs after applying:

```bash
terraform output
```

Or retrieve a single value:

```bash
terraform output ecr_writer_role_arn
```

## IAM permissions summary

### ECR Writer role (`ecr_writer`)

| Action | Scope |
|---|---|
| `ecr:GetAuthorizationToken` | `*` (registry-level — required by Docker CLI) |
| `ecr:BatchCheckLayerAvailability` | All repositories |
| `ecr:InitiateLayerUpload` | All repositories |
| `ecr:UploadLayerPart` | All repositories |
| `ecr:CompleteLayerUpload` | All repositories |
| `ecr:PutImage` | All repositories |
| `ecr:DescribeRepositories` | All repositories |
| `ecr:ListImages` | All repositories |

### ECR Read-Only role (`ecr_read_only`)

| Action | Scope |
|---|---|
| `ecr:GetAuthorizationToken` | `*` (registry-level — required by Docker CLI) |
| `ecr:BatchCheckLayerAvailability` | All repositories |
| `ecr:GetDownloadUrlForLayer` | All repositories |
| `ecr:BatchGetImage` | All repositories |
| `ecr:DescribeRepositories` | All repositories |
| `ecr:ListImages` | All repositories |

> To scope the ECR policies to specific repositories, replace the `resources` wildcard (`arn:aws:ecr:<region>:*:repository/*`) with explicit repository ARNs.

## Tags

All resources receive the following tags automatically via the provider `default_tags` block:

| Tag key | Value |
|---|---|
| `Project` | Value of `var.project_name` |
| `Environment` | Value of `var.environment` |
| `ManagedBy` | `Terraform` |
