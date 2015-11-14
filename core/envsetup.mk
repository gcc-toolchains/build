#
# Copyright (C) 2015 The Yudatun Open Source Project
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation

#=======================================
# Set up configuration for host machine. We don't do cross-compiles
# except for arm/mips, os the HOST is whatever we are running on
#

UNAME := $(shell uname -sm)

# HOST_OS
ifneq (,$(findstring Linux,$(UNAME)))
HOST_OS := linux
endif

# BUILD_OS is the real host doing the build.
BUILD_OS := $(HOST_OS)

ifeq ($(HOST_OS),)
$(error Unable to determine HOST_OS from uname -sm: $(UNAME)!)
endif

# HOST_ARCH
HOST_ARCH := x86
ifneq (,$(findstring x86_64,$(UNAME)))
  HOST_ARCH := x86_64
  HOST_IS_64_BIT := true
endif

BUILD_ARCH := $(HOST_ARCH)

ifeq ($(HOST_ARCH),)
$(error Unable to determine HOST_ARCH from uname -sm; $(UNAME)!)
endif

CURRENT_HOST := $(HOST_ARCH)-linux-gnu
CURRENT_BUILD := $(CURRENT_HOST)

#=======================================
# packages

BINUTILS_VERSION := 2.25
BINUTILS_PATH := binutils-$(BINUTILS_VERSION)
BINUTILS_ABS_PATH := $(TOPDIR)binutils/$(BINUTILS_PATH)

GOLD_VERSION := 2.25
GOLD_PATH := binutils-$(GOLD_VERSION)
GOLD_ABS_PATH := $(TOPDIR)binutils/$(GOLD_PATH)

GCC_VERSION := 5.1.0
GCC_PATH := gcc-$(GCC_VERSION)
GCC_ABS_PATH := $(TOPDIR)gcc/$(GCC_PATH)

GDB_VERSION := 7.9
GDB_PATH := gdb-$(GDB_VERSION)
GDB_ABS_PATH := $(TOPDIR)gdb/$(GDB_PATH)

KERNEL_HEADERS_PATH := kernel-headers/original/uapi/$(TARGET_TOOLCHAINS_ARCH)
KERNEL_HEADERS_ABS_PATH := $(TOPDIR)$(KERNEL_HEADERS_PATH)

ifeq ($(TARGET_LIBC),glibc)
GLIBC_VERSION := 2.21
GLIBC_PATH := glibc-$(GLIBC_VERSION)
GLIBC_ABS_PATH := $(TOPDIR)glibc/$(GLIBC_PATH)
endif # TARGET_LIBC

GMP_VERSION := 6.0.0
GMP_PATH := gmp-$(GMP_VERSION)
GMP_ABS_PATH := $(TOPDIR)gmp/$(GMP_PATH)

MPFR_VERSION := 3.1.2
MPFR_PATH := mpfr-$(MPFR_VERSION)
MPFR_ABS_PATH := $(TOPDIR)mpfr/$(MPFR_PATH)

MPC_VERSION := 1.0.3
MPC_PATH := mpc-$(MPC_VERSION)
MPC_ABS_PATH := $(TOPDIR)mpc/$(MPC_PATH)

ISL_VERSION := 0.14
ISL_PATH := isl-$(ISL_VERSION)
ISL_ABS_PATH := $(TOPDIR)isl/$(ISL_PATH)

ifeq ($(ENABLE_GRAPHITE_USE_CLOOG),yes)
PPL_VERSION := 1.1
PPL_PATH := ppl-$(PPL_VERSION)
PPL_ABS_PATH := $(TOPDIR)ppl/$(PPL_PATH)

CLOOG_VERSION := 0.18.3
CLOOG_PATH := cloog-$(CLOOG_VERSION)
CLOOG_ABS_PATH := $(TOPDIR)cloog/$(CLOOG_PATH)
endif # ENABLE_GRAPHITE_USE_CLOOG

EXPAT_VERSION := 2.1.0
EXPAT_PATH := expat-$(EXPAT_VERSION)
EXPAT_ABS_PATH := $(TOPDIR)expat/$(EXPAT_PATH)

#=======================================

ifeq (,$(strip $(OUT_DIR)))
OUT_DIR := $(TOPDIR)out
endif

TARGET_OUT_ROOT := $(OUT_DIR)/$(TARGET)

TOOLCHAINS_PREFIX := $(WORKSPACE)/$(TARGET_OUT_ROOT)/$(TARGET)-$(GCC_VERSION)

TOOLCHAINS_SYSROOT := $(TOOLCHAINS_PREFIX)/$(TARGET)/sysroot

TEMP_INSTALLDIR := $(WORKSPACE)/$(TARGET_OUT_ROOT)/temp-install

ifeq ($(HAVE_GMP),)
  GMP_DIR=$(TEMP_INSTALLDIR)
endif

ifeq ($(HAVE_MPC),)
  MPC_DIR=$(TEMP_INSTALLDIR)
endif

ifeq ($(HAVE_MPFR),)
  MPFR_DIR=$(TEMP_INSTALLDIR)
endif

ifeq ($(HAVE_PPL),)
  PPL_DIR=$(TEMP_INSTALLDIR)
endif

ifeq ($(HAVE_CLOOG),)
  CLOOG_DIR=$(TEMP_INSTALLDIR)
endif

ifeq ($(HAVE_ISL),)
  ISL_DIR=$(TEMP_INSTALLDIR)
endif

ifeq ($(HAVE_EXPAT),)
  EXPAT_DIR=$(TEMP_INSTALLDIR)
endif

# toolchains
TARGET_TOOLCHAINS_EXPORTS= \
  export CC=$(TOOLCHAINS_PREFIX)/bin/$(TARGET)-gcc \
    CXX=$(TOOLCHAINS_PREFIX)/bin/$(TARGET)-g++ \
    AR=$(TOOLCHAINS_PREFIX)/bin/$(TARGET)-ar \
    NM=$(TOOLCHAINS_PREFIX)/bin/$(TARGET)-nm \
    OBJDUMP=$(TOOLCHAINS_PREFIX)/bin/$(TARGET)-objdump \
    OBJCOPY=$(TOOLCHAINS_PREFIX)/bin/$(TARGET)-objcopy \
    READELF=$(TOOLCHAINS_PREFIX)/bin/$(TARGET)-readelf

#---------------------------------------

ifeq ($(PRINT_BUILD_CONFIG),)
PRINT_BUILD_CONFIG := true
endif
