# Mac Lab

## Overview

To be completed soon.

## Requirements and Setup

Tested with:
* Mac OS 13.4
* terraform 1.5.7

Clone this repository:
```
git clone https://github.com/iknowjason/MacLab
```

Credentials Setup:

Generate an IAM programmatic access key that has permissions to build resources in your AWS account.  Setup your .env to load these environment variables.  You can also use the direnv tool to hook into your shell and populate the .envrc.  Should look something like this in your .env or .envrc:

```
export AWS_ACCESS_KEY_ID="VALUE"
export AWS_SECRET_ACCESS_KEY="VALUE"
```

## Build and Destroy Resources

### Run terraform init
Change into the AutomatedEmulation working directory and type:

```
terraform init
```

### Run terraform plan or apply
```
terraform apply -auto-approve
```
or
```
terraform plan -out=run.plan
terraform apply run.plan
```

### Destroy resources
```
terraform destroy -auto-approve
```

### View terraform created resources
The lab has been created with important terraform outputs showing services, endpoints, IP addresses, and credentials.  To view them:
```
terraform output
```

## Features and Capabilities

### Important Firewall and White Listing

### Mac Examples for Building Intel, M1, M2, M2Pro


