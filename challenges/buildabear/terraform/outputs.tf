
#Required: Always output the AWS Account ID
output "aws_account_id" {
  value = data.aws_caller_identity.aws-account-id.account_id
}
output "aws_access_key_id" {
  value = aws_iam_access_key.bear-whisperer.id
}
output "aws_secret_access_key" {
  value     = aws_iam_access_key.bear-whisperer.secret
  sensitive = true
}

resource "local_sensitive_file" "credentials_output" {
  content  = jsonencode({
    "aws_access_key_id": aws_iam_access_key.bear-whisperer.id,
    "aws_secret_access_key": aws_iam_access_key.bear-whisperer.secret,
  })
  filename = "../credentials.json"
}
