# webmethods-devsecops-projects
various infrastructure-as-code project samples that demonstrate full auto-provisioning of different webmethods environments



## Add keys to the management servers:

```
cp ~/webmethods-provisioning/.ssh/sshkey_id_rsa_internalnode ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
```



## bootstrap management

1) bootstrap python / aws cli

2) configure AWS

aws configure
