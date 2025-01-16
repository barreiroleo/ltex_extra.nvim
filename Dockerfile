FROM ubuntu
WORKDIR plugin

RUN apt-get update && apt-get -y --no-install-recommends install \
    bash build-essential curl git software-properties-common \
    luarocks openjdk-21-jre \
    neovim

COPY . .
CMD nvim -u test/repro.lua
