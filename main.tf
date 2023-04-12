terraform {
  required_version = ">= 1.0.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.1"
    }

    fly = {
      source  = "fly-apps/fly"
      version = "~> 0.0.20"
    }
  }

  backend "s3" {
    bucket = "changeme"
    key    = "terraform/shmoocon-ctf.tfstate"
    region = "us-east-2"
  }
}

variable "dns_suffix" {
  type    = string
  default = "changeme"
}

variable "ctfd_db_password" {
  type    = string
  default = "0dLlPXl9NvBUxKdmBidG"
}

variable "ctfd_ami" {
  default = "ami-0b7dbdd7650cf2988"
}

provider "aws" {
  region = "us-east-2"
}
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
provider "cloudflare" {}

data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

module "scoreboard_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name                 = "scoreboard"
  cidr                 = "10.42.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.42.1.0/24", "10.42.2.0/24"]
  public_subnets       = ["10.42.11.0/24", "10.42.12.0/24"]
  database_subnets     = ["10.42.21.0/24", "10.42.22.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}
output "staging_vpc_id" {
  value = module.scoreboard_vpc.vpc_id
}

resource "aws_security_group" "scoreboard" {
  name        = "shmoocon-ctf-scoreboard"
  description = "Allow HTTP inbound traffic"
  vpc_id      = module.scoreboard_vpc.vpc_id

  ingress {
    description     = "CTFd HTTP"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.scoreboard_lb.id]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "scoreboard_lb" {
  name        = "shmoocon-ctf-scoreboard-lb"
  description = "Allow HTTP inbound traffic"
  vpc_id      = module.scoreboard_vpc.vpc_id

  ingress {
    description      = "Public HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Public HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_iam_user" "scoreboard" {
  name = "shmoocon-ctf-scoreboard"
  path = "/"
}

resource "aws_iam_role" "scoreboard" {
  name = "shmoocon-ctf-scoreboard"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_user_policy" "scoreboard" {
  name = "shmoocon-ctf-scoreboard"
  user = aws_iam_user.scoreboard.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ],
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.scoreboard_uploads.arn,
          "${aws_s3_bucket.scoreboard_uploads.arn}/*",
        ]
      },
    ]
  })
}

resource "aws_iam_instance_profile" "scoreboard" {
  name = "shmoocon-ctf-scoreboard"
  role = aws_iam_role.scoreboard.name
}

resource "aws_instance" "scoreboard" {
  ami                  = var.ctfd_ami
  instance_type        = "t4g.medium"
  iam_instance_profile = aws_iam_instance_profile.scoreboard.name

  tags = {
    Name = "shmoocon-ctf-scoreboard"
  }

  associate_public_ip_address = true
  ebs_optimized               = true
  key_name                    = "hexedpackets"
  subnet_id                   = module.scoreboard_vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.scoreboard.id]
}

output "scoreboard_ip" {
  value = aws_instance.scoreboard.public_ip
}


resource "aws_ebs_volume" "scoreboard_sqllite" {
  availability_zone = module.scoreboard_vpc.azs[0]
  size              = 10
  type              = "gp3"
}

resource "aws_volume_attachment" "scoreboard_sqllite" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.scoreboard_sqllite.id
  instance_id = aws_instance.scoreboard.id
}

resource "aws_acm_certificate" "scoreboard" {
  domain_name       = "ctf.jumpwire.ai"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

data "cloudflare_zone" "ctf_root" {
  name = var.dns_suffix
}

resource "cloudflare_record" "ctf_acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.scoreboard.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.cloudflare_zone.ctf_root.id
  name    = each.value.name
  value   = each.value.record
  type    = each.value.type
  ttl     = 3600
  proxied = false
}

resource "aws_acm_certificate_validation" "scoreboard" {
  certificate_arn         = aws_acm_certificate.scoreboard.arn
  validation_record_fqdns = values(cloudflare_record.ctf_acm_validation).*.hostname
}

resource "aws_lb" "scoreboard" {
  name               = "shmoocon-ctf-scoreboard"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.scoreboard_lb.id]
  subnets            = module.scoreboard_vpc.public_subnets
}

resource "aws_lb_target_group" "ctfd" {
  name     = "shmoocon-ctf-ctfd"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = module.scoreboard_vpc.vpc_id
}

resource "aws_lb_target_group_attachment" "ctfd" {
  target_group_arn = aws_lb_target_group.ctfd.arn
  target_id        = aws_instance.scoreboard.id
}


resource "aws_lb_listener" "scoreboard_http" {
  load_balancer_arn = aws_lb.scoreboard.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "ctfd_https" {
  load_balancer_arn = aws_lb.scoreboard.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate_validation.scoreboard.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ctfd.arn
  }
}

resource "cloudflare_record" "ctf" {
  zone_id = data.cloudflare_zone.ctf_root.id
  name    = "ctf"
  value   = aws_lb.scoreboard.dns_name
  type    = "CNAME"
  ttl     = "3600"
  proxied = false
}

output "hostname" {
  value = cloudflare_record.ctf.hostname
}


resource "aws_security_group" "ctfd_db" {
  name        = "shmoocon-ctf-ctfd-db"
  description = "Allow DB traffic"
  vpc_id      = module.scoreboard_vpc.vpc_id

  ingress {
    description     = "CTFd"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.scoreboard.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_db_instance" "ctfd_db" {
  allocated_storage      = 10
  storage_type           = "gp2"
  db_name                = "ctfd"
  engine                 = "mariadb"
  engine_version         = "10.6"
  instance_class         = "db.t3.medium"
  username               = "ctfd"
  password               = var.ctfd_db_password
  skip_final_snapshot    = true
  maintenance_window     = "Mon:04:00-Mon:10:00"
  db_subnet_group_name   = module.scoreboard_vpc.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.ctfd_db.id]
}

output "ctfd_db_url" {
  value = "${aws_db_instance.ctfd_db.username}:${var.ctfd_db_password}@${aws_db_instance.ctfd_db.endpoint}/${aws_db_instance.ctfd_db.db_name}"
}

resource "aws_s3_bucket" "scoreboard_uploads" {
  bucket = "shmoocon-ctf-2023"
}

resource "aws_ecrpublic_repository" "docker_chall" {
  # This resource can only be used with us-east-1 region.
  provider        = aws.us_east_1
  repository_name = "image-4-sail"
}
output "scoreboard_repo_url" {
  value = aws_ecrpublic_repository.docker_chall.repository_uri
}
