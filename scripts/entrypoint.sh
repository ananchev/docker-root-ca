#!/bin/bash
set -e

# Generate Root CA
/scripts/generate_root_ca.sh

# Execute the provided command
exec "$@"