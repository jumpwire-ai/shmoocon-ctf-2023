#Required: AWS Profile
variable "profile" {
  default = "ctf-cloudproxy"
}
#Required: AWS Region
variable "region" {
  default = "us-east-1"
}
#Required: CGID Variable for unique naming
variable "cgid" {
  default = "default"
}
#SSH Public Key
variable "ssh-public-key-for-ec2" {
  default = "../assets/ctf-key.pub"
}
#SSH Private Key
variable "ssh-private-key-for-ec2" {
  default = "../assets/ctf-key"
}
#Stack Name
variable "stack-name" {
  default = "CTF"
}
#Scenario Name
variable "scenario-name" {
  default = "cloud-proxy"
}


locals {
  #Required: User's Public IP Address(es)
  cg_whitelist = split("\n", chomp(file("../../../ip-whitelist.txt")))
}
