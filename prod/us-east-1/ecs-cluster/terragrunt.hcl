include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "tfr:///terraform-aws-modules/ecs/aws//modules/cluster?version=5.11.1"
}

locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))

  project_name = local.global_vars.locals.project_name

  cluster_name   = "${local.project_name}-fargate"
}

inputs = {
  cluster_name = local.cluster_name
}