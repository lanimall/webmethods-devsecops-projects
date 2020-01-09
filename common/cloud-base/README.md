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

(Make sure to replace the COUNTRYCODE, STATE, CITY, ORG, ORG UNIT, and domain with what you want)

```
openssl genrsa -out ./helper_scripts/ssl-sagdemo-main-testcert.key 2048
openssl req -new -key ./helper_scripts/ssl-sagdemo-main-testcert.key -out ./helper_scripts/ssl-sagdemo-main-testcert.csr -subj "/emailAddress=/C=COUNTRYCODE/ST=STATE/L=CITY/O=ORG/OU=ORG UNIT/CN=*.sagdemo.com"
```

Check the CSR:
```
openssl req -text -noout -verify -in ./helper_scripts/ssl-sagdemo-main-testcert.csr
```

### Generate the CA and self signed certificate for the CA:

```
openssl genrsa -out ./helper_scripts/ssl-sagdemo-main-ca.key 2048
openssl req -new -x509 -key ./helper_scripts/ssl-sagdemo-main-ca.key -out ./helper_scripts/ssl-sagdemo-main-ca.crt
```

You could use the following subject to create the CRT in one line (replacing the COUNTRYCODE, STATE, CITY, ORG, ORG UNIT, and domain with what you want)
```
-subj "/emailAddress=/C=COUNTRYCODE/ST=STATE/L=CITY/O=ORG/OU=ORG UNIT/CN=*.sagdemo.com"
```

Finally, sign the CSR and create the CRT:

openssl x509 -req -in ./helper_scripts/ssl-sagdemo-main-testcert.csr -CA ./helper_scripts/ssl-sagdemo-main-ca.crt -CAkey ./helper_scripts/ssl-sagdemo-main-ca.key -CAcreateserial -out ./helper_scripts/ssl-sagdemo-main-testcert.crt

Checking the cert:

openssl x509 -in ./helper_scripts/ssl-sagdemo-main-testcert.crt -noout -text

Creating bundle with CA:

cat ./helper_scripts/ssl-sagdemo-main-testcert.crt ./helper_scripts/ssl-sagdemo-main-ca.crt > ./helper_scripts/ssl-sagdemo-main-testcert.bundle.crt


Finally, transform to PEM:
```
openssl x509 -in ./helper_scripts/ssl-sagdemo-main-testcert.bundle.crt -out ./helper_scripts/ssl-sagdemo-main-testcert.bundle.pem -outform PEM
```


## Create base environment

```bash
terraform init && terraform apply
```