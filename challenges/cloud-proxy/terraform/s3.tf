#Secret S3 Bucket
locals {
  # Ensure the bucket suffix doesn't contain invalid characters
  # "Bucket names can consist only of lowercase letters, numbers, dots (.), and hyphens (-)."
  # (per https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html)
  bucket_suffix = replace(var.cgid, "/[^a-z0-9-.]/", "-")
}

resource "aws_s3_bucket" "cardholder-data-bucket" {
  bucket        = "cardholder-data-bucket-${local.bucket_suffix}"
  force_destroy = true
  tags = {
    Name        = "cardholder-data-bucket-${local.bucket_suffix}"
    Description = "S3 Bucket used for storing sensitive cardholder data."
    Stack       = "${var.stack-name}"
    Scenario    = "${var.scenario-name}"
  }
}
resource "aws_s3_bucket_object" "flag" {
  bucket = aws_s3_bucket.cardholder-data-bucket.id
  key    = "cardholder-data.txt"
  source = "../assets/flag"
  tags = {
    Name     = "flag"
    Stack    = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

resource "aws_s3_bucket_acl" "cardholder-data-bucket-acl" {
  bucket = aws_s3_bucket.cardholder-data-bucket.id
  acl    = "private"
}
