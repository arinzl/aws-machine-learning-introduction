resource "aws_security_group" "codebuild" {
  name_prefix = var.app_name
  description = "Allow outbound traffic to allow download images and dependencies for codebuild"
  vpc_id      = module.codebuild_vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
