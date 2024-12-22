# Use an official lightweight Alpine Linux as the base image
FROM alpine:latest

# Install OpenSSL and other necessary packages
RUN apk update && apk add --no-cache openssl bash

# Create necessary directories
RUN mkdir -p /ca/{private,certs,crl,newcerts,requests} /clients/{private,certs,requests}

# Set permissions
RUN chmod 700 /ca/private
RUN chmod 700 /clients/private

# Initialize the CA directory
RUN touch /ca/index.txt
RUN echo 1000 > /ca/serial

# Copy scripts into the container
COPY scripts/ /scripts/
RUN chmod +x /scripts/*.sh

# Set default environment variables (can be overridden at runtime)
ENV COUNTRY="US" \
    STATE="State" \
    LOCALITY="City" \
    ORGANIZATION="Organization" \
    ORGANIZATIONAL_UNIT="OrgUnit" \
    COMMON_NAME="RootCA"

# Set the entrypoint
ENTRYPOINT ["/scripts/entrypoint.sh"]

# Default command
CMD ["bash"]