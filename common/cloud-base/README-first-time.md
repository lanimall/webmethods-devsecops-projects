# webmethods-devsecops-recipes - first time prep steps

We'll assume for the rest of this page that the following path variable is set and exist on your workstation.
Feel free to change the path if required.

```bash
env=demoenv
export SAGDEVOPSDEMO_CONFIGS_PATH=$HOME/.mydevsecrets/webmethods-devsecops-recipes/configs/${env}
export SAGDEVOPSDEMO_ADMIN_S3BUCKETNAME="<your admin s3 bucket>"
```

### Prepare the SSH Keys

In order to login into the servers, you'll need to create some SSH keys and store them in a central place.
I will create the config base folder $SAGDEVOPSDEMO_CONFIGS_PATH:

```bash
mkdir -p $SAGDEVOPSDEMO_CONFIGS_PATH/certs/ssh/
```

Then, run following command to generate the SSH keys:

```bash
ssh-keygen -b 2048 -t rsa -f $SAGDEVOPSDEMO_CONFIGS_PATH/certs/ssh/sshkey_id_rsa_bastion -q -N ""
ssh-keygen -b 2048 -t rsa -f $SAGDEVOPSDEMO_CONFIGS_PATH/certs/ssh/sshkey_id_rsa_internalnode -q -N ""
chmod 600 $SAGDEVOPSDEMO_CONFIGS_PATH/certs/ssh/sshkey_*
```

### Prepare the SSL self-signed certs

Even though it's a demo, it's usually best practice to use SSL for secure-website access...
SSL or not is out of scope for tyhis demo, so I'll leave it up to you.
BUT the rest of the demo code does expect HTTPS in some places, so it'd be preferred to set it up.

If you do decide to create SSL certs, it'd be good to put them in: $SAGDEVOPSDEMO_CONFIGS_PATH/certs/ssl/ to keep consistent.
I created a small document at [README-ssl-selfsigned](./README-ssl-selfsigned.md).

You should have at a minimum:
- private_key: ssl-demo.key
- certificate_body: ssl-demo.crt
- certificate_chain: ssl-demo-ca.crt

## Upload certs to S3 so you don't lose them

Run the following to save your certs in S3 for further reference:

```bash
export SAGDEVOPSDEMO_ADMIN_S3BUCKETNAME="<your admin s3 bucket>"
aws s3 sync $SAGDEVOPSDEMO_CONFIGS_PATH s3://$SAGDEVOPSDEMO_ADMIN_S3BUCKETNAME/webmethods-devsecops-recipes/configs/${env}
```