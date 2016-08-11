PKG_DIR = ../../pkgs
PKG_BUILDS = $(PKG_DIR)/builds

# yodelgw package info
PKG_YODELGW_DIR     = $(PKG_DIR)/yodelgw
PKG_YODELGW_CONTROL = $(PKG_YODELGW_DIR)/DEBIAN/control
PKG_YODELGW_NAME    = $(shell awk '/^Package: /{print $$2}' $(PKG_YODELGW_CONTROL))
PKG_YODELGW_VER     = $(shell awk '/^Version: /{print $$2}' $(PKG_YODELGW_CONTROL))
PKG_YODELGW_ARCH    = $(shell awk '/^Architecture: /{print $$2}' $(PKG_YODELGW_CONTROL))
PKG_YODELGW_FILE    = $(PKG_YODELGW_NAME)_$(PKG_YODELGW_VER)_$(PKG_YODELGW_ARCH).deb

PAYLOAD_FILES += gwsetup_extra_payload $(PKG_BUILDS)/$(PKG_YODELGW_FILE)

GWSETUP_SCRIPT = script.bash

gwsetup: $(GWSETUP_SCRIPT) $(PAYLOAD_FILES)
	cp $(GWSETUP_SCRIPT) gwsetup
	echo "PAYLOAD:" >> $@
	tar -czv $(PAYLOAD_FILES) | base64 >> $@
