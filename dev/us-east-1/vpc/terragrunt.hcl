include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path = "${get_terragrunt_dir()}/../../../_env/vpc.hcl"
}

inputs = {
  azs  = ["us-east-1a", "us-east-1b", "us-east-1c"]
}