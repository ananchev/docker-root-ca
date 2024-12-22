#!/bin/bash
set -e

# Retrieve environment variables with default values
COUNTRY=${COUNTRY:-"US"}
STATE=${STATE:-"State"}
LOCALITY=${LOCALITY:-"City"}
ORGANIZATION=${ORGANIZATION:-"Organization"}
ORGANIZATIONAL_UNIT=${ORGANIZATIONAL_UNIT:-"OrgUnit"}
COMMON_NAME=${COMMON_NAME:-"RootCA"}

# Variables
CA_KEY="/ca/private/ca.key.pem"
CA_CERT="/ca/certs/ca.cert.pem"
CONFIG="/ca/openssl.cnf"

# Generate CA private key if it doesn't exist
if [ ! -f "$CA_KEY" ]; then
  openssl genrsa -out $CA_KEY 4096
  chmod 400 $CA_KEY
  echo "CA private key generated at $CA_KEY"
else
  echo "CA private key already exists at $CA_KEY"
fi

# Create  OpenSSL config file for CA with environment variables
cat > $CONFIG <<EOF
[ ca ]
default_ca = CA_default

[ CA_default ]
dir               = /ca
certs             = \$dir/certs
crl_dir           = \$dir/crl
database          = \$dir/index.txt
new_certs_dir     = \$dir/newcerts
serial            = \$dir/serial
RANDFILE          = \$dir/private/.rand

private_key       = \$dir/private/ca.key.pem
certificate       = \$dir/certs/ca.cert.pem

default_md        = sha256

name_opt          = ca_default
cert_opt          = ca_default
default_days      = 3650
preserve          = no
policy            = policy_strict

[ policy_strict ]
countryName             = match
stateOrProvinceName     = match
organizationName        = match
organizationalUnitName  = optional
commonName              = supplied
emailAddress            = optional

[ req ]
default_bits        = 4096
distinguished_name  = req_distinguished_name
string_mask         = utf8only
default_md          = sha256

[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
stateOrProvinceName             = State or Province Name
localityName                    = Locality Name
organizationName                = Organization Name
organizationalUnitName          = Organizational Unit Name
commonName                      = Common Name

[ v3_ca ]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, keyCertSign, cRLSign

[ usr_cert ]
basicConstraints = CA:FALSE
nsCertType = client, email
nsComment = "OpenSSL Generated Client Certificate"
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection

[ crl_ext ]
authorityKeyIdentifier=keyid:always,issuer
EOF

echo "OpenSSL configuration generated at $CONFIG"

# Generate CA certificate if it doesn't exist
if [ ! -f "$CA_CERT" ]; then
  openssl req -config $CONFIG \
        -key $CA_KEY \
        -new -x509 -days 3650 -sha256 -extensions v3_ca \
        -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$COMMON_NAME" \
        -out $CA_CERT

  chmod 444 $CA_CERT
  echo "Root CA certificate generated at $CA_CERT"
else
  echo "Root CA certificate already exists at $CA_CERT"
fi