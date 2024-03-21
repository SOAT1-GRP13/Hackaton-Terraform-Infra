output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = try(aws_db_instance.postgresql_db.address, null)
}

output "replica-url" {
  description = "The address of the replica RDS instance"
  value       = try(aws_db_instance.replica-postgresql-rds.address, null)
}

output "dynamo_arn" {
  description = "the dynamoDB arn"
  value       = aws_dynamodb_table.loggedUsers.arn
}

