# webmethods-devsecops-recipes

Various infrastructure-as-code project samples that demonstrate full auto-provisioning of different webmethods environments

## Prep tasks

There are a couple of one-time tasks to perform in order to access the servers and setup a command central with the right artifacts.

Check out this [README](./README-Preps.md) for all the one-time setup tasks.

At the end, you should have a running Command Central that's accessible and configured at URL (where $resources_external_dns_apex is the value you entered during the cloud creation of the environment)

```bash
. ./common/cloud-management/tfexpanded/setenv-mgt.sh && \
open https://$HOSTNAME_EXTERNAL_COMMANDCENTRAL/
```

## Provision recipes

Recipe1: 1 Api Gateway
Go to [Setup](./recipes/recipe1-apimgt-simple/README.md)

Recipe2: 1 Api Gateway, 1 Integration Server (embedded DB), Universal MEssaging, Terracotta
Go to [Setup](./recipes/recipe2-integration-simple/README.md)

Recipe3: 1 Integration Server (with backend DB), MWS (with backend DB), Universal Messaging, Terracotta
Go to [Setup](./recipes/recipe3-integration-with-db/README.md)

etc...