#!/bin/bash
set -e

# Apt doesn't need anything special when building

tag=latest
if [[ "$1" != "" ]]; then
  tag="$1"
fi

# Build the image
echo "INFO: Building image: breqwatr-apt:$tag"
docker build -t breqwatr/apt:$tag .
