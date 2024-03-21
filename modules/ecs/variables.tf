# variable "task_exec_secret_arns" {
#   description = "List of SecretsManager secret ARNs the task execution role will be permitted to get/read"
# }

variable "dynamo_arn" {
  description = "arn of dynamoDB"
}

variable "lb_target_group_relatorio_arn" {
  description = "arn relatorio target group"
}

variable "lb_target_group_rabbit_management_arn" {
  description = "arn rabbit management target group"
}

variable "lb_target_group_rabbit_arn" {
  description = "arn rabbitmq target group"
}

variable "lb_target_group_ponto_arn" {
  description = "arn ponto target group"
}

variable "lb_target_group_auth_arn" {
  description = "arn auth target group"
}



variable "lb_engress_id" {
  description = "Id of engress sg"
}

variable "lb_ingress_id" {
  description = "Id of ingress sg"
}

variable "privates_subnets_id" {
  description = "Privates subnets"
}

variable "vpc_id" {
  description = "id of vpc"
}

variable "rabbit_user" {
  description = "User of rabbitMQ"
}

variable "rabbit_password" {
  description = "Password of rabbitMQ"
}
