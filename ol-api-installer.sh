#!/bin/bash

# Default network name and subnet
NETWORK_NAME="osint_liar_network"
SUBNET="192.168.100.0/24"
CONTAINER_NAME="osint-liar-api"
IMAGE_NAME="osintliar/osint-liar-api:latest"
PORT=9906
FIXED_IP="192.168.100.100"
VOLUME_NAME="osint_liar_home"

# Check if the network already exists, if not, create it
docker network ls | grep -q "$NETWORK_NAME"
if [ $? -ne 0 ]; then
    echo "Creating Docker network: $NETWORK_NAME with subnet $SUBNET"
    docker network create --subnet=$SUBNET $NETWORK_NAME
else
    echo "Docker network $NETWORK_NAME already exists."
fi

# Prompt for email addresses
read -p "Enter comma-separated email addresses for USERS environment variable: " USERS

# Run the Docker container
echo "Pulling the latest Docker image..."
docker pull $IMAGE_NAME
# remove the old container
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true
echo "Starting the Docker container..."
docker run -d \
  --name=$CONTAINER_NAME \
  --network=$NETWORK_NAME \
  --ip=$FIXED_IP \
  -p $PORT:$PORT \
  -e USERS="$USERS" \
  -v $VOLUME_NAME:/home/lia \
  $IMAGE_NAME

if [ $? -eq 0 ]; then
    echo "OSINT LIAR API container started successfully. Access it at http://$FIXED_IP:$PORT."
else
    echo "Failed to start the OSINT LIAR API container."
fi
