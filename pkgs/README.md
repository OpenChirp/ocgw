# Instructions

Pre-built packages can be found in the `builds` directory.

# Packages

### yodelgw

This package contains the minimal gateway services and configuration.

The dependency for `swig`, `python-dev`, and `WiringPi` come
from the [LinkLabs install script](https://github.com/mirakonta/Raspberry-PI-Link-Labs-LoRaWAN-Gateway/blob/spi/install.sh).

### yodelgw-compile

This package depends on other packages needed to build the gateway services.

### yodelgw-environment

This package depends on packages that are unnecessary to the core gateway
services, but support a nice interactive console environment.
