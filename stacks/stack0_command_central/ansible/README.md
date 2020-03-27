# webmethods-cce

An ansible project for webMethods command central

## Some sysprep tasks

Optional if not done: let's remove tty requiremewnt for SUDO (temp thing until we use the right ansible user)

```bash
ansible-playbook -i inventory sagenv-sysprep-disabletty.yaml
```

Then, let's sysprep everything:

```bash
ansible-playbook -i inventory sagenv-sysprep-all.yaml
```

And let's generate the secrets needed for the installation:

```bash
ansible-playbook -i inventory sagenv-tools-cce-create-secrets.yaml
```

## Run

```bash
./project0-run.sh && tail -f /home/centos/nohup-project0-webmethods-base.out
```

## Special run

In case you need to re-run a specific task...you can do so as such (in this case it re-register the products repos in command central)

```bash
ansible-playbook -i inventory ./project0.yaml --extra-vars "@vars/project0.yaml" --tags "configure-repo-products"
```
