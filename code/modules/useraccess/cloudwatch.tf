resource "aws_cloudwatch_event_rule" "commit" {
  name        = "${var.app_name}-codecommit_push"
  description = "Capture each push to the CodeCommit reposistory"

  event_pattern = <<-EOF
    {
        "source": ["aws.codecommit"],
        "detail-type": ["CodeCommit Repository State Change"],
        "resources": ["${aws_codecommit_repository.lambda_repo.arn}"],
        "detail": {
            "referenceType": ["branch"],
            "referenceName": ["${var.repo_branch}"]
        }
    }
    EOF
}
resource "aws_cloudwatch_event_target" "pipeline" {
  target_id = "${var.app_name}-pipeline-trigger"
  rule      = aws_cloudwatch_event_rule.commit.name
  arn       = aws_codepipeline.app_pipeline.arn
  role_arn  = aws_iam_role.cloudwatchtrigger.arn
}
