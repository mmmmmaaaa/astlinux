#############################################################
#
# syslinux to make target msdos/iso9660 filesystems bootable
#
#############################################################

SYSLINUX_VERSION = 3.86
SYSLINUX_SOURCE  = syslinux-$(SYSLINUX_VERSION).tar.bz2
SYSLINUX_SITE    = $(BR2_KERNEL_MIRROR)/linux/utils/boot/syslinux/3.xx/

SYSLINUX_INSTALL_TARGET = NO
SYSLINUX_INSTALL_IMAGES = YES

SYSLINUX_DEPENDENCIES = host-nasm

HOST_SYSLINUX_DEPENDENCIES = host-nasm

define SYSLINUX_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CC="$(HOSTCC)" AR="$(HOSTAR)" -C $(@D)
endef

SYSLINUX_IMAGES-$(BR2_TARGET_SYSLINUX_ISOLINUX) += isolinux.bin
SYSLINUX_IMAGES-$(BR2_TARGET_SYSLINUX_PXELINUX) += pxelinux.bin

define SYSLINUX_INSTALL_IMAGES_CMDS
	for i in $(SYSLINUX_IMAGES-y); do \
		$(INSTALL) -D -m 0755 $(@D)/core/$$i $(BINARIES_DIR)/$$i; \
	done
endef

define HOST_SYSLINUX_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)
endef

define HOST_SYSLINUX_INSTALL_CMDS
	$(INSTALL) -D -m 0755 $(@D)/linux/syslinux $(HOST_DIR)/usr/sbin/syslinux
endef

$(eval $(call GENTARGETS,boot,syslinux))
$(eval $(call GENTARGETS,boot,syslinux,host))
