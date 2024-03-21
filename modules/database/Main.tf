/*=============RDS=================*/

resource "aws_security_group" "rds-postgres-sg" {
  name        = "rds-postgres-sg-${var.environment}"
  description = "Security group for RDS Postgres"
  vpc_id      = var.vpc_id
  ingress {
    description     = "Postgres port"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = ["${var.ecs_security_group}"]
  }
  tags = {
    Name        = "Security-group-RDS"
    Environment = "${var.environment}"
  }
}

resource "aws_db_instance" "postgresql_db" {
  allocated_storage       = 20
  db_name                 = "hackaton"
  identifier              = "hackaton"
  engine                  = "postgres"
  engine_version          = "15.4"
  instance_class          = "db.t4g.micro"
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
  publicly_accessible     = true
  availability_zone       = var.availability_zone
  multi_az                = false
  backup_retention_period = 7
  db_subnet_group_name    = var.subnet_group_name
  vpc_security_group_ids  = [aws_security_group.rds-postgres-sg.id]
  tags = {
    Name        = "RDS"
    Environment = "${var.environment}"
  }
}

resource "aws_db_instance" "replica-postgresql-rds" {
  instance_class          = "db.t4g.micro"
  identifier              = "hackatonreplica"
  skip_final_snapshot     = true
  backup_retention_period = 7
  replicate_source_db     = aws_db_instance.postgresql_db.identifier
}

/*=============DynamoDB=================*/
resource "aws_dynamodb_table" "loggedUsers" {
  name                        = "usuariosLogados"
  billing_mode                = "PAY_PER_REQUEST"
  hash_key                    = "token"
  stream_enabled              = false
  table_class                 = "STANDARD"
  deletion_protection_enabled = false

  ttl {
    enabled        = true
    attribute_name = "ttl"
  }


  attribute {
    name = "token"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "DynamoDB-usuarios"
    Environment = "${var.environment}"
  }
}
