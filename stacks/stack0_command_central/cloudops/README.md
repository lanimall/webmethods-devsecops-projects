# webmethods-devsecops-recipes - cloud-management

This creates the management-related cloud artifacts

## Pre-requisites: Set the environment

Make sure you have run the "cloud-base" terraform project, it will have created the general environment artifacts and boundaries (VPC, routes, subnets, etc...).

## Create base environment

Now, you can create the environment:

```bash
env=demoenv
stack=stack0
configs=$HOME/mydevsecrets/webmethods-devsecops-recipes/configs/$env/stacks/$stack
terraform get -update=true
terraform init -backend-config=$configs/backend.conf
terraform plan -var-file=$configs/stack.tfvars
terraform apply -var-file=$configs/stack.tfvars
```