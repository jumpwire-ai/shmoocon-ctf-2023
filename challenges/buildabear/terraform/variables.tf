#Required: AWS Profile
variable "profile" {
  default = "ctf-buildabear"

}
#Required: AWS Region
variable "region" {
  default = "us-east-1"
}
#Required: CGID Variable for unique naming
variable "cgid" {
  default = "default"
}
#Example: RDS PostgreSQL Instance Credentials
variable "rds-username" {
  default = "secureadmin"
}
variable "rds-password" {
  default = "rgqoi8hQwkRcMBoBPUydiIQYfgZwXKM8"
}
variable "rds-database-name" {
  default = "securedb"
}
#SSH Public Key
variable "ssh-public-key-for-ec2" {
  default = "../assets/ctf-key.pub"
}
#Stack Name
variable "stack-name" {
  default = "CTF"
}
#Scenario Name
variable "scenario-name" {
  default = "buildabear"
}

locals {
  #Required: User's Public IP Address(es)
  cg_whitelist = split("\n", chomp(file("../../../ip-whitelist.txt")))

  flag = file("../assets/flag")


  # Ensure the bucket suffix doesn't contain invalid characters
  # "Bucket names can consist only of lowercase letters, numbers, dots (.), and hyphens (-)."
  # (per https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html)
  cgid_suffix = replace(var.cgid, "/[^a-z0-9-.]/", "-")
}
