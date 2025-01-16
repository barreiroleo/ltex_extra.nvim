#!/bin/bash
set -x

docker build -t ltex_extra .
docker run -it ltex_extra
