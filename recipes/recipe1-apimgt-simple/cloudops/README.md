# cloud-sub-environment-template

This is a template for a new terraform-managed "environment" within the base environment

## Pre-requisites: Set the environment

Once you have run the "cloud-base" terraform project, it will have created the general environment artifacts and boundaries (VPC, routes, subnets, etc...).

Based on that, we'll need to provide some info to our current (and future) terraform projects we want to execute in this newly-created environment. 

In order to automatically set the right variables needed by our environment, simply execute:

```bash
. ../../../common/cloud-base/tfexpanded/setenv-base.sh
```

## Create base environment

Now, you can create the environment:

```bash
terraform init && terraform apply
```

## Continue with ansible portion

Now, the servers and related cloud artifacts are created, continue with the [Main Instructions](../README.md)