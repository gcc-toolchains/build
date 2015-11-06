#
# Copyright (C) 2015 The Yudatun Open Source Project
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation
#

#
# the setpath shell function in envsetup.sh uses this
# to figure out what to add to the path given the config
# we have chosen.
#

ifeq ($(CALLED_FROM_SETUP), true)

dumpvar_goals := \
    $(strip $(patsubst dumpvar-%,%,$(filter dumpvar-%,$(MAKECMDGOALS))))
ifdef dumpvar_goals
  ifneq ($(words $(dumpvar_goals)),1)
    $(error Only one "dumpvar-" goal allowed. Saw "$(MAKECMDGOALS)")
  endif

  # If the goal is of the form "dumpvar-abs-VARNAME", then
  # treat VARNAME as a path and return the absolute path to it.
  absolute_dumpvar := $(strip $(filter abs-%,$(dumpvar_goals)))
  ifdef absolute_dumpvar
    dumpvar_goals := $(patsubst abs-%,%,$(dumpvar_goals))
    ifneq ($(filter /%,$($(dumpvar_goals))),)
      DUMPVAR_VALUE := $($(dumpvar_goals))
    else
      DUMPVAR_VALUE := $(PWD)/$($(dumpvar_goals))
    endif
    dumpvar_target := dumpvar-abs-$(dumpvar_goals)
  else
    DUMPVAR_VALUE := $($(dumpvar_goals))
    dumpvar_target := dumpvar-$(dumpvar_goals)
  endif

.PHONY: $(dumpvar_target)
$(dumpvar_target):
	@echo $(DUMPVAR_VALUE)
endif # dumpvar_goals

ifneq ($(dumpvar_goals),report_config)
PRINT_BUILD_CONFIG :=
endif

endif # CALLED_FROM_SETUP

ifneq ($(PRINT_BUILD_CONFIG),)
$(info )
$(info +++++++++++++++++++++++++++++++++)
$(info WITH_SYSROOT=$(WITH_SYSROOT))
$(info TARGET=$(TARGET))
$(info TARGET_TOOLCHAINS_ARCH=$(TARGET_TOOLCHAINS_ARCH))
$(info TARGET_OS=$(TARGET_OS))
$(info TARGET_LIBC=$(TARGET_LIBC))
$(info TARGET_BUILD_APP=$(TARGET_BUILD_APP))
$(info BUILD_OS=$(BUILD_OS))
$(info BUILD_ARCH=$(BUILD_ARCH))
$(info ENABLE_GRAPHITE=$(ENABLE_GRAPHITE))
$(info ENABLE_GRAPHITE_USE_CLOOG=$(ENABLE_GRAPHITE_USE_CLOOG))
$(info ENABLE_GOLD=$(ENABLE_GOLD))
$(info ENABLE_LD_DEFAULT=$(ENABLE_LD_DEFAULT))
$(info binutils_VERSION=$(BINUTILS_VERSION))
$(info gold_VERSION=$(GOLD_VERSION))
$(info gcc_VERSION=$(GCC_VERSION))
$(info gdb_VERSION=$(GDB_VERSION))
$(info kernel_VERSION=$(KERNEL_VERSION))
ifeq ($(TARGET_LIBC),glibc)
$(info glibc_VERSION=$(GLIBC_VERSION))
$(info glibc-linuxthreads_VERSION=$(GLIBC_LINUXTHREADS_VERSION))
endif # TARGET_LIBC
$(info gmp_VERSION=$(GMP_VERSION))
$(info mpfr_VERSION=$(MPFR_VERSION))
$(info mpc_VERSION=$(MPC_VERSION))
ifeq ($(ENABLE_GRAPHITE),yes)
$(info isl_VERSION=$(ISL_VERSION))
ifeq ($(ENABLE_GRAPHITE_USE_CLOOG),yes)
$(info ppl_VERSION=$(PPL_VERSION))
$(info cloog_VERSION=$(CLOOG_VERSION))
endif # ENABLE_GRAPHITE_USE_CLOOG
endif # ENABLE_GRAPHITE
$(info expat_VERSION=$(EXPAT_VERSION))
$(info TARGET_OUT_ROOT=$(TARGET_OUT_ROOT))
$(info +++++++++++++++++++++++++++++++++)
endif # PRINT_BUILD_CONFIG
