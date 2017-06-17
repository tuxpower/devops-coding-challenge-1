#!/usr/bin/env bash
# Author: Jose Gaspar <jad.gaspar@gmail.com>

# set default args
INTERVAL=10

if [[ $# > 0 ]]; then
  INTERVAL="$1"
fi

while true; do
  CONTAINER_ID=$(sudo docker ps -q --filter \"status=running\" --filter=\"name=my-nginx\")
  RUNNING=$(sudo docker inspect -f {{.State.Running}} ${CONTAINER_ID})

  if [[ ! $RUNNING ]]; then
	cd /devops-coding-challenge-1
	ansible-playbook web.yml
  else
	echo "Nginx container is running with ID ${CONTAINER_ID}"
  fi
  sleep ${INTERVAL}
done
