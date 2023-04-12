data "archive_file" "lambda-function" {
  type        = "zip"
  source_file = "../assets/lambda.py"
  output_path = "../assets/lambda.zip"
}
resource "aws_iam_role" "lambda-role" {
  name               = "lambda-role-${var.cgid}-service-role"
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
  tags = {
    Name     = "lambda-role-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
resource "aws_lambda_function" "lambda-function" {
  filename         = "../assets/lambda.zip"
  function_name    = "lambda-${var.cgid}"
  role             = aws_iam_role.lambda-role.arn
  handler          = "lambda.handler"
  source_code_hash = data.archive_file.lambda-function.output_base64sha256
  runtime          = "python3.9"
  environment {
    variables = {
      DB_NAME     = "${var.rds-database-name}"
      DB_USER     = "${var.rds-username}"
      DB_PASSWORD = "${var.rds-password}"
    }
  }
  tags = {
    Name     = "lambda-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
