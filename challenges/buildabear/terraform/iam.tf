resource "aws_iam_user" "cicd" {
  name = "cicd-readonly"
  tags = {
    Name     = "cicd-readonly${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
resource "aws_iam_access_key" "cicd" {
  user = aws_iam_user.cicd.name
}
resource "aws_iam_user" "bear-whisperer" {
  name = "bear-whisperer"
  tags = {
    Name     = "bear-whisperer-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
resource "aws_iam_access_key" "bear-whisperer" {
  user = aws_iam_user.bear-whisperer.name
}
#IAM User Policies
resource "aws_iam_policy" "cicd-policy" {
  name        = "cicd-readonly-policy-${var.cgid}"
  description = "cicd-readonly-policy-${var.cgid}"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "cicdreadonly",
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "lambda:Get*",
                "lambda:List*",
                "ssm:Describe*",
                "ssm:Get*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
resource "aws_iam_policy" "bear-whisperer-policy" {
  name        = "bear-whisperer-policy-${var.cgid}"
  description = "bear-whisperer-policy-${var.cgid}"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "bearwhisperer",
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "codebuild:ListProjects",
                "codebuild:BatchGetProjects",
                "codebuild:ListBuilds"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
#User Policy Attachments
resource "aws_iam_user_policy_attachment" "cicd-attachment" {
  user       = aws_iam_user.cicd.name
  policy_arn = aws_iam_policy.cicd-policy.arn
}
resource "aws_iam_user_policy_attachment" "bear-whisperer-attachment" {
  user       = aws_iam_user.bear-whisperer.name
  policy_arn = aws_iam_policy.bear-whisperer-policy.arn
}
