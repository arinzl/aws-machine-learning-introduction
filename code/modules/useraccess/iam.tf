#------------------------------------------------------------------------------
#  Role for Codebuild to create artifacts
#------------------------------------------------------------------------------

resource "aws_iam_role" "codebuild" {
  name = "${var.app_name}-codebuild-role"

  assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": "sts:AssumeRole",
                "Principal": {
                    "Service": "codebuild.amazonaws.com"
                }
            }
        ]
    }
    EOF
}


resource "aws_iam_role_policy" "codebuild" {
  name = "${var.app_name}-codebuild-policy"
  role = aws_iam_role.codebuild.name

  policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateNetworkInterface",
                    "ec2:DescribeDhcpOptions",
                    "ec2:DescribeNetworkInterfaces",
                    "ec2:DeleteNetworkInterface",
                    "ec2:DescribeSubnets",
                    "ec2:DescribeSecurityGroups",
                    "ec2:DescribeVpcs"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateNetworkInterfacePermission"
                ],
                "Resource": "*",
                "Condition": {
                    "StringEquals": {
                        "ec2:Subnet": [
                            "${module.codebuild_vpc.private_subnet_arns[0]}"
                        ],
                        "ec2:AuthorizedService": "codebuild.amazonaws.com"
                    }
                }
            },
            {
                "Effect": "Allow",
                "Action": [
                    "s3:*"
                ],
                "Resource": [
                    "${module.artifact_bucket.s3_bucket_arn}",
                    "${module.artifact_bucket.s3_bucket_arn}/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "kms:*"
                ],
                "Resource": "${aws_kms_key.demo_kms_key.arn}"
            }
        ]
    }
  EOF
}

#------------------------------------------------------------------------------
#  Role for CodePipeline
#------------------------------------------------------------------------------

resource "aws_iam_role" "codepipeline" {
  name = "${var.app_name}-pipeline-role"

  assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "codepipeline.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
}


resource "aws_iam_role_policy" "codepipeline_role_policy" {
  name = "${var.app_name}-pipeline-policy"
  role = aws_iam_role.codepipeline.id

  policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "ReadRepoAndContents",
                "Effect": "Allow",
                "Action": [
                    "codecommit:GetBranch",
                    "codecommit:GetCommit",
                    "codecommit:GetUploadArchiveStatus",
                    "codecommit:UploadArchive"
                ],
                "Resource": "${aws_codecommit_repository.lambda_repo.arn}"
            },
            {
                "Sid" : "CodeBuildActivities",
                "Effect": "Allow",
                "Action": [
                    "codebuild:BatchGetBuilds",
                    "codebuild:StartBuild"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateNetworkInterface",
                    "ec2:DescribeDhcpOptions",
                    "ec2:DescribeNetworkInterfaces",
                    "ec2:DeleteNetworkInterface",
                    "ec2:DescribeSubnets",
                    "ec2:DescribeSecurityGroups",
                    "ec2:DescribeVpcs"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateNetworkInterfacePermission"
                ],
                "Resource": "*",
                "Condition": {
                    "StringEquals": {
                        "ec2:Subnet": [
                            "${module.codebuild_vpc.private_subnet_arns[0]}"
                        ],
                        "ec2:AuthorizedService": "codebuild.amazonaws.com"
                    }
                }
            },
                        {
                "Effect": "Allow",
                "Action": [
                    "s3:*"
                ],
               "Resource": [
                    "${module.artifact_bucket.s3_bucket_arn}",
                    "${module.artifact_bucket.s3_bucket_arn}/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "kms:*"
                ],
                "Resource": "${aws_kms_key.demo_kms_key.arn}"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "cloudformation:CreateChangeSet",
                    "cloudformation:DeleteChangeSet",
                    "cloudformation:DescribeChangeSet",
                    "cloudformation:DescribeStacks",
                    "cloudformation:ExecuteChangeSet"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "iam:PassRole"
                ],
                "Resource": "${aws_iam_role.cloudformation.arn}"
            }
        ]
    }
    EOF
}

#------------------------------------------------------------------------------
#  Role for lambda Execution Role
#------------------------------------------------------------------------------


resource "aws_iam_role" "lambda" {
  name = "${var.app_name}-lambda-role"

  assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Principal": {
                    "Service": "lambda.amazonaws.com"
                },
                "Action": "sts:AssumeRole",
                "Effect": "Allow"
            }
        ]
    }
    EOF
}


