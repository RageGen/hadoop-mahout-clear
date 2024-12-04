#!/bin/bash

IMAGE_NAME="hadoop_mahout_image"
CONTAINER_NAME="hadoop_mahout"

echo "Building Docker image..."
docker build -t $IMAGE_NAME .

if [ $? -ne 0 ]; then
    echo "Docker build failed. Exiting..."
    exit 1
fi

echo "Starting Docker container..."
docker run -d --name $CONTAINER_NAME \
    -p 9870:9870 -p 9000:9000  -p 9864:9864 -p 9866:9866 -p 8080:8080 -p 4040:4040 -p 8020:8020\
    -v ./lab5:/lab5 \
    -v ./lab6:/lab6 \
    --hostname localhost \
    $IMAGE_NAME

if [ $? -ne 0 ]; then
    echo "Failed to start Docker container. Exiting..."
    exit 1
fi

echo "Docker container started successfully!"
