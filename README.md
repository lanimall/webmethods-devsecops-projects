# webmethods-devsecops-projects
various infrastructure-as-code project samples that demonstrate full auto-provisioning of different webmethods environments

## Add keys to the management servers:

```
cp ~/webmethods-provisioning/.ssh/sshkey_id_rsa_internalnode ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
```

## bootstrap management server

1) Bootstrap ansible / python / aws cli

```
cd ~/webmethods-provisioning/scripts/
./bootstrap-management-(rhel|centos).sh
```

2) configure AWS credentials to pull SAG content from S3

```
. ~/setenv.sh
aws configure
```

3) Pull content from S3

```
cd ~/webmethods-provisioning/scripts/
./bootstrap-devops-content.sh
./bootstrap-sag-content.sh
```

