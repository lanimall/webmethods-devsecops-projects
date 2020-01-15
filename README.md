# webmethods-devsecops-projects
various infrastructure-as-code project samples that demonstrate full auto-provisioning of different webmethods environments

## Prep tasks

Check out this [README](./common/README.md) for all the one-time setup tasks.

At the end, you should have a running Command Central that's accessible and configured.

## Provision recipes


### CICD stack (ABE, deployer)

Use --tags install if you don't want to re-sysprep CCE...

```
ansible-playbook -i inventory sagenv-stack-cicd.yaml --tags install
```

or with nohup:
```
nohup ansible-playbook -i inventory sagenv-stack-cicd.yaml --tags install &> ~/nohup-sagenv-stack-cicd.out &
```

Sub tasks if needed:

```
ansible-playbook -i inventory sagenv-stack-cicd.yaml --tags install-abe
ansible-playbook -i inventory sagenv-stack-cicd.yaml --tags install-deployer
```

### Gateway stack (gateway)

```
ansible-playbook -i inventory sagenv-stack-apigateway-standalone.yaml --tags install
```

or with nohup:
```
nohup ansible-playbook -i inventory sagenv-stack-apigateway-standalone.yaml --tags install &> ~/nohup-sagenv-stack-apigateway-standalone.out &
```

### BPMS stack

```
ansible-playbook -i inventory sagenv-stack-bpms-standalone.yaml --tags install-um
```

or with nohup:
```
nohup ansible-playbook -i inventory sagenv-stack-bpms-standalone.yaml --tags install-um &> ~/nohup-sagenv-stack-bpms-standalone-um.out &
```