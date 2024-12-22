#!/bin/bash
set -e

# Variables
CLIENT_NAME=$1
if [ -z "$CLIENT_NAME" ]; then
  echo "Usage: $0 <client_name>"
  exit 1
fi

CA_KEY="/ca/private/ca.key.pem"
CA_CERT="/ca/certs/ca.cert.pem"
CONFIG="/ca/openssl.cnf"
CLIENT_KEY="/clients/private/${CLIENT_NAME}.key.pem"
CLIENT_REQ="/clients/requests/${CLIENT_NAME}.csr.pem"
CLIENT_CERT="/clients/certs/${CLIENT_NAME}.cert.pem"

# Ensure the CA certificate exists
if [ ! -f "$CA_CERT" ]; then
  echo "Root CA certificate not found at $CA_CERT. Generate it first."
  exit 1
fi

# Generate client private key
openssl genrsa -out $CLIENT_KEY 2048
chmod 400 $CLIENT_KEY
echo "Client private key generated at $CLIENT_KEY"

# Create client CSR
openssl req -config $CONFIG \
      -key $CLIENT_KEY \
      -new -sha256 \
      -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${ORGANIZATIONAL_UNIT}/CN=${CLIENT_NAME}" \
      -out $CLIENT_REQ

echo "Client CSR generated at $CLIENT_REQ"

# Sign the client CSR with CA
openssl ca -batch -config $CONFIG \
      -extensions usr_cert \
      -days 375 -notext -md sha256 \
      -in $CLIENT_REQ \
      -out $CLIENT_CERT

chmod 444 $CLIENT_CERT
echo "Client certificate generated at $CLIENT_CERT"