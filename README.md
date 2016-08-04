# Overview

A gateway contains two important services, the
[packet_forwarder](https://github.com/Lora-net/packet_forwarder) and the
[lora-gateway-bridge](https://github.com/brocaar/lora-gateway-bridge).

The `packet_forwarder`, produced by Semtech, interfaces with the SX1301
concentrator board and exposes a UDP interface. This UDP interface is
used locally by the `lora-gateway-bridge`.
The `lora-gateway-bridge` then bridges messages from the UDP to the
remote MQTT instance, where the
[loraserver](https://github.com/brocaar/loraserver) will consume them.

# General Compilation Notes

The `packet_forwarder` requires the SX1301 HAL library 
[lora_gateway](https://github.com/Lora-net/lora_gateway)
to be in the parent directory. Both the lora_gateway and 
packet_forwarder should compile with nothing more than the
`build-essential` package installed.

The `lora-gateway-bridge` requires a newer version of golang than
what is supplied with Debian jessie (golang 1.3.3), since it uses
some newer base64 library features. It will fail to compile with 1.3.3.
To fix this issue, upgrade the Raspbian release to stretch, which has
golang 1.6.1.

------

# Organization

* pkgs: Contains the Debian packages to bring up a new Yodel gateway.
* conf: Configuration files needed by the services
