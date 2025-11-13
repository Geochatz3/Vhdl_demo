#!/usr/bin/env bash
# Use GHDL from Docker, working in the current directory

docker run --rm \
  -v "$(pwd)":/work \
  -w /work \
  ghdl/ghdl:6.0.0-dev-gcc-ubuntu-22.04 \
  ghdl "$@"
