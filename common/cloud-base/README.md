# webmethods-devsecops-recipes - cloud-base - cloud skeleton

This creates the base environment into which we'll create all our sample projects
If this is the first time you setup, follow [README-first-time-steps](./README-first-time-steps.md) for a few intiial setup tasks.

## Download demo configs from S3

Based on the first-time steps, we'll assume for the rest of this page that the following path variable is set and exist on your workstation.
Feel free to change the path if required.

```bash
env=demoenv
export SAGDEVOPSDEMO_CONFIGS_PATH=$HOME/mydevsecrets/webmethods-devsecops-recipes/configs/$env
export SAGDEVOPSDEMO_ADMIN_S3BUCKETNAME="<your admin s3 bucket>"
```

Run the following commands to get the configs from s3

```bash
aws s3 sync s3://$SAGDEVOPSDEMO_ADMIN_S3BUCKETNAME/webmethods-devsecops-recipes/configs/$env $SAGDEVOPSDEMO_CONFIGS_PATH
chmod -R 600 $SAGDEVOPSDEMO_CONFIGS_PATH/certs/ssh/*
```

## Create base environment

Now, you can create the environment:

```bash
env=demoenv
configs=$HOME/mydevsecrets/webmethods-devsecops-recipes/configs/$env/stacks
terraform get -update=true
terraform init -backend-config=$configs/cloud-base/backend.conf
terraform plan -var-file=$configs/cloud-base/stack.tfvars
terraform apply -var-file=$configs/cloud-base/stack.tfvars
```

## Destroy stack

```bash
env=demoenv
configs=$HOME/mydevsecrets/webmethods-devsecops-recipes/configs/$env/stacks
terraform init -backend-config=$configs/cloud-base/backend.conf
terraform destroy -var-file=$configs/cloud-base/stack.tfvars
```