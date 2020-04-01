# webmethods-cce

An ansible project for webMethods command central

## Some sysprep tasks

Let's sysprep everything:

```bash
ansible-playbook -i inventory sagenv-sysprep-all.yaml
```

## Run

```bash
./project2-runall-serial.sh && tail -f $HOME/nohup-project2.out
```

OR if you want to run only a subset:

```bash
./project2-runall-concurrent.sh apigwinternaldatastore \
    && tail -f $HOME/nohup-project2_playbook_apigwinternaldatastore.out
```

## Special runs directly with ansible commands

In case you need to re-run a specific task...you can tags to the command...

```bash
ansible-playbook -i inventory ./project2.yaml --extra-vars "@vars/project2.yaml" -tags "some_tag1,some_tag2"
```
