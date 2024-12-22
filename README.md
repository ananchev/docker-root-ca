# docker-root-ca
Docker solution to generate a Root Certificate Authority (CA) and issue client certificates utilizing *OpenSSL*

## Features
* Create automatically a root CA with customizable details.
* Issue client certificates signed by the root CA.
* Customize certificate details via environment variables.
* Store CA and client data outside the container for persistence.

## Directory Structure
```
|-- Dockerfile
|-- scripts
|   |-- entrypoint.sh
|   |-- generate_root_ca.sh
|   |-- issue_client_cert.sh
|   `-- verify_cert.sh
|-- .gitignore
`-- .env
```

- `Dockerfile`: Defines the Docker image setup.
- `scripts/`: Contains the scripts for CA and certificate management.
  - `entrypoint.sh`: Initializes the Root CA upon container start.
  - `generate_root_ca.sh`: Generates the Root CA private key and certificate.
  - `issue_client_cert.sh`: Issues client certificates using the Root CA.
  - `verify_cert.sh`: Verifies certificates against the Root CA.
- `.gitignore`: Sensitive directories and files are not tracked by Git.
- `.env`: Environment variables file. Must be created manually.

##  Environment Variables
Create the ```.env``` file based on below example. This file will hold the dynamic configuration of certificates.
```env
# Certificate Details
COUNTRY=US
STATE=California
LOCALITY=San Francisco
ORGANIZATION=MyOrganization
ORGANIZATIONAL_UNIT=ITDepartment
COMMON_NAME=MyRootCA
```

## Build the Docker image
From the root directory:
```shell
docker build -t my-root-ca .
```

## Running the container
1. Prepare directories & files

Create directories on the host machine to store CA and client data. Will be mounted as volumes to persist data outside the container.
```shell
mkdir -p ca_data/certs ca_data/private ca_data/newcerts ca_data/crl clients_data/certs clients_data/private clients_data/requests 
```
Create and initialize index.txt and serial files on the host
```shell
touch ca_data/index.txt
echo 1000 > ca_data/serial
```
Initialize the crlnumber file that keeps track of CRL versions
```shell
echo 1000 > ca_data/crl/crlnumber
chmod 644 ca_data/crl/crlnumber
```


2. Run the container

Execute from project's root directory and with the .env file ready:
```shell
docker run --rm -it --name my-ca \
  -v $(pwd)/ca_data:/ca:Z \
  -v $(pwd)/clients_data:/clients:Z \
  --env-file .env \
  my-root-ca
```
This command will start the container and drop into a Bash shell to execute certificate management commands.

## Intended Usage

The Docker container is meant to be used interactively. Once the container is run, drop into a Bash shell to execute  the scripts to generate and manage your Root CA and client certificates:
* Generate root CA: Initialize the CA when needed.
* Issue Certificates: Create client certificates based on current requirements.
* Verify Certificates: Ensure the integrity and validity of generated certificates.
After generated the necessary certificates, the container is intended to be decommissioned. Simply type ```exit``` or press ```Ctrl+D``` to leave the container's shell and remove the container.

All sensitive data, including the root CA's private key and certificates, and the client certificates, are persisted on the host through mounted volumes. 

## Managing Certificates

### Generate Root CA
The Root CA is automatically generated when the container starts if it doesn't already exist.
#### Output
* OpenSSL configuration generated at ```/ca/openssl.cnf```, on the host under ```$(pwd)/ca_data/openssl.cnf```
* CA private key generated at ```/ca/private/ca.key.pem```, on the host under ```$(pwd)/ca_data/private/ca.key.pem```
* Root CA certificate generated at ```/ca/certs/ca.cert.pem```, on the host under ```$(pwd)/ca_data/certs/ca.key.pem```

### Issue a client certificate
Executing the ```issue_client_cert.sh``` script followed by the desired client name issues a client certificate. Example for ```client1```:
```shell
/scripts/issue_client_cert.sh client1
```

#### Output
* Client certificate generated at ```/clients/certs/client1.cert.pem```, on the host under ```$(pwd)/clients_data/certs/client1.cert.pem```

### Verify a certificate
To verify a client certificate against the Root CA, use the ```verify_cert.sh``` script with the path to the certificate.
Example for verifying ```client1's``` certificate
```shell
/scripts/verify_cert.sh /clients/certs/client1.cert.pem
```

#### Output
* ```/ca/certs/ca.cert.pem: OK```

### Revoke a certificate
To revoke a specified client certificate and update the certificate revocation list (CRL) use the ``` ``` scriot with the client's certificate name
```shell
/scripts/revoke_client_cert.sh client1
```

#### Output
* Certificate for ```client1``` has been revoked
* Certificate Revocation List (CRL) updated at ```/ca/cr/ca.crl.pem```

### Verify CRL
Verify the CRL to check the revocations:
```shell
openssl crl -in /ca/crl/ca.crl.pem -noout -text
```

#### Output
The command will display a detailed, human-readable view of the certificate revocation list.

## Security Considerations
* Ensure that the ca_data and clients_data directories on the host have strict permissions (```chmod 700```) to prevent unauthorized access
* Regularly back up the ```ca_data``` and ```clients_data``` directories to prevent data loss
* Restrict access to the Docker container and the host mounts to trusted users only