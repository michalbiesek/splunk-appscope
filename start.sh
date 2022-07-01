#!/bin/bash
source .env

KEY_CERT_DIR="/opt/"
PRIVATE_KEY_NAME="domain.key"
CERT_NAME="domain.crt"

#######################################
# Copy private key to specific docker container
# Arguments:
#   Name of the docker container
#######################################
copy_key () {
    local output_dir=$1:$KEY_CERT_DIR

    echo "Copying the TLS private key to $output_dir"
    docker cp $PRIVATE_KEY_NAME $output_dir$PRIVATE_KEY_NAME
}

#######################################
# Generate ssh key
# Arguments:
#   Username
#######################################
ssh_new_keys () {
    local user_name=$1
    local key_name=${user_name}_key
    local pub_key=${key_name}.pub

    echo "Generate key $key_name"

    ssh-keygen -q -t rsa -b 4096 -f $key_name -P ""
    cp $pub_key images
}

#######################################
# Delete duplicate public key
# Arguments:
#   Username
#######################################
ssh_rm_dup_public_key () {
    local pub_key=${1}_key.pub

    echo "Remove key $pub_key"

    rm images/${pub_key}
}

#######################################
# Copy certificate to specific docker container
# Arguments:
#   Name of the docker container
#######################################
copy_cert () {
    local output_dir=$1:$KEY_CERT_DIR

    echo "Copying the TLS certificate to $output_dir"
    docker cp $CERT_NAME $output_dir$CERT_NAME
}

echo "Start generate private & public keys"
ssh_new_keys "foouser" "appscope_sshd" 
ssh_new_keys "baruser" "appscope_sshd" 

echo "Start docker compose"
docker-compose --env-file .env up -d --build

echo "Remove duplicate public keys"
ssh_rm_dup_public_key "foouser"
ssh_rm_dup_public_key "baruser"

echo "Copying the Cribl Configuration"
docker cp cribl/ cribl01:/opt/cribl/local/

echo "Generate TLS keys"
openssl req -newkey rsa:2048 -nodes -keyout $PRIVATE_KEY_NAME -x509 -days 365 -out $CERT_NAME -subj "/C=PL/ST=Warsaw/L=GoatTown/O=Cribl/OU=Appscope/CN=cribl.io"

copy_key "cribl01"
copy_cert "cribl01"
copy_cert "appscope01_tls"

printf '\n'
echo "Demo is ready."
echo "To use TCP:"
echo "To start scoping bash session run: 'docker-compose run appscope01'"
echo "To start scoping individual commands run: 'docker exec -it appscope02 bash' and use ldscope/scope"
echo "To use TLS:"
echo "To start scoping individual commands run: 'docker exec -it appscope01_tls bash' and use ldscope/scope"
echo "To use SSHD:"
echo "To start scoping individual commands run: 'docker exec -it appscope_sshd bash' and use ldscope/scope"
echo "To connect via ssh to appscope_sshd:"
echo "To start scoping individual commands run: 'docker exec -it appscope_sshd bash' and use ldscope/scope"
echo "'ssh foouser@localhost -i foouser_key -p 2022' pass:foouser"
echo "'ssh baruser@localhost -i baruser_key -p 2022' pass:baruser"
