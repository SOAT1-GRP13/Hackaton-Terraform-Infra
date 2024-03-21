resource "aws_secretsmanager_secret" "auth" {
  name = "auth-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "produto" {
  name = "ponto-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "producao" {
  name = "relatorio-secret"
  recovery_window_in_days = 0
}