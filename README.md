# Simple web app infrastructure

This project demonstrates simple public web app infrastructure hosted on AWS using Terraform.
The web app is a default NGINX page hosted on ASG w/ 2 EC2 instances to ensure high availability.
GitHub Actions runs Terraform lint, validation, and plans only.

## Planned architecture

![High-level infrastructure overview](docs/images/infra-overview.png)

- Region: `ap-southeast-2` (Sydney).
- Application Load Balancer distributes traffic across healthy instances.
- Auto Scaling Group maintains two EC2 instances across two AZs.
- Terminated or unhealthy instances are replaced automatically using EC2 and load balancer health checks.
- Cloud-init to pull NGINX image from ECR. (The ECR image is the default NGINX image)
  - Note: change to pull NGINX image from docker hub for simplicity.
  - Build image step is not implemented.
- Terraform manages all infrastructure; GitHub Actions authenticates through OIDC for plans.
- Use S3 for Terraform backend state.

## Planned code layout

- `infra/`: Terraform root configuration, variables, outputs.
- `infra/tf-state/`: S3 state bucket module.
- `infra/network/`: VPC, subnets, IGW, and routing.
- `infra/web-app/`: load balancer, launch template, and Auto Scaling Group.
- Apply `project` tag `simple-web-app-infra`

## Assumptions

- Indicative monthly estimate is higher than AUD 20, estimated at AUD 45 (USD 30).
- Traffic is minimal, almost zero traffic. Use the smallest EC2 instance `t4g.nano`.
- This project is to demonstrate the HA infra to host web app, with below limitation:
  - HTTPS and custom DNS are outside this project scope.
  - The web app is static web app, no database layer.
  - Everything in the public subnet for cost saving (avoid using NAT gateway).
  - Cloudwatch logs for debug purpose only.
  - Although serverless infrastructure can be used, this project is to demonstrate web app hosted on EC2 instances.

## Quick start

### Migrate tf state to s3

```sh
# Comment the backend.tf file content completely when first time to bring up the infra
terrform init
terrform apply

# Note down the S3 bucket name after first terraform apply or run below
terraform output

# Migrate tf state to S3 bucket
terraform init -migrate-state \
  -backend-config="bucket=${bucket_name}"
```

### Set up github OIDC manually

On AWS console, set up IdP:

- Provider type: OIDC
- Provider URL: https://token.actions.githubusercontent.com
- Audience: sts.amazonaws.com

Create role with below custom trust policy, replace ACCOUNT_ID, OWNER, OWNER_ID, REPO, and REPO_ID

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": [
            "repo:OWNER@OWNER_ID/REPO@REPO_ID:ref:refs/heads/main",
            "repo:OWNER@OWNER_ID/REPO@REPO_ID:pull_request"
          ]
        }
      }
    }
  ]
}
```
