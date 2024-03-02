
#------------------------------------------------------------------------------
# VPC Module
#------------------------------------------------------------------------------
module "codebuild_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.1"


  name = "codebuild-${var.app_name}-vpc"
  cidr = var.vpc_cidr_range

  azs             = ["${var.region}a"]
  private_subnets = var.private_subnets_list
  public_subnets  = var.public_subnets_list


  enable_flow_log                      = false
  create_flow_log_cloudwatch_log_group = false
  create_flow_log_cloudwatch_iam_role  = false
  #vpc_flow_log_permissions_boundary    = aws_iam_policy.vpc_flow_logging_boundary_role_policy.arn
  flow_log_max_aggregation_interval = 60

  create_igw         = true
  enable_nat_gateway = true
  enable_ipv6        = false

  enable_dns_hostnames = true
  enable_dns_support   = true

}
