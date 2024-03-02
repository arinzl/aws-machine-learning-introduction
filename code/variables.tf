
# variable "region" {
#   default = "ap-southeast-2"
#   type    = string
# }

variable "app_name_root" {
  description = "Applicaiton Name"
  type        = string
  default     = "ml-intro"
}

variable "vpc_cidr_root" {
  type        = map(string)
  description = "VPC CIDR ranges per terraform workspace"
  default = {
    "default" : "172.17.0.0/20",
    "dev" : "10.32.0.0/16",
  }

}


variable "private_subnets_list_root" {
  description = "Private subnet list for infrastructure"
  type        = map(list(string))
  default = {
    "default" : ["172.17.1.0/24"]
  }

}

variable "public_subnets_list_root" {
  description = "Public subnet list for infrastructure"
  type        = map(list(string))
  default = {
    "default" : ["172.17.15.0/24"]
  }

}

variable "region_root" {
  description = "Applicaiton Name"
  type        = string
  default     = "ap-southeast-2"
}


variable "repo_branch_root" {
  description = "CodeCommit branch name"
  type        = string
  default     = "master"
}

