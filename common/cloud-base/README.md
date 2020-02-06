# webmethods-devsecops-recipes - common-cloud

This creates the base environment into which we'll create all our sample projects

NOTE: 

## Prepare the certs

### Prepare the SSH Keys

In order to login into the servers, you'll need to create some SSH keys and store them in a central place.
I will create a folder under my home, but feel free to create wherever appropriate:

```bash
export WEBMETHODS_KEY_PATH=~/.mydevsecrets/webmethods-devsecops-recipes/common/cloud-base
mkdir -p $WEBMETHODS_KEY_PATH
```

Then, run following command to generate the SSH keys:

```bash
ssh-keygen -b 2048 -t rsa -f $WEBMETHODS_KEY_PATH/sshkey_id_rsa_bastion -q -N ""
ssh-keygen -b 2048 -t rsa -f $WEBMETHODS_KEY_PATH/sshkey_id_rsa_internalnode -q -N ""
chmod 600 $WEBMETHODS_KEY_PATH/sshkey_*
```

### Prepare the SSL self-signed certs

#### Generate the certificate signing request

If doing it in 1 liner using the -subj attribute:
 - Make sure to replace the COUNTRYCODE, STATE, CITY, ORG, ORG UNIT, and domain with what you want.
 - Make sure that if any of your info contains "/" characters, escape it as follows "\/"

```bash
export SSL_CERT_COUNTRYCODE=<your info>
export SSL_CERT_STATE=<your info>
export SSL_CERT_CITY=<your info>
export SSL_CERT_ORG=<your info>
export SSL_CERT_ORGUNIT=<your info>
export SSL_CERT_EMAIL=<your info>
export SSL_CERT_CN=*.<your external demo domain>

openssl genrsa -out $WEBMETHODS_KEY_PATH/ssl-devsecops-clouddemos.key 2048
openssl req -new -key $WEBMETHODS_KEY_PATH/ssl-devsecops-clouddemos.key -out $WEBMETHODS_KEY_PATH/ssl-devsecops-clouddemos.csr -subj "/emailAddress=$SSL_CERT_EMAIL/C=$SSL_CERT_COUNTRYCODE/ST=$SSL_CERT_STATE/L=$SSL_CERT_CITY/O=$SSL_CERT_ORG/OU=$SSL_CERT_ORGUNIT/CN=$SSL_CERT_CN"
```

Make sure that the CSR was geenrally properly...especailly the "Subject" info...

```bash
openssl req -text -noout -verify -in $WEBMETHODS_KEY_PATH/ssl-devsecops-clouddemos.csr
```

#### Generate the CA and self signed certificate for the CA:

```bash
openssl genrsa -out $WEBMETHODS_KEY_PATH/ssl-devsecops-clouddemos-ca.key 2048
openssl req -new -x509 -key $WEBMETHODS_KEY_PATH/ssl-devsecops-clouddemos-ca.key -out $WEBMETHODS_KEY_PATH/ssl-devsecops-clouddemos-ca.crt -subj "/emailAddress=$SSL_CERT_EMAIL/C=$SSL_CERT_COUNTRYCODE/ST=$SSL_CERT_STATE/L=$SSL_CERT_CITY/O=$SSL_CERT_ORG/OU=$SSL_CERT_ORGUNIT/CN=$SSL_CERT_CN"
```

Finally, sign the CSR and create the CRT:

```bash
openssl x509 -req -in $WEBMETHODS_KEY_PATH/ssl-devsecops-clouddemos.csr -CA $WEBMETHODS_KEY_PATH/ssl-devsecops-clouddemos-ca.crt -CAkey $WEBMETHODS_KEY_PATH/ssl-devsecops-clouddemos-ca.key -CAcreateserial -out $WEBMETHODS_KEY_PATH/ssl-devsecops-clouddemos.crt
```

Checking the cert:

```bash
openssl x509 -in $WEBMETHODS_KEY_PATH/ssl-devsecops-clouddemos.crt -noout -text
```

## Create base environment

```bash
terraform init && terraform apply
```
