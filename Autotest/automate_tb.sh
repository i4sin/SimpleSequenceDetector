#!/usr/bin/env bash
set -eu
# DIR=$(dirname "${BASH_SOURCE[0]}")
# REPO=$(readlink -f $DIR/../../..)
# source $REPO/Utils/utility-scripts.sh
# set_prompt

# QUESTA_DOCKER_AUTHORIZED_KEYS_FILE=$REPO/AutoTest/keys/fabric_key.pub

main() {
    trap remove_docker EXIT

    xhost +local:docker

    CONTAINER_ID=$(docker run --mac-address "00:0c:29:31:ad:65" \
        -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix \
        -p 10022:22 \
        --detach \
        -v /home/yasin/projects/RTL/:/workspace \
        questasim-10.7c-automation:0.1.0)

    # AUTHORIZED_KEYS=$(cat $QUESTA_DOCKER_AUTHORIZED_KEYS_FILE)
    # docker exec $CONTAINER_ID /bin/bash -c "echo $AUTHORIZED_KEYS >> /root/.ssh/authorized_keys"
    docker exec $CONTAINER_ID /bin/bash -c "echo export DISPLAY=$DISPLAY >> /root/.profile"

    docker exec -it $CONTAINER_ID /bin/bash || true
    # docker exec -it $CONTAINER_ID /bin/bash -c 'vsim -c -do "vlib work; vlog ALU.sv ALU_tb.sv; vsim work.ALU_tb; run -all; quit"' || true
}

remove_docker() {
    docker stop $CONTAINER_ID
    docker rm $CONTAINER_ID
}

main
