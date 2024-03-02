resource "aws_codecommit_repository" "lambda_repo" {
  repository_name = "${var.app_name}-repo"
  description     = "Lambda Repository for ${var.app_name}"
  default_branch  = var.repo_branch
}


resource "aws_codebuild_project" "codebuild" {
  depends_on = [module.artifact_bucket]

  name          = "${var.app_name}-codebuildproject"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild.arn

  encryption_key = aws_kms_key.demo_kms_key.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/${var.app_name}/build"
      stream_name = "${var.app_name}build-log-stream"
    }

    s3_logs {
      status   = "ENABLED"
      location = "${module.artifact_bucket.s3_bucket_id}/build-log"
    }
  }

  source {
    type = "CODEPIPELINE"
  }

  source_version = var.repo_branch

  vpc_config {
    vpc_id = module.codebuild_vpc.vpc_id

    subnets = module.codebuild_vpc.private_subnets

    security_group_ids = [
      aws_security_group.codebuild.id
    ]
  }
}


resource "aws_codepipeline" "app_pipeline" {
  name     = "${var.app_name}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn


  artifact_store {
    location = module.artifact_bucket.s3_bucket_id
    type     = "S3"
  }


  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      input_artifacts  = []
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName       = "${var.app_name}-repo" #local.permission_sets_repository_name
        BranchName           = var.repo_branch
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.codebuild.id
      }
    }
  }


  stage {
    name = "CreateChangeSet_TEST"

    action {
      name            = "GenerateChangeSet"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ActionMode    = "CHANGE_SET_REPLACE"
        Capabilities  = "CAPABILITY_IAM"
        ChangeSetName = var.app_name
        RoleArn       = aws_iam_role.cloudformation.arn
        StackName     = "${var.app_name}"
        TemplatePath  = "build_output::outputSamTemplate.yml"
      }
    }
  }

  stage {
    name = "DeployChangeSet_TEST"

    action {
      name            = "ExecuteChangeSet"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ActionMode    = "CHANGE_SET_EXECUTE"
        Capabilities  = "CAPABILITY_IAM"
        ChangeSetName = var.app_name
        RoleArn       = aws_iam_role.cloudformation.arn
        StackName     = "${var.app_name}"
        TemplatePath  = "build_output::outputSamTemplate.yml"
      }
    }
  }

}
