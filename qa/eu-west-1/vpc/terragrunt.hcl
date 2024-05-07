include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path = "${get_terragrunt_dir()}/../../_env/vpc.hcl"
}

inputs = {
  azs  = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}