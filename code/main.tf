module "testing" {
  source = "./modules/useraccess"


  vpc_cidr_range       = var.vpc_cidr_root[terraform.workspace]
  app_name             = var.app_name_root
  region               = var.region_root
  repo_branch          = var.repo_branch_root
  private_subnets_list = var.private_subnets_list_root[terraform.workspace]
  public_subnets_list  = var.public_subnets_list_root[terraform.workspace]

}

module "jupyter" {
  source = "./modules/jupyter"

  app_name = var.app_name_root
  region   = var.region_root

  kms_key_arn = module.testing.demo_kms_key_arn
}
