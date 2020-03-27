# recipe2-integration-simple -- ansible

Ansible portion of the recipe2 project

## Prepping steps

Connect to the management server:

```bash
. ./common/cloud-base/tfexpanded/setenv-base.sh
ssh -A $BASTION_SSH_USER@$BASTION_SSH_HOST
. $HOME/setenv-mgt.sh
ssh -A $MGT_SSH_USER@$MGT_SSH_HOST
```

Go into the ansible project directory:

```bash
cd ~/webmethods-provisioning/webmethods-devops-ansible/
```

Then, let's sysprep everything (preparing the new servers we just created)

```bash
ansible-playbook -i inventory sagenv-sysprep-all.yaml
```

## Provisioning the components

Now, we can provision the various products and configs by simply running either below.

### Concurrent provisioning

```bash
./recipe2-concurrent.sh
```

Check progress as indicated by the script output.

### Serial provisioning

```bash
./recipe2-serial.sh
```

Check progress as indicated by the script output.