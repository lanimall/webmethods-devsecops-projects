# recipe2-integration-simple

Project that leverages terraform, ansible, and softwareAG Command Central for creating a complete SoftwareAG infrastructure.

## Prerequisites

At this point, the management and command central server should be fully functionnal with all the required packages available.
If not done, refer to [Initial Setup](../../README-Preps.md)

## Cloud Provisoning steps

Go to the "./cloudops" folder and execute:

```bash
terraform init && terraform apply
```

## Move all the new code to the management server

```bash
../sync-to-remote.sh
```

All code should automatically be copied all the way to the management server (via the bastion)

## Product Provisioning steps




Refer to [Ansible Instructions](./ansible/README.md)

## Accessing the UIs

The UI URLs will depend on the cloud provisoning prefixes and domain name you chose...
In my case:

```bash
export resources_name_prefix=sagdemoproj1
export resources_external_dns_apex=devsecops.clouddemos.saggov.com
```

Api gateway:

```bash
open https://$resources_name_prefix-apigateway-ui.$resources_external_dns_apex
```

Api gateway runtime:

```bash
open https://$resources_name_prefix-apigateway-runtime.$resources_external_dns_apex
```

Api portal:

```bash
open https://$resources_name_prefix-apiportal.$resources_external_dns_apex
```

Api Integration Server:

```bash
open https://$resources_name_prefix-apiintegration1.$resources_external_dns_apex
```

NOTE: These urls are not added to any public DNS at this time... so you'll need to make sure you add them in your local machine's host file to be able to access them.

A command that should work on linux-based systems:

```bash
export AWS_MAIN_ALB=$(dig +short sagdemo-main-public-alb-386813943.us-east-2.elb.amazonaws.com | head -n 1)
echo $AWS_MAIN_ALB $resources_name_prefix-apigateway-ui.$resources_external_dns_apex $resources_name_prefix-apigateway-runtime.$resources_external_dns_apex $resources_name_prefix-apiportal.$resources_external_dns_apex
```
