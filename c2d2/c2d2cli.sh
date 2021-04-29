#!/usr/bin/env bash

docker run -it --entrypoint=""  -v "$HOME/.c2d2cli":/root/.c2d2cli --add-host=host.docker.internal:host-gateway axelar/c2d2cli:latest bash
