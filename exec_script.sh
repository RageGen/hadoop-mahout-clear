#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Использование: ./exec_script.sh <script_name> <container_id>"
  exit 1
fi

SCRIPT_NAME=$1
CONTAINER_NAME=$2

docker exec "$CONTAINER_NAME" python3 "/scripts/$SCRIPT_NAME"
