# resource "aws_lambda_function" "lambda_s3_handler" {
#   function_name    = "techChallenge-authorizer"
#   filename         = data.archive_file.lambda_zip_file.output_path
#   source_code_hash = data.archive_file.lambda_zip_file.output_base64sha256
#   handler          = "index.handler"
#   role             = aws_iam_role.iam_for_lambda.arn
#   runtime          = "nodejs18.x"
# }

# data "archive_file" "lambda_zip_file" {
#   type        = "zip"
#   source_file = "${path.module}/src/index.js"
#   output_path = "${path.module}/lambda.zip"
# }

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  inline_policy {
    name   = "lambda_logs_policy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "AllowLambdaFunctionToCreateLogs",
        "Action": [ 
            "logs:*" 
        ],
        "Effect": "Allow",
        "Resource": [ 
            "arn:aws:logs:*:*:*" 
        ]
    },
    {
			"Effect": "Allow",
			"Action": [
				"dynamodb:BatchGetItem",
				"dynamodb:GetItem",
				"dynamodb:Query",
				"dynamodb:Scan",
				"dynamodb:BatchWriteItem",
				"dynamodb:PutItem",
				"dynamodb:UpdateItem"
			],
			"Resource": ["*"]
	}
  ]
}
EOF
  }
}

# data "aws_iam_policy_document" "assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["lambda.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }

#   statement {
#     sid       = "Dynamo"
#     actions   = ["dynamodb:*"]
#     resources = ["arn:aws:dynamodb:*"]
#   }

#   statement {
#     sid       = "CreateLogs"
#     actions   = ["logs:*"]
#     resources = ["arn:aws:logs:*:*:*"]
#   }
# }

# resource "aws_iam_role" "iam_for_lambda" {
#   name               = "iam_for_lambda"
#   assume_role_policy = data.aws_iam_policy_document.iam_lambda.json
# }

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "./resources/index.mjs"
  output_path = "./resources/lambda_function_payload.zip"
}

resource "aws_lambda_function" "authorizer_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "./resources/lambda_function_payload.zip"
  function_name = "techChallenge-authorizer"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "nodejs18.x"
}
