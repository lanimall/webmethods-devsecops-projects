# common-cloud
This creates the base environment into which we'll create all our sample projects

## Get the code and initial setup

Run the following commands to get the terraform code, generate the ssh keys we'll need, and fix the permissions on the keys

```
ssh-keygen -b 2048 -t rsa -f ./helper_scripts/sshkey_id_rsa_bastion -q -N ""
ssh-keygen -b 2048 -t rsa -f ./helper_scripts/sshkey_id_rsa_internalnode -q -N ""
chmod 600 ./helper_scripts/sshkey_*
```

Then, add the ssh key to the local agent for easy remote connecting:
```
ssh-add ./helper_scripts/sshkey_id_rsa_bastion
```

## SSL setup for main load balancer

### Generate the certificate signing request:

If doing it in 1 liner using the -subj attribute:
- Make sure to replace the COUNTRYCODE, STATE, CITY, ORG, ORG UNIT, and domain with what you want.
- Make sure that if any of your info contains "/" characters, escape it as follows "\/"

```
export SSL_CERT_COUNTRYCODE=<your info>
export SSL_CERT_STATE=<your info>
export SSL_CERT_CITY=<your info>
export SSL_CERT_ORG=<your info>
export SSL_CERT_ORGUNIT=<your info>
export SSL_CERT_EMAIL=<your info>
export SSL_CERT_CN=*.<your external demo domain>

openssl genrsa -out ./helper_scripts/ssl-devsecops-clouddemos.key 2048
openssl req -new -key ./helper_scripts/ssl-devsecops-clouddemos.key -out ./helper_scripts/ssl-devsecops-clouddemos.csr -subj "/emailAddress=$SSL_CERT_EMAIL/C=$SSL_CERT_COUNTRYCODE/ST=$SSL_CERT_STATE/L=$SSL_CERT_CITY/O=$SSL_CERT_ORG/OU=$SSL_CERT_ORGUNIT/CN=$SSL_CERT_CN"
```

Make sure that the CSR was geenrally properly...especailly the "Subject" info...
```
openssl req -text -noout -verify -in ./helper_scripts/ssl-devsecops-clouddemos.csr
```

### Generate the CA and self signed certificate for the CA:

```
openssl genrsa -out ./helper_scripts/ssl-devsecops-clouddemos-ca.key 2048
openssl req -new -x509 -key ./helper_scripts/ssl-devsecops-clouddemos-ca.key -out ./helper_scripts/ssl-devsecops-clouddemos-ca.crt -subj "/emailAddress=$SSL_CERT_EMAIL/C=$SSL_CERT_COUNTRYCODE/ST=$SSL_CERT_STATE/L=$SSL_CERT_CITY/O=$SSL_CERT_ORG/OU=$SSL_CERT_ORGUNIT/CN=$SSL_CERT_CN"
```

You could use the following subject to create the CRT in one line (replacing the COUNTRYCODE, STATE, CITY, ORG, ORG UNIT, and domain with what you want)
```
-subj "/emailAddress=/C=COUNTRYCODE/ST=STATE/L=CITY/O=ORG/OU=ORG UNIT/CN=*.sagdemo.com"
```

Finally, sign the CSR and create the CRT:

openssl x509 -req -in ./helper_scripts/ssl-devsecops-clouddemos.csr -CA ./helper_scripts/ssl-devsecops-clouddemos-ca.crt -CAkey ./helper_scripts/ssl-devsecops-clouddemos-ca.key -CAcreateserial -out ./helper_scripts/ssl-devsecops-clouddemos.crt

Checking the cert:

openssl x509 -in ./helper_scripts/ssl-devsecops-clouddemos.crt -noout -text


## Create base environment

```bash
terraform init && terraform apply
```