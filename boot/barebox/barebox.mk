#############################################################
#
# Barebox
#
#############################################################

BAREBOX_VERSION = 2011.08.0
BAREBOX_SOURCE = barebox-$(BAREBOX_VERSION).tar.bz2
BAREBOX_SITE = http://www.barebox.org/download/

BAREBOX_INSTALL_IMAGES = YES
ifneq ($(BR2_TARGET_BAREBOX_BAREBOXENV),y)
BAREBOX_INSTALL_TARGET = NO
endif

BAREBOX_BOARD_DEFCONFIG = $(call qstrip,$(BR2_TARGET_BAREBOX_BOARD_DEFCONFIG))

ifeq ($(KERNEL_ARCH),i386)
BAREBOX_ARCH=x86
else ifeq ($(KERNEL_ARCH),powerpc)
BAREBOX_ARCH=ppc
else
BAREBOX_ARCH=$(KERNEL_ARCH)
endif

BAREBOX_MAKE_FLAGS = ARCH=$(BAREBOX_ARCH) CROSS_COMPILE="$(CCACHE) $(TARGET_CROSS)"

define BAREBOX_CONFIGURE_CMDS
	$(MAKE) $(BAREBOX_MAKE_FLAGS) -C $(@D) $(BAREBOX_BOARD_DEFCONFIG)_defconfig
endef

ifeq ($(BR2_TARGET_BAREBOX_BAREBOXENV),y)
define BAREBOX_BUILD_BAREBOXENV_CMDS
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) -o $(@D)/bareboxenv \
		$(@D)/scripts/bareboxenv.c
endef
endif

define BAREBOX_BUILD_CMDS
	$(BAREBOX_BUILD_BAREBOXENV_CMDS)
	$(MAKE) $(BAREBOX_MAKE_FLAGS) -C $(@D)
endef

define BAREBOX_INSTALL_IMAGES_CMDS
	cp $(@D)/barebox.bin $(BINARIES_DIR)
endef

ifeq ($(BR2_TARGET_BAREBOX_BAREBOXENV),y)
define BAREBOX_INSTALL_TARGET_CMDS
	cp $(@D)/bareboxenv $(TARGET_DIR)/usr/bin
endef
endif

$(eval $(call GENTARGETS,boot,barebox))

ifeq ($(BR2_TARGET_BAREBOX),y)
# we NEED a board defconfig file unless we're at make source
ifeq ($(filter source,$(MAKECMDGOALS)),)
ifeq ($(BAREBOX_BOARD_DEFCONFIG),)
$(error No Barebox defconfig file. Check your BR2_TARGET_BAREBOX_BOARD_DEFCONFIG setting)
endif
endif

barebox-menuconfig barebox-xconfig barebox-gconfig barebox-nconfig: barebox-configure
	$(MAKE) $(BAREBOX_MAKE_FLAGS) -C $(BAREBOX_DIR) \
		$(subst barebox-,,$@)
	rm -f $(BAREBOX_DIR)/.stamp_{built,target_installed,images_installed}

barebox-savedefconfig: barebox-configure
	$(MAKE) $(BAREBOX_MAKE_FLAGS) -C $(BAREBOX_DIR) \
		$(subst barebox-,,$@)

endif
