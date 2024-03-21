/*====
Variables used across all modules
======*/
locals {
  dev_availability_zones = ["${var.region}a", "${var.region}b"]
  environment            = "dev"
}

//TODO criar bucket
//*=======Usar somente para pipeline"==========*/
terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "techchallenge-soat1-grp13-state"
    key            = "tfstate-s3-bucket"
    region         = "us-west-2"
    dynamodb_table = "soat1-grp13-dynamo-lock"
  }
}

module "networking" {
  source = "./modules/networking"

  region             = var.region
  environment        = var.environment
  availability_zones = local.dev_availability_zones
}

module "databases" {
  source = "./modules/database"

  availability_zone  = local.dev_availability_zones[0]
  subnet_group_name  = module.networking.db_subnet_group_name
  db_username        = var.db_username
  db_password        = var.db_password
  environment        = local.environment
  vpc_id             = module.networking.vpc_id
  ecs_security_group = module.ecs.ecs_security_group
}

module "s3" {
  source = "./modules/s3"

  environment = local.environment
}

module "secrets" {
  source = "./modules/secrets"
}

module "alb" {
  source = "./modules/alb"

  vpc_id              = module.networking.vpc_id
  privates_subnets_id = module.networking.private_subnet_id
}

module "lambda" {
  source = "./modules/lambda"
}

module "apigw" {
  source              = "./modules/apigw"
  privates_subnets_id = module.networking.private_subnet_id
  listener_arn        = module.alb.listener_arn
  lambda_invoke_arn   = module.lambda.lambda_invoke_arn
  lambda_name         = module.lambda.lambda_name
  lb_engress_id       = module.alb.egress_all_id
  lb_ingress_id       = module.alb.ingress_api_id
}

module "ecs" {
  source = "./modules/ecs"

  privates_subnets_id                   = module.networking.private_subnet_id
  lb_engress_id                         = module.alb.egress_all_id
  lb_ingress_id                         = module.alb.ingress_api_id
  lb_target_group_relatorio_arn         = module.alb.lb_target_group_relatorio_arn
  lb_target_group_ponto_arn             = module.alb.lb_target_group_ponto_arn
  lb_target_group_auth_arn              = module.alb.lb_target_group_auth_arn
  lb_target_group_rabbit_arn            = module.alb.lb_target_group_rabbit_arn
  lb_target_group_rabbit_management_arn = module.alb.lb_target_group_rabbit_management_arn
  vpc_id                                = module.networking.vpc_id
  dynamo_arn                            = module.databases.dynamo_arn
  rabbit_password                       = var.rabbit_password
  rabbit_user                           = var.rabbit_user
}

output "alb-dns" {
  description = "DNS do load balance interno"
  value       = module.alb.dns_name
}

output "rds-address" {
  description = "caminho do RDS"
  value       = module.databases.db_instance_address
}

output "replica-rds-address" {
  description = "caminho do RDS de replica"
  value       = module.databases.replica-url
}

output "api-gateway-invoke" {
  description = "invoke url to default stage"
  value       = module.apigw.invoke_url
}

output "api-endpoint" {
  description = "api gateway endpoint"
  value       = module.apigw.apigw_endpoint
}
