#AWS SSM Parameters
resource "aws_ssm_parameter" "ec2-public-key" {
  name        = "ec2-public-key-${var.cgid}"
  description = "ec2-public-key-${var.cgid}"
  type        = "String"
  value       = file("../assets/ctf-key.pub")
  tags = {
    Name     = "ec2-public-key-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

resource "aws_ssm_parameter" "ec2-private-key" {
  name        = "ec2-private-key-${var.cgid}"
  description = "ec2-private-key-${var.cgid}"
  type        = "String"
  value       = file("../assets/ctf-key")
  tags = {
    Name     = "ec2-private-key-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

resource "aws_ssm_parameter" "ec2-user" {
  name        = "ec2-user-${var.cgid}"
  description = "ec2-user-${var.cgid}"
  type        = "String"
  value       = "ctf"
  tags = {
    Name     = "ec2-user-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
