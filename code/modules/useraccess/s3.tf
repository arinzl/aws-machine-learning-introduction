locals {
  account_id = data.aws_caller_identity.current.account_id
}

module "artifact_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.11.0"


  bucket = "${var.app_name}-artifact-${local.account_id}"


  versioning = {
    enabled = false
  }

}

resource "aws_s3_bucket_policy" "artifact_bucket_policy" {

  bucket = module.artifact_bucket.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "pipeline-artifact-access"
        Effect = "Allow"
        Principal = {
          "AWS" = "arn:aws:iam::${local.account_id}:root"
        }
        Action = [
          "s3:*",
        ]
        Resource = [
          "arn:aws:s3:::${module.artifact_bucket.s3_bucket_id}",
          "arn:aws:s3:::${module.artifact_bucket.s3_bucket_id}/*"
        ]
      },
    ]
  })
}


resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = module.artifact_bucket.s3_bucket_id

  rule {
    id = "rule-1"

    abort_incomplete_multipart_upload {
      days_after_initiation = 6
    }

    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = module.artifact_bucket.s3_bucket_id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.demo_kms_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
