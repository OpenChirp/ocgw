# Instructions

Pre-built packages can be found in the `builds` directory.

# Packages

### yodelgw

This package contains the minimal gateway services and configuration.

The dependency for `swig`, `python-dev`, and `WiringPi` come
from the [LinkLabs install script](https://github.com/mirakonta/Raspberry-PI-Link-Labs-LoRaWAN-Gateway/blob/spi/install.sh).

The following is a list of it's responsibilities:
* Create symbolic link and set permissions for rtl sdr (group is "sdr")
* Force the old eth0 naming
* Enable console on FTDI usb to serial adapter hot plug
* Set preference (downgrade priority) for older wireless firmware
* Add systemd services for lora-gateway-bridge and packet-forwarder
* Added systemd dependency to fix wait for network
* Provide binaries for lora-gateway-bridge and packet-forwarder services
* Enable systemd watchdog

### yodelgw-compile

This package depends on other packages needed to build the gateway services.

### yodelgw-environment

This package depends on packages that are unnecessary to the core gateway
services, but support a nice interactive console environment.
