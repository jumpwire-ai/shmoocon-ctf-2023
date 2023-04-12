#IAM Role
resource "aws_iam_role" "ec2-role" {
  name               = "ec2-role-${var.cgid}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    Name     = "ec2-role-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
#Iam Role Policy
resource "aws_iam_policy" "ec2-role-policy" {
  name        = "ec2-role-policy-${var.cgid}"
  description = "ec2-role-policy-${var.cgid}"
  policy      = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "rds:DescribeDBInstances"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}
#IAM Role Policy Attachment
resource "aws_iam_policy_attachment" "ec2-role-policy-attachment" {
  name = "ec2-role-policy-attachment-${var.cgid}"
  roles = [
    "${aws_iam_role.ec2-role.name}"
  ]
  policy_arn = aws_iam_policy.ec2-role-policy.arn
}
#IAM Instance Profile
resource "aws_iam_instance_profile" "ec2-instance-profile" {
  name = "ec2-instance-profile-${var.cgid}"
  role = aws_iam_role.ec2-role.name
}
#Security Groups
resource "aws_security_group" "ec2-security-group" {
  name        = "ec2-ssh-${var.cgid}"
  description = "Security Group for EC2 Instance"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  tags = {
    Name     = "ec2-ssh-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
#AWS Key Pair
resource "aws_key_pair" "ec2-key-pair" {
  key_name   = "ec2-key-pair-${var.cgid}"
  public_key = file(var.ssh-public-key-for-ec2)
}

#EC2 Instance
resource "aws_instance" "ubuntu-ec2-rds-loader" {
  ami                         = "ami-0a313d6098716f372"
  instance_type               = "t3.nano"
  iam_instance_profile        = aws_iam_instance_profile.ec2-instance-profile.name
  subnet_id                   = aws_subnet.public-subnet-1.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "${aws_security_group.ec2-security-group.id}"
  ]
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }

  user_data = <<-EOF
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y postgresql-client
psql postgresql://${var.rds-username}:${var.rds-password}@${aws_db_instance.psql-rds.endpoint}/${var.rds-database-name} \
-c "CREATE TABLE sensitive_information (name VARCHAR(100) NOT NULL, value VARCHAR(100) NOT NULL);"
psql postgresql://${var.rds-username}:${var.rds-password}@${aws_db_instance.psql-rds.endpoint}/${var.rds-database-name} \
-c "INSERT INTO sensitive_information (name,value) VALUES ('Flag','${local.flag}');"
EOF

  volume_tags = {
    Name     = "EC2 Instance Root Device"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
  tags = {
    Name     = "ubuntu-ec2-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

#EC2 Instance
resource "aws_instance" "ubuntu-ec2-proxy" {
  ami                         = "ami-0a313d6098716f372"
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.ec2-instance-profile.name
  subnet_id                   = aws_subnet.public-subnet-1.id
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "${aws_security_group.ec2-security-group.id}"
  ]
  key_name = "${aws_key_pair.ec2-key-pair.key_name}"
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }

  user_data = <<-EOF
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update

apt-get install -y autoconf bison flex gcc g++ git libprotobuf-dev libnl-route-3-dev libtool make pkg-config protobuf-compiler
git clone https://github.com/google/nsjail/
cd nsjail
make
mv /nsjail/nsjail /usr/local/sbin

cat > /etc/nsjail.cfg <<EOC
name: "ssh-nsjail-configuration"
description: "nsjail configuration for SSH isolation."

mode: ONCE
rlimit_as_type: HARD
rlimit_cpu_type: HARD
rlimit_nofile_type: HARD
rlimit_nproc_type: HARD
clone_newnet: false

cwd: "/home/ctf"
envar: "HOME=/home/ctf"

mount: [
  {
    src: "/"
    dst: "/"
    is_bind: true
  },
  {
    dst: "/tmp"
    fstype: "tmpfs"
    rw: true
  },
  {
    dst: "/proc"
    fstype: "proc"
    rw: true
  },
  {
    src: "/etc/resolv.conf"
    dst: "/etc/resolv.conf"
    is_bind: true
  }
]
EOC

cat > /usr/local/sbin/jailme <<EOC
#!/bin/bash

exec nsjail -Q --config /etc/nsjail.cfg -- /bin/bash
EOC
chmod +x /usr/local/sbin/jailme

useradd -d /home/ctf -m ctf -s /usr/local/sbin/jailme
mkdir /home/ctf/.ssh
echo '${file(var.ssh-public-key-for-ec2)}' > /home/ctf/.ssh/authorized_keys
chown -R ctf:ctf /home/ctf/.ssh
chmod 700 /home/ctf/.ssh
chmod 600 /home/ctf/.ssh/authorized_keys

reboot
EOF

  volume_tags = {
    Name     = "EC2 Instance Root Device"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
  tags = {
    Name     = "ubuntu-ec2-${var.cgid}"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
