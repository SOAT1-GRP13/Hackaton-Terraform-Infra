provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}


# #usar quando for rodar local
# provider "aws" {
#   region  = var.region
#   profile = var.profile
# }