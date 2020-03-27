# webmethods-devsecops-recipes - cloud-management

This creates the management-related cloud artifacts

## Pre-requisites: Set the environment

Once you have run the "cloud-base" terraform project, it will have created the general environment artifacts and boundaries (VPC, routes, subnets, etc...).

## Create base environment

Now, you can create the environment:

```bash
terraform init && terraform apply
```
