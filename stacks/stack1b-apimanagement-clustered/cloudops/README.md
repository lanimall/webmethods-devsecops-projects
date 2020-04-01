# webmethods-devsecops-recipes - stack1b webMethods api-management clustered

This creates the management-related cloud artifacts

## Pre-requisites: Set the environment

Make sure you have run the "cloud-base" terraform project, it will have created the general environment artifacts and boundaries (VPC, routes, subnets, etc...).

## Create base environment

Now, you can create the environment:

```bash
env=demoenv
stack=stack1b
configs=$HOME/mydevsecrets/webmethods-devsecops-recipes/configs/$env/stacks/$stack
terraform get -update=true
terraform init -backend-config=$configs/backend.conf
terraform plan -var-file=$configs/stack.tfvars
terraform apply -var-file=$configs/stack.tfvars
```

## Destroy stack

```bash
env=demoenv
stack=stack1b
configs=$HOME/mydevsecrets/webmethods-devsecops-recipes/configs/$env/stacks/$stack
terraform init -backend-config=$configs/backend.conf
terraform destroy -var-file=$configs/stack.tfvars
```