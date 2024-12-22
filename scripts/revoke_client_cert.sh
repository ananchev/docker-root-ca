#!/bin/bash
set -e

# Usage: ./revoke_client_cert.sh <client_name>

CLIENT_NAME=$1
if [ -z "$CLIENT_NAME" ]; then
  echo "Usage: $0 <client_name>"
  exit 1
fi

CA_KEY="/ca/private/ca.key.pem"
CA_CERT="/ca/certs/ca.cert.pem"
CONFIG="/ca/openssl.cnf"
CLIENT_CERT="/clients/certs/${CLIENT_NAME}.cert.pem"
CRL_FILE="/ca/crl/ca.crl.pem"

# Check if the client certificate exists
if [ ! -f "$CLIENT_CERT" ]; then
  echo "Error: Client certificate not found at $CLIENT_CERT"
  exit 1
fi

# Revoke the client certificate
openssl ca -config "$CONFIG" -revoke "$CLIENT_CERT"

echo "Certificate for '$CLIENT_NAME' has been revoked."

# Generate an updated CRL
openssl ca -config "$CONFIG" -gencrl -out "$CRL_FILE"

echo "Certificate Revocation List (CRL) updated at $CRL_FILE."