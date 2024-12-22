#!/bin/bash
set -e

CERT_TO_VERIFY=$1
CA_CERT="/ca/certs/ca.cert.pem"

if [ -z "$CERT_TO_VERIFY" ]; then
  echo "Usage: $0 <certificate_to_verify>"
  exit 1
fi

openssl verify -CAfile $CA_CERT $CERT_TO_VERIFY