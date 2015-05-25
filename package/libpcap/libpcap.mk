#############################################################
#
# libpcap
#
#############################################################

LIBPCAP_VERSION = 1.7.3
LIBPCAP_SITE = http://www.tcpdump.org/release
LIBPCAP_SOURCE = libpcap-$(LIBPCAP_VERSION).tar.gz
LIBPCAP_INSTALL_STAGING = YES
LIBPCAP_DEPENDENCIES = zlib host-flex host-bison

# We're patching configure.in
LIBPCAP_AUTORECONF = YES
LIBPCAP_CONF_ENV = \
	ac_cv_linux_vers=2 \
	ac_cv_header_linux_wireless_h=yes \
	CFLAGS="$(LIBPCAP_CFLAGS)"
LIBPCAP_CFLAGS = $(TARGET_CFLAGS)
LIBPCAP_CONF_OPT = --disable-yydebug --with-pcap=linux

# Omit -rpath from pcap-config output
define LIBPCAP_CONFIG_REMOVE_RPATH
	$(SED) 's/^V_RPATH_OPT=.*/V_RPATH_OPT=""/g' $(@D)/pcap-config
endef
LIBPCAP_POST_BUILD_HOOKS = LIBPCAP_CONFIG_REMOVE_RPATH

# On purpose, not compatible with bluez5
ifeq ($(BR2_PACKAGE_BLUEZ_UTILS),y)
LIBPCAP_DEPENDENCIES += bluez_utils
else
LIBPCAP_CONF_OPT += --disable-bluetooth
endif

ifeq ($(BR2_PACKAGE_DBUS),y)
LIBPCAP_CONF_OPT += --enable-dbus
LIBPCAP_DEPENDENCIES += dbus
else
LIBPCAP_CONF_OPT += --disable-dbus
endif

ifeq ($(BR2_PACKAGE_LIBUSB),y)
LIBPCAP_CONF_OPT += --enable-canusb
LIBPCAP_DEPENDENCIES += libusb
else
LIBPCAP_CONF_OPT += --disable-canusb
endif

ifeq ($(BR2_PACKAGE_LIBNL),y)
LIBPCAP_DEPENDENCIES += libnl
LIBPCAP_CFLAGS += "-I$(STAGING_DIR)/usr/include/libnl3"
else
LIBPCAP_CONF_OPT += --without-libnl
endif

define LIBPCAP_STAGING_FIXUP_PCAP_CONFIG
        $(SED) "s,prefix=\"/usr\",prefix=\"$(STAGING_DIR)/usr\",g" $(STAGING_DIR)/usr/bin/pcap-config
endef
LIBPCAP_POST_INSTALL_STAGING_HOOKS += LIBPCAP_STAGING_FIXUP_PCAP_CONFIG

define LIBPCAP_TARGET_REMOVE_PCAP_CONFIG
        rm -f $(TARGET_DIR)/usr/bin/pcap-config
endef
LIBPCAP_POST_INSTALL_TARGET_HOOKS += LIBPCAP_TARGET_REMOVE_PCAP_CONFIG

$(eval $(call AUTOTARGETS,package,libpcap))
