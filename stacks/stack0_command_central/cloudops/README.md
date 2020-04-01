# webmethods-devsecops-recipes - stack0 - command central

This creates the management-related cloud artifacts

## Pre-requisites: Set the environment

Make sure you have run the "cloud-base" terraform project, it will have created the general environment artifacts and boundaries (VPC, routes, subnets, etc...).

## Create base environment

Now, you can create the environment:

```bash
env=demoenv
configs=$HOME/mydevsecrets/webmethods-devsecops-recipes/configs/$env/stacks
terraform get -update=true
terraform init -backend-config=$configs/stack0/backend.conf
terraform plan -var-file=$configs/stack0/stack.tfvars
terraform apply -var-file=$configs/stack0/stack.tfvars
```

## Destroy stack

```bash
env=demoenv
configs=$HOME/mydevsecrets/webmethods-devsecops-recipes/configs/$env/stacks
terraform init -backend-config=$configs/stack0/backend.conf
terraform destroy -var-file=$configs/stack0/stack.tfvars
```