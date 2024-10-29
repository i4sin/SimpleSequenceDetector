#!/usr/bin/env bash
set -eu

docker build --network host \
    -t questasim-10.7c-automation:0.1.0 \
    .

# `--network host` is used for proxy. Read following link for more information:
# https://stackoverflow.com/questions/61590317/use-socks5-proxy-from-host-for-docker-build
