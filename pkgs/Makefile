# Craig Hesling <craig@hesling.com>
# July 29, 2016

.PHONY: all yodelgw yodelgw-compile yodelgw-environment

PKG_YODELGW_DIR     = yodelgw
PKG_YODELGW_CONTROL = $(PKG_YODELGW_DIR)/DEBIAN/control
PKG_YODELGW_NAME    = $(shell awk '/^Package: /{print $$2}' $(PKG_YODELGW_CONTROL))
PKG_YODELGW_VER     = $(shell awk '/^Version: /{print $$2}' $(PKG_YODELGW_CONTROL))
PKG_YODELGW_ARCH    = $(shell awk '/^Architecture: /{print $$2}' $(PKG_YODELGW_CONTROL))
PKG_YODELGW_FILE    = $(PKG_YODELGW_NAME)_$(PKG_YODELGW_VER)_$(PKG_YODELGW_ARCH).deb

PKG_YODELGW_COMPILE_DIR = yodelgw-compile
PKG_YODELGW_COMPILE_CONTROL = $(PKG_YODELGW_COMPILE_DIR)/yodelgw-compile.equivs
PKG_YODELGW_COMPILE_NAME = $(shell awk '/^Package: /{print $$2}' $(PKG_YODELGW_COMPILE_CONTROL))
PKG_YODELGW_COMPILE_VER = $(shell awk '/^Version: /{print $$2}' $(PKG_YODELGW_COMPILE_CONTROL))
PKG_YODELGW_COMPILE_ARCH = $(shell awk '/^Architecture: /{print $$2}' $(PKG_YODELGW_COMPILE_CONTROL))
PKG_YODELGW_COMPILE_FILE    = $(PKG_YODELGW_COMPILE_NAME)_$(PKG_YODELGW_COMPILE_VER)_$(PKG_YODELGW_COMPILE_ARCH).deb

PKG_YODELGW_ENVIRONMENT_DIR = yodelgw-environment
PKG_YODELGW_ENVIRONMENT_CONTROL = $(PKG_YODELGW_ENVIRONMENT_DIR)/yodelgw-environment.equivs
PKG_YODELGW_ENVIRONMENT_NAME = $(shell awk '/^Package: /{print $$2}' $(PKG_YODELGW_ENVIRONMENT_CONTROL))
PKG_YODELGW_ENVIRONMENT_VER = $(shell awk '/^Version: /{print $$2}' $(PKG_YODELGW_ENVIRONMENT_CONTROL))
PKG_YODELGW_ENVIRONMENT_ARCH = $(shell awk '/^Architecture: /{print $$2}' $(PKG_YODELGW_ENVIRONMENT_CONTROL))
PKG_YODELGW_ENVIRONMENT_FILE    = $(PKG_YODELGW_ENVIRONMENT_NAME)_$(PKG_YODELGW_ENVIRONMENT_VER)_$(PKG_YODELGW_ENVIRONMENT_ARCH).deb

CONF_DIR = ../conf
SRC_DIR  = ../src

LORA_GATEWAY_DIR        = $(SRC_DIR)/lora_gateway
PACKET_FORWARDER_DIR    = $(SRC_DIR)/packet_forwarder
LORA_GATEWAY_BRIDGE_DIR = $(SRC_DIR)/go/src/github.com/brocaar/lora-gateway-bridge

all: yodelgw yodelgw-compile yodelgw-environment

yodelgw: builds/$(PKG_YODELGW_NAME)_$(PKG_YODELGW_VER)_$(PKG_YODELGW_ARCH).deb

yodelgw-compile: builds/$(PKG_YODELGW_COMPILE_NAME)_$(PKG_YODELGW_COMPILE_VER)_$(PKG_YODELGW_COMPILE_ARCH).deb

yodelgw-environment: builds/$(PKG_YODELGW_ENVIRONMENT_NAME)_$(PKG_YODELGW_ENVIRONMENT_VER)_$(PKG_YODELGW_ENVIRONMENT_ARCH).deb

builds/$(PKG_YODELGW_FILE):
	# Copy over current version of packet_forwarder and lora-gateway-bridge binaries
	mkdir -p $(PKG_YODELGW_DIR)/usr/sbin
	cp $(PACKET_FORWARDER_DIR)/basic_pkt_fwd/basic_pkt_fwd $(PKG_YODELGW_DIR)/usr/sbin/
	cp $(PACKET_FORWARDER_DIR)/beacon_pkt_fwd/beacon_pkt_fwd $(PKG_YODELGW_DIR)/usr/sbin/
	cp $(PACKET_FORWARDER_DIR)/gps_pkt_fwd/gps_pkt_fwd $(PKG_YODELGW_DIR)/usr/sbin/
	cp $(LORA_GATEWAY_BRIDGE_DIR)/build/lora-gateway-bridge $(PKG_YODELGW_DIR)/usr/sbin/
	cp $(SRC_DIR)/lora_pkt_fwd $(PKG_YODELGW_DIR)/usr/sbin/
	# Copy over current version of systemd environment files
	mkdir -p $(PKG_YODELGW_DIR)/etc/packet-forwarder
	cp $(CONF_DIR)/lora-gateway-bridge.env $(PKG_YODELGW_DIR)/etc/
	cp $(CONF_DIR)/packet-forwarder.env $(PKG_YODELGW_DIR)/etc/packet-forwarder/
	# Copy over current version of packet-forwarder config files
	cp $(CONF_DIR)/global_conf.json $(PKG_YODELGW_DIR)/etc/packet-forwarder/
	cp $(CONF_DIR)/local_conf.json $(PKG_YODELGW_DIR)/etc/packet-forwarder/
	# Generating the md5sums inside the package
	cd $(PKG_YODELGW_DIR) ;	find * -type f | grep -v DEBIAN | xargs md5sum | tee DEBIAN/md5sums
	# Build the yodelgw package
	dpkg -b $(PKG_YODELGW_DIR) $(PKG_YODELGW_FILE)
	# Move the built package into the builds directory
	mv $(PKG_YODELGW_FILE) builds/

builds/$(PKG_YODELGW_COMPILE_FILE):
	# Build the yodelgw-compile package
	cd $(PKG_YODELGW_COMPILE_DIR); equivs-build $(shell basename $(PKG_YODELGW_COMPILE_CONTROL))
	# Move the built package into the builds directory
	mv $(PKG_YODELGW_COMPILE_DIR)/$(PKG_YODELGW_COMPILE_FILE) builds/

builds/$(PKG_YODELGW_ENVIRONMENT_FILE):
	# Build the yodelgw-environment package
	cd $(PKG_YODELGW_ENVIRONMENT_DIR); equivs-build $(shell basename $(PKG_YODELGW_ENVIRONMENT_CONTROL))
	# Move the built package into the builds directory
	mv $(PKG_YODELGW_ENVIRONMENT_DIR)/$(PKG_YODELGW_ENVIRONMENT_FILE) builds/
