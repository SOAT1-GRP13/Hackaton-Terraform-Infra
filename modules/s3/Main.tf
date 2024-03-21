resource "aws_s3_bucket" "lambda_s3" {
  bucket = "tech-challenge-soat1-grp13-s3-auth"

  tags = {
    Name        = "S3-lambda"
    Environment = "${var.environment}"
  }
}