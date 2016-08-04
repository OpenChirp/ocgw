# Craig Hesling <craig@hesling.com>
# July 29, 2016

.PHONY: all yodelgw

PKG_YODELGW_DIR = yodelgw
PKG_YODELGW_CONTROL = $(PKG_YODELGW_DIR)/DEBIAN/control
PKG_YODELGW_NAME = $(shell awk '/Package: /{print $$2}' $(PKG_YODELGW_CONTROL))
PKG_YODELGW_VER = $(shell awk '/Version: /{print $$2}' $(PKG_YODELGW_CONTROL))
PKG_YODELGW_ARCH = $(shell awk '/Architecture: /{print $$2}' $(PKG_YODELGW_CONTROL))

all: yodelgw

yodelgw:
	cd $(PKG_YODELGW_DIR) ;	find * -type f | grep -v DEBIAN | xargs md5sum | tee DEBIAN/md5sums
	dpkg -b $(PKG_YODELGW_DIR) $(PKG_YODELGW_NAME)_$(PKG_YODELGW_VER)_$(PKG_YODELGW_ARCH).deb
