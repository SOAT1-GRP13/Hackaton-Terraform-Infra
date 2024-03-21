variable "region" {
  description = "us-west-2"
}

variable "environment" {
  description = "The Deployment environment"
}

variable "access_key" {
  description = "AWS access key to create resources"
}

variable "secret_key" {
  description = "AWS secret key to create resources"
}

variable "rabbit_user" {
  description = "User of rabbitMQ"
}

variable "rabbit_password" {
  description = "Password of rabbitMQ"
}



# #Usar quando for rodar local
# variable "profile" {
#   description = "AWS profile to create resources used locally"
# }

//Networking

variable "db_username" {
  description = "us-west-2"
}

variable "db_password" {
  description = "us-west-2"
}