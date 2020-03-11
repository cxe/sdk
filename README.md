# @cxe/sdk
Dockerized Software Development Kit

## Download and Installation
```
mkdir -p ~/.cxe && \
    wget https://raw.githubusercontent.com/cxe/sdk/master/cli -O ~/.cxe/cli && \
    chmod +x ~/.cxe/cli && \
    ~/.cxe/cli --install
```

## Getting Started
```
# learn more about the commandline options
cxe --help

# start an interactive terminal in a docker image mounting the current working directory
cxe node:latest
```
