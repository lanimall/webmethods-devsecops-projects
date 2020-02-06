# webmethods-devsecops-recipes - cloud-management

This creates the management-related cloud artifacts

## Pre-requisites: Set the environment

Once you have run the "cloud-base" terraform project, it will have created the general environment artifacts and boundaries (VPC, routes, subnets, etc...).

Based on that, we'll need to provide some info to our current (and future) terraform projects we want to execute in this newly-created environment. 

In order to automatically set the right variables needed by our environment, simply execute:

```bash
. ../cloud-base/tfexpanded/setenv-base.sh
```

## Create base environment

Now, you can create the environment:

```bash
terraform init && terraform apply
```
