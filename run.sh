#!/bin/bash
docker run --rm -it --name my-ca \
  -v $(pwd)/ca_data:/ca \
  -v $(pwd)/clients_data:/clients \
  --env-file .env \
  my-root-ca