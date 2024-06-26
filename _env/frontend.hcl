terraform {
  source = "tfr:///terraform-aws-modules/ecs/aws//modules/service?version=5.11.1"
}

locals {
  global_vars = read_terragrunt_config(find_in_parent_folders("global.hcl"))
  regional_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  project_name = local.global_vars.locals.project_name
  aws_region   = local.regional_vars.locals.aws_region

  service_name   = "${local.project_name}-ecsdemo-frontend"
  container_name = "${local.project_name}-ecsdemo-frontend"
  container_port = 3000
}

dependency "vpc" {
  config_path = "../../vpc"
}

dependency "alb" {
  config_path = "../../alb"
}

dependency "ecs_cluster" {
  config_path = "../../ecs-cluster"
}

inputs = {
  cluster_name = "${local.project_name}-fargate"

  name        = local.service_name
  cluster_arn = dependency.ecs_cluster.outputs.arn

  cpu    = 1024
  memory = 4096

  # Enables ECS Exec
  enable_execute_command = true

  # Container definition(s)
  container_definitions = {

    (local.container_name) = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
      port_mappings = [
        {
          name          = local.container_name
          containerPort = local.container_port
          hostPort      = local.container_port
          protocol      = "tcp"
        }
      ]

      # Example image used requires access to write to root filesystem
      readonly_root_filesystem = false

      enable_cloudwatch_logging = true

      linux_parameters = {
        capabilities = {
          add = []
          drop = [
            "NET_RAW"
          ]
        }
      }
      memory_reservation = 100
    }
  }

  load_balancer = {
    service = {
      target_group_arn = dependency.alb.outputs.target_groups["ex_ecs"].arn
      container_name   = local.container_name
      container_port   = local.container_port
    }
  }

  subnet_ids = dependency.vpc.outputs.private_subnets
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = dependency.alb.outputs.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}