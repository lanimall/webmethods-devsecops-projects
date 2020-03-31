# webmethods-devsecops-recipes - generate self signed ssl certs

If you chose to generate the SSL certs for this demo, here are the general steps:

```bash
env=demoenv
export SAGDEVOPSDEMO_CONFIGS_PATH=$HOME/.mydevsecrets/webmethods-devsecops-recipes/configs/${env}
export SAGDEVOPSDEMO_CONFIGS_SSL_PATH=$SAGDEVOPSDEMO_CONFIGS_PATH/certs/ssl
export SAGDEVOPSDEMO_SSL_CERT_CN=*.${env}.devsecops.softwareagdemos.com
```

And let's create the folders on your local to store the certs:

```bash
mkdir -p $SAGDEVOPSDEMO_CONFIGS_SSL_PATH
```

## Generate the certificate signing request (CSR)

Run the following command and follow the prompts:
IMPORTANT: In the certs Prompt, make sure the CN entry matches the value in SAGDEVOPSDEMO_SSL_CERT_CN

```bash
openssl genrsa -out $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos.key 2048
openssl req -new -key $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos.key -out $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos.csr
```

Finally, make sure that the CSR was geenrally properly...especially the "Subject" info...

```bash
openssl req -text -noout -verify -in $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos.csr
```

## Generate the CA and self-signed certificate for the CA:

```bash
openssl genrsa -out $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos-ca.key 2048
openssl req -new -x509 -days 365 -key $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos-ca.key -out $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos-ca.crt
```

## Create final cert

Finally, sign the CSR and create the CRT:

```bash
openssl x509 -req -days 365 -CAcreateserial -CAserial $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ca.srl -in $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos.csr -CA $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos-ca.crt -CAkey $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos-ca.key -CAcreateserial -out $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos.crt
```

Checking the cert:

```bash
openssl x509 -in $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos.crt -noout -text
```

## Final recap

You should now have all the following files in $SAGDEVOPSDEMO_CONFIGS_SSL_PATH:

- ca.srl
- ssl-devsecops-clouddemos-ca.crt
- ssl-devsecops-clouddemos-ca.key
- ssl-devsecops-clouddemos.crt
- ssl-devsecops-clouddemos.csr
- ssl-devsecops-clouddemos.key

## Optional - Including attributes in openssl commands

If doing it in 1 liner using the -subj attribute:
 - Make sure to replace the COUNTRYCODE, STATE, CITY, ORG, ORG UNIT, and domain with what you want.
 - Make sure that if any of your info contains "/" characters, escape it as follows "\/"
 - make sure the CN entry matches the value in SAGDEVOPSDEMO_SSL_CERT_CN

Export Variables:

```bash
export SSL_CERT_COUNTRYCODE=<your info>
export SSL_CERT_STATE=<your info>
export SSL_CERT_CITY=<your info>
export SSL_CERT_ORG=<your info>
export SSL_CERT_ORGUNIT=<your info>
export SSL_CERT_EMAIL=<your info>
export SSL_CERT_CN=$SAGDEVOPSDEMO_SSL_CERT_CN
```

### Generate CSR

```bash
openssl genrsa -out $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos.key 2048
openssl req -new -key $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos.key -out $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos.csr -subj "/emailAddress=$SSL_CERT_EMAIL/C=$SSL_CERT_COUNTRYCODE/ST=$SSL_CERT_STATE/L=$SSL_CERT_CITY/O=$SSL_CERT_ORG/OU=$SSL_CERT_ORGUNIT/CN=$SSL_CERT_CN"
```

Verify CSR, especially the "Subject" info...

```bash
openssl req -text -noout -verify -in $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos.csr
```

### Generate the CA

```bash
openssl genrsa -out $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos-ca.key 2048
openssl req -new -x509 -days 365 -key $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos-ca.key -out $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos-ca.crt -subj "/emailAddress=$SSL_CERT_EMAIL/C=$SSL_CERT_COUNTRYCODE/ST=$SSL_CERT_STATE/L=$SSL_CERT_CITY/O=$SSL_CERT_ORG/OU=$SSL_CERT_ORGUNIT/CN=$SSL_CERT_CN"
```

### Create final cert

Finally, sign the CSR and create the CRT:

```bash
openssl x509 -req -days 365 -CAcreateserial -CAserial $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ca.srl -in $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos.csr -CA $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos-ca.crt -CAkey $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos-ca.key -CAcreateserial -out $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos.crt
```

Checking the cert:

```bash
openssl x509 -in $SAGDEVOPSDEMO_CONFIGS_SSL_PATH/ssl-devsecops-clouddemos.crt -noout -text
```