resource "aws_iam_role_policy" "lambda_role_policy" {
  name = "${var.app_name}-lambda-policy"
  role = aws_iam_role.lambda.id

  policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "LambdaCloudwatchLogging",
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ],
                "Resource": "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.app_name}:*"
            },
            {
                "Sid": "EndpointInference",
                "Effect" : "Allow",
                "Action" : [
                    "SageMaker:InvokeEndpoint"
                ],
                "Resource" : "*"
            }
        ]
    }
    EOF
}

#------------------------------------------------------------------------------
#  Role for cloudwatch to trigger pipeline after repo commit
#------------------------------------------------------------------------------

resource "aws_iam_role" "cloudwatchtrigger" {
  name = "${var.app_name}-cloudwatch-pipeline-trigger-role"

  assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": "events.amazonaws.com"
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
    EOF
}

resource "aws_iam_role_policy" "trigger" {
  name = "${var.app_name}-pipeline-trigger-policy"
  role = aws_iam_role.cloudwatchtrigger.id

  policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect":"Allow",
                "Action": [
                   "codepipeline:StartPipelineExecution"
                ],
                "Resource": [
                    "${aws_codepipeline.app_pipeline.arn}"
                ]
            }
        ]
    }
    EOF
}


resource "aws_iam_role" "cloudformation" {
  name = "${var.app_name}-cloudformation-role"

  assume_role_policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Principal": {
                    "Service": "cloudformation.amazonaws.com"
                },
                "Action": "sts:AssumeRole",
                "Effect": "Allow"
            }
        ]
    }
    EOF
}

resource "aws_iam_role_policy" "cloudformation" {
  name = "${var.app_name}-cloudformation-policy"
  role = aws_iam_role.cloudformation.id

  policy = <<-EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Resource": "arn:aws:logs:*:*:*",
                "Action": "logs:*",
                "Effect": "Allow"                
            },
            {
                "Resource": [
                    "${module.artifact_bucket.s3_bucket_arn}",
                    "${module.artifact_bucket.s3_bucket_arn}/*"
                ],
                "Action": [
                    "s3:GetObject",
                    "s3:GetObjectVersion",
                    "s3:GetBucketVersioning",
                    "s3:PutObject"
                ],
                "Effect": "Allow"
            },
            {
                "Resource": "arn:aws:lambda:*",
                "Action": [
                    "lambda:*"
                ],
                "Effect": "Allow"
            },
            {
                "Resource": "arn:aws:apigateway:ap-southeast-2::*",
                "Action": [
                    "apigateway:*"
                ],
                "Effect": "Allow"
            },
            {
                "Resource": "arn:aws:iam:::*",
                "Action": [
                    "iam:AttachRolePolicy",
                    "iam:DeleteRolePolicy",
                    "iam:DetachRolePolicy",
                    "iam:GetRole",
                    "iam:CreateRole",
                    "iam:DeleteRole",
                    "iam:PutRolePolicy"
                ],
                "Effect": "Allow"
            },
            {
                "Resource": "*",
                "Action": [
                    "iam:PassRole"
                ],
                "Effect": "Allow"
            },
            {
                "Resource": "arn:aws:cloudformation:ap-southeast-2:aws:transform/Serverless-2016-10-31",
                "Action": [
                    "cloudformation:CreateChangeSet"
                ],
                "Effect": "Allow"
            },
            {
                "Resource": "arn:aws:codedeploy:ap-southeast-2::application:*",
                "Action": [
                    "codedeploy:CreateApplication",
                    "codedeploy:DeleteApplication",
                    "codedeploy:RegisterApplicationRevision"
                ],
                "Effect": "Allow"
            },
            {
                "Resource": "arn:aws:codedeploy:ap-southeast-2::deploymentgroup:*",
                "Action": [
                    "codedeploy:CreateDeploymentGroup",
                    "codedeploy:CreateDeployment",
                    "codedeploy:GetDeployment"
                ],
                "Effect": "Allow"
            },
            {
                "Resource": "arn:aws:codedeploy:ap-southeast-2::deploymentconfig:*",
                "Action": [
                    "codedeploy:GetDeploymentConfig"
                ],
                "Effect": "Allow"
            }
        ]
    }
    EOF
}
