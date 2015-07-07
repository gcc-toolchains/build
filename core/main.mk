#
# Copyright (C) 2015 The Yudatun Open Source Project
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation


TOP := .
TOPDIR :=

BUILD_SYSTEM := $(TOPDIR)build/core

# ----------------------------------------------------------
# Set up various standard variables based on configuration
# and host informations.
include $(BUILD_SYSTEM)/config.mk

.PHONY: all clean

all: build

build: build-target-binutils build-target-gcc \
    build-target-gdb

install: install-target-binutils install-target-gcc \
    install-target-gdb

# target gold rules.  We need these only if BINUTILS_VERSION != GOLD_VERSION
ifneq ($(BINUTILS_VERSION), $(GOLD_VERSION))
build: build-target-gold
install: install-target-gold
endif

include $(BUILD_SYSTEM)/Makefile

.PHONY: clean
clean:
	$(RM) -r $(TEMP_INSTALLDIR) $(TARGET_OUT_ROOT)/stamp-* && \
	for sub in [ ${TARGET_OUT_ROOT}/* ] ; do \
	  if [ -f $$sub/Makefile ] ; then \
	    $(MAKE) -C $$sub clean ; \
	  fi; \
	done

.PHONY: distclean
distclean:
	$(RM) -r $(TEMP_INSTALLDIR) $(TARGET_OUT_ROOT)/stamp-* && \
	for sub in [ ${TARGET_OUT_ROOT}/* ] ; do \
	  if [ -f $$sub/config.status ] ; then \
	    echo "Deleting " $$sub "..." && $(RM) -r $$sub ; \
	  fi; \
	done
	@$(RM) -r $(TOOLCHAINS_PREFIX)
