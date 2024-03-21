variable "privates_subnets_id" {
  description = "Privates subnets"
}

variable "listener_arn" {
  description = "alb listener arn"
}

variable "lambda_invoke_arn" {
  description = "lambda arn"
}

variable "lambda_name" {
  description = "name of lambda function"
}

variable "lb_engress_id" {
  description = "Id of engress sg"
}

variable "lb_ingress_id" {
  description = "Id of ingress sg"
}