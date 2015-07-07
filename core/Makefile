#
# Copyright (C) 2015 The Yudatun Open Source Project
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation

STAMP := touch
INSTALL := install

ifeq ($(ENABLE_GRAPHITE),yes)
ifeq ($(ENABLE_GRAPHITE_USE_CLOOG),yes)
CLOOG_BACKEND := --enable-cloog-backend=isl
endif # ENABLE_GRAPHITE_USE_CLOOG
endif

#=======================================
# binutils
# target binutils rules
.PHONY: config-target-binutils build-target-binutils install-target-binutils

stamp-config-target-binutils := $(TARGET_OUT_ROOT)/stamp-config-target-binutils
stamp-build-target-binutils := $(TARGET_OUT_ROOT)/stamp-build-target-binutils

config-target-binutils: $(stamp-config-target-binutils)

BINUTILS_BUILD_PATH := $(TARGET_OUT_ROOT)/$(BINUTILS_PATH)
BINUTILS_BUILD_ABS_PATH := $(WORKSPACE)/$(BINUTILS_BUILD_PATH)

BINUTILS_CONFIGURE := $(WORKSPACE)/$(BINUTILS_ABS_PATH)/configure
INTERNAL_BINUTILS_CONFIG_ARGS := \
    --target=${TARGET} \
    --prefix=${TOOLCHAINS_PREFIX} \
    --build=$(CURRENT_BUILD) \
    --host=$(CURRENT_HOST) \
    --disable-shared --disable-nls

ifeq ($(ENABLE_GRAPHITE),yes)
$(stamp-config-target-binutils): install-host-isl
INTERNAL_BINUTILS_CONFIG_ARGS += \
    --with-isl=${ISL_DIR} \
    --disable-isl-version-check

ifeq ($(ENABLE_GRAPHITE_USE_CLOOG),yes)
$(stamp-config-target-binutils): install-host-ppl
INTERNAL_BINUTILS_CONFIG_ARGS += \
    --with-ppl=${PPL_DIR} \
    --disable-ppl-version-check
$(stamp-config-target-binutils): install-host-cloog
INTERNAL_BINUTILS_CONFIG_ARGS += \
    --with-cloog=${CLOOG_DIR} \
    --disable-cloog-version-check \
    $(CLOOG_BACKEND)
endif # ENABLE_GRAPHITE_USE_CLOOG
endif # ENABLE_GRAPHITE

# links to the static C++ runtime to avoid depending on the host version
# ! darwin
INTERNAL_BINUTILS_CONFIG_ARGS += \
    '--with-host-libstdcxx=-static-libgcc -Wl,-Bstatic,-lstdc++,-Bdynamic -lm' \
    --enable-install-libbfd

ifeq ($(CURRENT_HOST),$(CURRENT_BUILD))
INTERNAL_BINUTILS_CONFIG_ARGS += \
     --with-gold-ldflags='-static-libgcc -static-libstdc++'
endif

# Enable dual linker support and make gold as default linker when gold is
# enabled. Notice that our binutils take different --enable-gold=xxx options.
ifneq ($(ENABLE_GOLD),)

ifeq ($(ENABLE_LD_DEFAULT),)
INTERNAL_BINUTILS_CONFIG_ARGS += --enable-gold=default
endif # ENABLE_LD_DEFAULT

else

ifeq ($(ENABLE_LD_DEFAULT),)
INTERNAL_BINUTILS_CONFIG_ARGS += --enable-gold=default
else
INTERNAL_BINUTILS_CONFIG_ARGS += --enable-ld=default
endif # ENABLE_LD_DEFAULT

endif # ENABLE_GOLD

ifneq ($(TARGET), arm-eabi)
$(stamp-config-target-binutils): install-target-kernel-headers
INTERNAL_BINUTILS_CONFIG_ARGS += \
    --with-sysroot=$(TOOLCHAINS_SYSROOT)
endif

BINUTILS_CONFIG_ARGS := \
    $(INTERNAL_BINUTILS_CONFIG_ARGS) \
    $(EXTRA_BINUTILS_CONFIG_ARGS)

$(stamp-config-target-binutils):
	([ -d ${BINUTILS_BUILD_PATH} ] || \
	  mkdir -p ${BINUTILS_BUILD_PATH}) && \
	(cd ${BINUTILS_BUILD_PATH} ; \
	  ${BINUTILS_CONFIGURE} ${BINUTILS_CONFIG_ARGS}) && \
	$(STAMP) $@

build-target-binutils: $(stamp-build-target-binutils)
$(stamp-build-target-binutils): $(stamp-config-target-binutils)
	$(MAKE) -C ${BINUTILS_BUILD_PATH} && \
	$(STAMP) $@

install-target-binutils: $(stamp-build-target-binutils)
	$(MAKE) -C ${BINUTILS_BUILD_PATH} install

# Figure out where to find the ld binary.
FIND_TARGET_LD := \
    `[ -d $(BINUTILS_BUILD_ABS_PATH)/gold ] && echo "gold" || echo "ld"`

# We export these insteading when configuring target gcc.
TARGET_BINUTILS_EXPORTS := \
  export AS_FOR_TARGET=$(BINUTILS_BUILD_ABS_PATH)/gas/as-new \
    LD_FOR_TARGET=$(BINUTILS_BUILD_ABS_PATH)/$(FIND_TARGET_LD)/ld-new \
    AR_FOR_TARGET=$(BINUTILS_BUILD_ABS_PATH)/binutils/ar \
    NM_FOR_TARGET=$(BINUTILS_BUILD_ABS_PATH)/binutils/nm-new \
    STRIP_FOR_TARGET=$(BINUTILS_BUILD_ABS_PATH)/binutils/strip-new \
    RANLIB_FOR_TARGET=$(BINUTILS_BUILD_ABS_PATH)/binutils/ranlib \
    OBJDUMP_FOR_TARGET=$(BINUTILS_BUILD_ABS_PATH)/binutils/objdump \
    READELF_FOR_TARGET=$(BINUTILS_BUILD_ABS_PATH)/binutils/readelf

#=======================================
# gold
ifneq ($(BINUTILS_VERSION), $(GOLD_VERSION))
.PHONY: config-target-gold build-target-gold install-target-gold

stamp-config-target-gold := $(TARGET_OUT_ROOT)/stamp-config-target-gold
stamp-build-target-gold := $(TARGET_OUT_ROOT)/stamp-build-target-gold

config-target-gold: $(stamp-config-target-gold)

GOLD_BUILD_PATH := $(TARGET_OUT_ROOT)/$(GOLD_PATH)

GOLD_CONFIGURE := $(WORKSPACE)/$(GOLD_ABS_PATH)/configure
INTERNAL_GOLD_CONFIG_ARGS := \
    --target=${TARGET} \
    --prefix=${TOOLCHAINS_PREFIX} \
    --build=$(CURRENT_BUILD) \
    --host=$(CURRENT_HOST) \
    --disable-shared

INTERNAL_GOLD_CONFIG_ARGS += --enable-gold=default

GOLD_CONFIG_ARGS := \
    $(INTERNAL_GOLD_CONFIG_ARGS) \
    $(EXTRA_GOLD_CONFIG_ARGS)

$(stamp-config-target-gold):
	([ -d ${GOLD_BUILD_PATH} ] || \
	  mkdir -p ${GOLD_BUILD_PATH}) && \
	(cd ${GOLD_BUILD_PATH} ; \
	  ${GOLD_CONFIGURE} ${GOLD_CONFIG_ARGS}) && \
	$(STAMP) $@

build-target-gold: $(stamp-build-target-gold)
$(stamp-build-target-gold): $(stamp-config-target-gold)
	$(MAKE) -C ${GOLD_BUILD_PATH} && \
	$(STAMP) $@

install-target-gold: $(stamp-build-target-gold) install-target-binutils
	$(MAKE) -C ${GOLD_BUILD_PATH}/gold install
endif

#=======================================
# gcc
# target gcc rules
.PHONY: config-target-gcc build-target-gcc install-target-gcc

stamp-config-target-gcc := $(TARGET_OUT_ROOT)/stamp-config-target-gcc
stamp-build-target-gcc := $(TARGET_OUT_ROOT)/stamp-build-target-gcc

config-target-gcc: $(stamp-config-target-gcc)

GCC_BUILD_PATH := $(TARGET_OUT_ROOT)/$(GCC_PATH)
#
# We need -Os as the overrides below interfere with --enable-target-optspace.
# We also need -mandroid for for target libraries to pass linking test
# in configuration.
#
# To build libstdc++ with RTTI and exceptions do:
#
#export CFLAGS_FOR_TARGET=-fexceptions
#export CXXFLAGS_FOR_TARGET=-frtti
#
CFLAGS_FOR_TARGET += -O2 -Os -g
CXXFLAGS_FOR_TARGET += $(CFLAGS_FOR_TARGET)
LDFLAGS_FOR_TARGET :=

GCC_CONFIGURE := $(WORKSPACE)/$(GCC_ABS_PATH)/configure
INTERNAL_GCC_CONFIG_ARGS := \
    --target=${TARGET} \
    --prefix=${TOOLCHAINS_PREFIX} \
    --build=$(CURRENT_BUILD) \
    --host=$(CURRENT_HOST) \
    --with-gnu-as \
    --with-gnu-ld \
    --enable-languages=c,c++

$(stamp-config-target-gcc): install-host-gmp
INTERNAL_GCC_CONFIG_ARGS += \
    --with-gmp=$(GMP_DIR)

$(stamp-config-target-gcc): install-host-mpfr
INTERNAL_GCC_CONFIG_ARGS += \
    --with-mpfr=$(MPFR_DIR)

$(stamp-config-target-gcc): install-host-mpc
INTERNAL_GCC_CONFIG_ARGS += \
    --with-mpc=$(MPC_DIR)

# For gcc 4.5 and 4.6 with graphite optimization, cloog and ppl are required.
# For gcc 4.8+ with graphite optimization, cloog and isl are required.
ifeq ($(ENABLE_GRAPHITE),yes)
$(stamp-config-target-gcc): install-host-isl
INTERNAL_GCC_CONFIG_ARGS += \
    --with-isl=${ISL_DIR} \
    --disable-isl-version-check

ifeq ($(ENABLE_GRAPHITE_USE_CLOOG),yes)
$(stamp-config-target-gcc): install-host-ppl
INTERNAL_GCC_CONFIG_ARGS += \
    --with-ppl=${PPL_DIR} \
    --disable-ppl-version-check
$(stamp-config-target-gcc): install-host-cloog
INTERNAL_GCC_CONFIG_ARGS += \
    --with-cloog=${CLOOG_DIR} \
    --disable-cloog-version-check \
    $(CLOOG_BACKEND)
endif # ENABLE_GRAPHITE_USE_CLOOG
else
# Disable ppl, isl and cloog just in case the host have them install.
INTERNAL_GCC_CONFIG_ARGS += \
    --without-ppl --without-cloog --without-isl
endif # ENABLE_GRAPHITE

# links to the static C++ runtime to avoid depending on the host version
# Linux
INTERNAL_GCC_CONFIG_ARGS += \
    '--with-host-libstdcxx=-static-libgcc \
     -Wl,-Bstatic,-lstdc++,-Bdynamic -lm'

# Add Yudatun specific gcc options.
# FIXME: These should be overridable by configure options.

# Target indenpendent Yudatun gcc options.
ifeq ($(BUILD_YUDATUN_GCC),yes)
INTERNAL_GCC_CONFIG_ARGS += \
    $(GCC_CONFIG_LIBSTDCXX_V3) \
    --disable-libssp \
    --enable-threads \
    --disable-nls \
    --disable-libmudflap \
    --disable-libgomp \
    --disable-libstdc__-v3 \
    --disable-sjlj-exceptions \
    --disable-libitm

CFLAGS_FOR_TARGET += -fno-short-enums

ifeq ($(TARGET_TOOLCHAINS_ARCH),i686)
INTERNAL_GCC_CONFIG_ARGS += \
    --with-arch=i686 \
    --with-tune=intel \
    --with-fpmath=sse
endif

ifeq ($(TARGET_TOOLCHAINS_ARCH),x86_64)
INTERNAL_GCC_CONFIG_ARGS += \
    --with-arch=x86-64 \
    --with-tune=intel \
    --with-fpmath=sse \
    --with-multilib-list=m32,m64,mx32
endif

# ARM specific options.
ifeq ($(TARGET_TOOLCHAINS_ARCH),arm)
INTERNAL_GCC_CONFIG_ARGS += \
    --with-float=soft \
    --with-fpu=vfp \
    --with-arch=armv5te \
    --enable-target-optspace

ifneq ($(TARGET_BUILD_APP),yes)
INTERNAL_GCC_CONFIG_ARGS += --with-abi=aapcs
endif # TARGET_BUILD_APP
endif # TARGET_TOOLCHAINS_ARCH

endif # BUILD_YUDATUN_GCC

# Add user specified --enable-gold=xxx option to gcc
ifneq ($(ENABLE_GOLD),)
INTERNAL_GCC_CONFIG_ARGS += --enable-gold=default
endif

ifneq ($(TARGET), arm-eabi)
$(stamp-config-target-gcc): install-target-kernel-headers
INTERNAL_GCC_CONFIG_ARGS += \
    --with-sysroot=$(TOOLCHAINS_SYSROOT)
endif

ifeq ($(TARGET), arm-linux-gnueabi)
INTERNAL_GCC_CONFIG_ARGS += \
    --enable-shared \
    --enable-lto \
    --enable-tls \
    --enable-symvers=gnu \
    --enable-__cxa_atexit \
    --disable-libstdcxx-pch \
    --enable-extra-sgxxlite-multilibs \
    --enable-poison-system-directories
else
INTERNAL_GCC_CONFIG_ARGS += \
    --disable-shared \
    --disable-tls
endif

GCC_CONFIG_ARGS := \
    $(INTERNAL_GCC_CONFIG_ARGS) \
    $(EXTRA_GCC_CONFIG_ARGS)

gcc_build_target :=
gcc_install_target := install
install-target-gcc-multilibs :=

$(stamp-config-target-gcc): install-target-binutils
	([ -d ${GCC_BUILD_PATH} ] || \
	  mkdir -p ${GCC_BUILD_PATH}) && \
	(cd ${GCC_BUILD_PATH} ; \
	  $(TARGET_BINUTILS_EXPORTS) \
	  export CFLAGS_FOR_TARGET="$(CFLAGS_FOR_TARGET)" ; \
	  export CXXFLAGS_FOR_TARGET="$(CXXFLAGS_FOR_TARGET)" ; \
	  export LDFLAGS_FOR_TARGET="$(LDFLAGS_FOR_TARGET)" ; \
	  ${GCC_CONFIGURE} ${GCC_CONFIG_ARGS}) && \
	$(STAMP) $@

build-target-gcc: $(stamp-build-target-gcc)
$(stamp-build-target-gcc): $(stamp-config-target-gcc)
	$(MAKE) -C ${GCC_BUILD_PATH} \
	  CFLAGS_FOR_TARGET="$(CFLAGS_FOR_TARGET)" \
	  CXXFLAGS_FOR_TARGET="$(CXXFLAGS_FOR_TARGET)" \
	  LDFLAGS_FOR_TARGET="$(LDFLAGS_FOR_TARGET)" \
	  $(gcc_build_target) \
	&& $(STAMP) $@

install-target-gcc: install-target-gcc-gcc $(install-target-gcc-multilibs)
install-target-gcc-gcc: $(stamp-build-target-gcc)
	$(MAKE) -C ${GCC_BUILD_PATH} $(gcc_install_target)

#---------------------------------------
# minimal gcc rules
# minimal gcc only builds the C and C++ compilers and libgcc
# We use the full gcc configure rules.
.PHONY: build-target-minimal-gcc install-target-minimal-gcc

# Helper
prefix-list = $(foreach e, $(2), $(join $1, $e))

MINIMAL_GCC_BUILD_TARGETS := gcc

stamp-build-target-minimal-gcc := $(TARGET_OUT_ROOT)/stamp-build-target-minimal-gcc
stamp-install-target-minimal-gcc := $(TARGET_OUT_ROOT)/stamp-install-target-minimal-gcc

build-target-minimal-gcc: $(stamp-build-target-minimal-gcc)
$(stamp-build-target-minimal-gcc): $(stamp-config-target-gcc)
	$(MAKE) -C ${GCC_BUILD_PATH} \
	  CFLAGS_FOR_TARGET="$(CFLAGS_FOR_TARGET)" \
	  CXXFLAGS_FOR_TARGET="$(CXXFLAGS_FOR_TARGET)" \
	  LDFLAGS_FOR_TARGET="$(LDFLAGS_FOR_TARGET)" \
	  $(call prefix-list, all-, $(MINIMAL_GCC_BUILD_TARGETS)) \
	&& $(STAMP) $@

install-target-minimal-gcc: $(stamp-install-target-minimal-gcc)
$(stamp-install-target-minimal-gcc): $(stamp-build-target-minimal-gcc)
	$(MAKE) -C ${GCC_BUILD_PATH} \
	  $(call prefix-list, install-, $(MINIMAL_GCC_BUILD_TARGETS)) \
	&& $(STAMP) $@

#---------------------------------------
# minimal gcc rules
# minimal gcc only builds the C and C++ compilers and libgcc
# We use the full gcc configure rules.
.PHONY: build-target-minimal-libgcc install-target-minimal-libgcc

MINIMAL_LIBGCC_BUILD_TARGETS := target-libgcc

stamp-build-target-minimal-libgcc := $(TARGET_OUT_ROOT)/stamp-build-target-minimal-libgcc
stamp-install-target-minimal-libgcc := $(TARGET_OUT_ROOT)/stamp-install-target-minimal-libgcc

build-target-minimal-libgcc: $(stamp-build-target-minimal-libgcc)
ifeq ($(TARGET), arm-linux-gnueabi)
$(stamp-build-target-minimal-libgcc): install-target-glibc-headers install-target-glibc-csu
endif
$(stamp-build-target-minimal-libgcc): $(stamp-config-target-gcc)
	$(MAKE) -C ${GCC_BUILD_PATH} \
	  CFLAGS_FOR_TARGET="$(CFLAGS_FOR_TARGET)" \
	  CXXFLAGS_FOR_TARGET="$(CXXFLAGS_FOR_TARGET)" \
	  LDFLAGS_FOR_TARGET="$(LDFLAGS_FOR_TARGET)" \
	  $(call prefix-list, all-, $(MINIMAL_LIBGCC_BUILD_TARGETS))
	$(STAMP) $@

install-target-minimal-libgcc: $(stamp-install-target-minimal-libgcc)
$(stamp-install-target-minimal-libgcc): $(stamp-build-target-minimal-libgcc)
	$(MAKE) -C ${GCC_BUILD_PATH} \
	  $(call prefix-list, install-, $(MINIMAL_LIBGCC_BUILD_TARGETS))
	$(STAMP) $@

#=======================================
# headers
# target kernel headers rules
.PHONY: install-target-kernel-headers

include $(BUILD_SYSTEM)/kernel.mk

ifeq ($(KERNEL_DEFCONFIG),)
KERNEL_DEFCONFIG := bcm_defconfig
endif # KERNEL_DEFCONFIG

stamp-install-target-kernel-headers := $(TARGET_OUT_ROOT)/stamp-install-target-kernel-headers

install-target-kernel-headers: $(stamp-install-target-kernel-headers)
$(stamp-install-target-kernel-headers): $(KERNEL_HEADERS_INSTALL)
	$(STAMP) $@

#=======================================
# glibc
# target glibc rules
ifeq ($(TARGET_LIBC), glibc)
.PHONY: config-target-glibc build-target-glibc install-target-glibc

stamp-config-target-glibc := $(TARGET_OUT_ROOT)/stamp-config-target-glibc
stamp-build-target-glibc := $(TARGET_OUT_ROOT)/stamp-build-target-glibc
stamp-install-target-glibc := $(TARGET_OUT_ROOT)/stamp-install-target-glibc

config-target-glibc: $(stamp-config-target-glibc)

GLIBC_BUILD_PATH := $(TARGET_OUT_ROOT)/$(GLIBC_PATH)
GLIBC_CONFIGURE := $(WORKSPACE)/$(GLIBC_ABS_PATH)/configure
INTERNAL_GLIBC_CONFIG_ARGS := \
    --target=${TARGET} \
    --prefix=${TOOLCHAINS_SYSROOT}/usr \
    --build=$(CURRENT_BUILD) \
    --host=$(TARGET) \
    --with-headers=$(TOOLCHAINS_SYSROOT)/usr/include \
    libc_cv_forced_unwind=yes \
    libc_cv_c_cleanup=yes \
    libc_cv_arm_tls=yes \
    --disable-werror \
    --disable-profile \
    --enable-add-ons

GLIBC_CONFIG_ARGS := \
    $(INTERNAL_GLIBC_CONFIG_ARGS) \
    $(EXTRA_GLIBC_CONFIG_ARGS)

$(stamp-config-target-glibc):
	([ -d ${GLIBC_BUILD_PATH} ] || \
	  mkdir -p ${GLIBC_BUILD_PATH}) && \
	(cd ${GLIBC_BUILD_PATH} ; \
	  $(TARGET_TOOLCHAINS_EXPORTS) ; \
	  ${GLIBC_CONFIGURE} ${GLIBC_CONFIG_ARGS}) && \
	$(STAMP) $@

build-target-glibc: $(stamp-build-target-glibc)
$(stamp-build-target-glibc): $(stamp-config-target-glibc)
	$(MAKE) -C ${GLIBC_BUILD_PATH}
	$(STAMP) $@

install-target-glibc: $(stamp-install-target-glibc)
$(stamp-install-target-glibc): $(stamp-build-target-glibc)
	$(MAKE) -C ${GLIBC_BUILD_PATH} install
	$(STAMP) $@

#---------------------------------------
# glibc headers
.PHONY: install-target-glibc-headers

stamp-install-target-glibc-headers := $(TARGET_OUT_ROOT)/stamp-install-target-glibc-headers

install-target-glibc-headers: $(stamp-install-target-glibc-headers)
$(stamp-install-target-glibc-headers): $(stamp-config-target-glibc)
	$(MAKE) -C $(GLIBC_BUILD_PATH) \
	  cross-compiling=yes \
	  install-bootstrap-headers=yes \
	  inst_includedir=$(TOOLCHAINS_SYSROOT)/usr/include \
	  install-headers
	touch $(TOOLCHAINS_SYSROOT)/usr/include/gnu/stubs.h
	$(STAMP) $@

#---------------------------------------
# glibc csu
.PHONY: build-target-glibc-csu install-target-glibc-csu

stamp-build-target-glibc-csu := $(TARGET_OUT_ROOT)/stamp-build-target-glibc-csu
stamp-install-target-glibc-csu := $(TARGET_OUT_ROOT)/stamp-install-target-glibc-csu

csu_install_target := \
    $(GLIBC_BUILD_PATH)/csu/crt1.o \
    $(GLIBC_BUILD_PATH)/csu/crti.o \
    $(GLIBC_BUILD_PATH)/csu/crtn.o

build-target-glibc-csu: $(stamp-build-target-glibc-csu)
$(stamp-build-target-glibc-csu): $(stamp-config-target-glibc)
	$(MAKE) -C $(GLIBC_BUILD_PATH) csu/subdir_lib
	$(STAMP) $@

install-target-glibc-csu: $(stamp-install-target-glibc-csu)
$(stamp-install-target-glibc-csu): $(stamp-build-target-glibc-csu)
	@rm -rf $(TOOLCHAINS_SYSROOT)/usr/lib
	@mkdir -p $(TOOLCHAINS_SYSROOT)/usr/lib
	$(INSTALL) $(csu_install_target) $(TOOLCHAINS_SYSROOT)/usr/lib
	$(TOOLCHAINS_PREFIX)/bin/$(TARGET)-gcc \
	  -nostdlib -nostartfiles -shared -x c /dev/null -o \
	  $(TOOLCHAINS_SYSROOT)/usr/lib/libc.so
	$(STAMP) $@
endif # TARGET_LIBC

#=======================================
# gdb
# target gdb rules
.PHONY: config-target-gdb build-target-gdb install-target-gdb

stamp-config-target-gdb := $(TARGET_OUT_ROOT)/stamp-config-target-gdb
stamp-build-target-gdb := $(TARGET_OUT_ROOT)/stamp-build-target-gdb

config-target-gdb: $(stamp-config-target-gdb)

ifeq ($(GDB_VERSION),gdb-none)
config-target-gdb:
build-target-gdb:
install-target-gdb:
else
GDB_BUILD_PATH := $(TARGET_OUT_ROOT)/$(GDB_PATH)

GDB_CONFIGURE := $(WORKSPACE)/$(GDB_ABS_PATH)/configure
INTERNAL_GDB_CONFIG_ARGS := \
    --target=${TARGET} \
    --prefix=${TOOLCHAINS_PREFIX} \
    --build=$(CURRENT_BUILD) \
    --host=$(CURRENT_HOST) \
    --disable-nls \
    $(WITH_PYTHON)

# For gdb version 7.2 and higher, expat is required
INTERNAL_GDB_CONFIG_ARGS += \
    --with-expat --with-libexpat-prefix=$(EXPAT_DIR)

GDB_CONFIG_ARGS := \
    $(INTERNAL_GDB_CONFIG_ARGS) \
    $(EXTRA_GDB_CONFIG_ARGS)

$(stamp-config-target-gdb): install-host-expat
	([ -d ${GDB_BUILD_PATH} ] || \
	  mkdir -p ${GDB_BUILD_PATH}) && \
	(cd ${GDB_BUILD_PATH} ; \
	  ${GDB_CONFIGURE} ${GDB_CONFIG_ARGS}) && \
	$(STAMP) $@

build-target-gdb: $(stamp-build-target-gdb)
$(stamp-build-target-gdb): $(stamp-config-target-gdb)
	$(MAKE) -C ${GDB_BUILD_PATH} && \
	$(STAMP) $@

install-target-gdb: $(stamp-build-target-gdb) install-target-binutils
	$(MAKE) -C ${GDB_BUILD_PATH}/gdb install
endif

#=======================================
# gmp
# host gmp rules
.PHONY: config-host-gmp build-host-gmp install-host-gmp

stamp-config-host-gmp := $(TARGET_OUT_ROOT)/stamp-config-host-gmp
stamp-build-host-gmp := $(TARGET_OUT_ROOT)/stamp-build-host-gmp
stamp-install-host-gmp := $(TARGET_OUT_ROOT)/stamp-install-host-gmp

config-host-gmp: $(stamp-config-host-gmp)

GMP_BUILD_PATH := $(TARGET_OUT_ROOT)/$(GMP_PATH)

GMP_CONFIGURE := $(WORKSPACE)/$(GMP_ABS_PATH)/configure
INTERNAL_GMP_CONFIG_ARGS := \
    --prefix=${GMP_DIR} \
    --build=$(CURRENT_BUILD) \
    --host=$(CURRENT_HOST) \
    --disable-shared

ifeq ($(ENABLE_GRAPHITE),yes)
INTERNAL_GMP_CONFIG_ARGS += --enable-cxx
endif

GMP_CONFIG_ARGS := \
    $(INTERNAL_GMP_CONFIG_ARGS) \
    $(EXTRA_GMP_CONFIG_ARGS)

$(stamp-config-host-gmp):
	([ -d ${GMP_BUILD_PATH} ] || \
	  mkdir -p ${GMP_BUILD_PATH}) && \
	(cd ${GMP_BUILD_PATH} ; \
	  ${GMP_CONFIGURE} ${GMP_CONFIG_ARGS}) && \
	$(STAMP) $@

build-host-gmp: $(stamp-build-host-gmp)
$(stamp-build-host-gmp): $(stamp-config-host-gmp)
	$(MAKE) -C ${GMP_BUILD_PATH} && $(STAMP) $@

install-host-gmp: $(stamp-install-host-gmp)
$(stamp-install-host-gmp): $(stamp-build-host-gmp)
	$(MAKE) -C ${GMP_BUILD_PATH} install && $(STAMP) $@

#=======================================
# mpfr
# host mpfr rules
.PHONY: config-host-mpfr build-host-mpfr install-host-mpfr

stamp-config-host-mpfr := $(TARGET_OUT_ROOT)/stamp-config-host-mpfr
stamp-build-host-mpfr := $(TARGET_OUT_ROOT)/stamp-build-host-mpfr
stamp-install-host-mpfr := $(TARGET_OUT_ROOT)/stamp-install-host-mpfr

config-host-mpfr: $(stamp-config-host-mpfr)

MPFR_BUILD_PATH := $(TARGET_OUT_ROOT)/$(MPFR_PATH)

MPFR_CONFIGURE := $(WORKSPACE)/$(MPFR_ABS_PATH)/configure
INTERNAL_MPFR_CONFIG_ARGS := \
    --prefix=${MPFR_DIR} \
    --build=$(CURRENT_BUILD) \
    --host=$(CURRENT_HOST) \
    --with-gmp=$(GMP_DIR) \
    --disable-shared

MPFR_CONFIG_ARGS := \
    $(INTERNAL_MPFR_CONFIG_ARGS) \
    $(EXTRA_MPFR_CONFIG_ARGS)

$(stamp-config-host-mpfr): install-host-gmp
	([ -d ${MPFR_BUILD_PATH} ] || \
	  mkdir -p ${MPFR_BUILD_PATH}) && \
	(cd ${MPFR_BUILD_PATH} ; \
	  ${MPFR_CONFIGURE} ${MPFR_CONFIG_ARGS}) && \
	$(STAMP) $@

build-host-mpfr: $(stamp-build-host-mpfr)
$(stamp-build-host-mpfr): $(stamp-config-host-mpfr)
	$(MAKE) -C ${MPFR_BUILD_PATH} && $(STAMP) $@

install-host-mpfr: $(stamp-install-host-mpfr)
$(stamp-install-host-mpfr): $(stamp-build-host-mpfr)
	$(MAKE) -C ${MPFR_BUILD_PATH} install && $(STAMP) $@

#=======================================
# mpc
# host mpc rules
.PHONY: config-host-mpc build-host-mpc install-host-mpc

stamp-config-host-mpc := $(TARGET_OUT_ROOT)/stamp-config-host-mpc
stamp-build-host-mpc := $(TARGET_OUT_ROOT)/stamp-build-host-mpc
stamp-install-host-mpc := $(TARGET_OUT_ROOT)/stamp-install-host-mpc

config-host-mpc: $(stamp-config-host-mpc)

MPC_BUILD_PATH := $(TARGET_OUT_ROOT)/$(MPC_PATH)

MPC_CONFIGURE := $(WORKSPACE)/$(MPC_ABS_PATH)/configure
INTERNAL_MPC_CONFIG_ARGS := \
    --prefix=${MPC_DIR} \
    --build=$(CURRENT_BUILD) \
    --host=$(CURRENT_HOST) \
    --with-gmp=$(GMP_DIR) \
    --with-mpfr=$(MPFR_DIR) \
    --disable-shared

MPC_CONFIG_ARGS := \
    $(INTERNAL_MPC_CONFIG_ARGS) \
    $(EXTRA_MPC_CONFIG_ARGS)

$(stamp-config-host-mpc): install-host-gmp install-host-mpfr
	([ -d ${MPC_BUILD_PATH} ] || \
	  mkdir -p ${MPC_BUILD_PATH}) && \
	(cd ${MPC_BUILD_PATH} ; \
	  ${MPC_CONFIGURE} ${MPC_CONFIG_ARGS}) && \
	$(STAMP) $@

build-host-mpc: $(stamp-build-host-mpc)
$(stamp-build-host-mpc): $(stamp-config-host-mpc)
	$(MAKE) -C ${MPC_BUILD_PATH} && $(STAMP) $@

install-host-mpc: $(stamp-install-host-mpc)
$(stamp-install-host-mpc): $(stamp-build-host-mpc)
	$(MAKE) -C ${MPC_BUILD_PATH} install && $(STAMP) $@

#=======================================
# ppl
# host ppl rules
.PHONY: config-host-ppl build-host-ppl install-host-ppl

stamp-config-host-ppl := $(TARGET_OUT_ROOT)/stamp-config-host-ppl
stamp-build-host-ppl := $(TARGET_OUT_ROOT)/stamp-build-host-ppl
stamp-install-host-ppl := $(TARGET_OUT_ROOT)/stamp-install-host-ppl

config-host-ppl: $(stamp-config-host-ppl)

PPL_BUILD_PATH := $(TARGET_OUT_ROOT)/$(PPL_PATH)

PPL_CONFIGURE := $(WORKSPACE)/$(PPL_ABS_PATH)/configure
INTERNAL_PPL_CONFIG_ARGS := \
    --target=$(TARGET) \
    --prefix=${PPL_DIR} \
    --build=$(CURRENT_BUILD) \
    --host=$(CURRENT_HOST) \
    --disable-shared \
    --without-java \
    --disable-ppl_lcdd \
    --disable-ppl_lpsol \
    --disable-ppl_pips

$(stamp-config-host-ppl): install-host-gmp
INTERNAL_PPL_CONFIG_ARGS += \
    --with-gmp=$(GMP_DIR)

PPL_CONFIG_ARGS := \
    $(INTERNAL_PPL_CONFIG_ARGS) \
    $(EXTRA_PPL_CONFIG_ARGS)

$(stamp-config-host-ppl):
	([ -d ${PPL_BUILD_PATH} ] || \
	  mkdir -p ${PPL_BUILD_PATH}) && \
	(cd ${PPL_BUILD_PATH} ; \
	  export CFLAGS="${CFLAGS} -I$(GMP_DIR)/include" ; \
	  export CXXFLAGS="${CFLAGS} -I$(GMP_DIR)/include" ; \
	  export LDFLAGS="${LDFLAGS} -L$(GMP_DIR)/lib" ; \
	  ${PPL_CONFIGURE} ${PPL_CONFIG_ARGS}) && \
	$(STAMP) $@

build-host-ppl: $(stamp-build-host-ppl)
$(stamp-build-host-ppl): $(stamp-config-host-ppl)
	$(MAKE) -C ${PPL_BUILD_PATH} && $(STAMP) $@

install-host-ppl: $(stamp-install-host-ppl)
ifeq ($(ENABLE_GRAPHITE),yes)
$(stamp-install-host-ppl): $(stamp-build-host-ppl)
	$(MAKE) -C ${PPL_BUILD_PATH} install && $(STAMP) $@
else
$(stamp-install-host-ppl):
	$(STAMP) $@
endif

#=======================================
# isl
# host isl rules
.PHONY: config-host-isl build-host-isl install-host-isl

stamp-config-host-isl := $(TARGET_OUT_ROOT)/stamp-config-host-isl
stamp-build-host-isl := $(TARGET_OUT_ROOT)/stamp-build-host-isl
stamp-install-host-isl := $(TARGET_OUT_ROOT)/stamp-install-host-isl

config-host-isl: $(stamp-config-host-isl)

ISL_BUILD_PATH := $(TARGET_OUT_ROOT)/$(ISL_PATH)

ISL_CONFIGURE := $(WORKSPACE)/$(ISL_ABS_PATH)/configure
INTERNAL_ISL_CONFIG_ARGS := \
    --prefix=${ISL_DIR} \
    --build=$(CURRENT_BUILD) \
    --host=$(CURRENT_HOST) \
    --disable-shared \
    --disable-nls

$(stamp-config-host-isl): install-host-gmp
INTERNAL_ISL_CONFIG_ARGS += \
    --with-gmp=$(GMP_DIR)

ISL_CONFIG_ARGS := \
    $(INTERNAL_ISL_CONFIG_ARGS) \
    $(EXTRA_ISL_CONFIG_ARGS)

$(stamp-config-host-isl):
	([ -d ${ISL_BUILD_PATH} ] || \
	  mkdir -p ${ISL_BUILD_PATH}) && \
	(cd ${ISL_BUILD_PATH} ; \
	  export CFLAGS="${CFLAGS} -I$(GMP_DIR)/include" ; \
	  export CXXFLAGS="${CFLAGS} -I$(GMP_DIR)/include" ; \
	  export LDFLAGS="${LDFLAGS} -L$(GMP_DIR)/lib" ; \
	  ${ISL_CONFIGURE} ${ISL_CONFIG_ARGS}) && \
	$(STAMP) $@

build-host-isl: $(stamp-build-host-isl)
$(stamp-build-host-isl): $(stamp-config-host-isl)
	$(MAKE) -C ${ISL_BUILD_PATH} && $(STAMP) $@

install-host-isl: $(stamp-install-host-isl)
ifeq ($(ENABLE_GRAPHITE),yes)
$(stamp-install-host-isl): $(stamp-build-host-isl)
	$(MAKE) -C ${ISL_BUILD_PATH} install && $(STAMP) $@
else
$(stamp-install-host-isl):
	$(STAMP) $@
endif # ENABLE_GRAPHITE

#=======================================
# cloog
# host cloog rules
.PHONY: config-host-cloog build-host-cloog install-host-cloog

stamp-config-host-cloog := $(TARGET_OUT_ROOT)/stamp-config-host-cloog
stamp-build-host-cloog := $(TARGET_OUT_ROOT)/stamp-build-host-cloog
stamp-install-host-cloog := $(TARGET_OUT_ROOT)/stamp-install-host-cloog

config-host-cloog: $(stamp-config-host-cloog)

CLOOG_BUILD_PATH := $(TARGET_OUT_ROOT)/$(CLOOG_PATH)

CLOOG_CONFIGURE := $(WORKSPACE)/$(CLOOG_ABS_PATH)/configure
INTERNAL_CLOOG_CONFIG_ARGS := \
    --target=${TARGET} \
    --prefix=${CLOOG_DIR} \
    --build=$(CURRENT_BUILD) \
    --host=$(CURRENT_HOST) \
    --disable-shared \
    --disable-nls

CLOOG_TARGET := libcloog-isl.la
$(stamp-config-host-cloog): install-host-gmp
INTERNAL_CLOOG_CONFIG_ARGS += \
    --with-gmp-prefix=$(GMP_DIR)

CLOOG_CONFIG_ARGS := \
    $(INTERNAL_CLOOG_CONFIG_ARGS) \
    $(EXTRA_CLOOG_CONFIG_ARGS)

$(stamp-config-host-cloog):
	([ -d ${CLOOG_BUILD_PATH} ] || \
	  mkdir -p ${CLOOG_BUILD_PATH}) && \
	(cd ${CLOOG_BUILD_PATH} ; \
	  ${CLOOG_CONFIGURE} ${CLOOG_CONFIG_ARGS}) && \
	$(STAMP) $@

build-host-cloog: $(stamp-build-host-cloog)
$(stamp-build-host-cloog): $(stamp-config-host-cloog)
	$(MAKE) -C ${CLOOG_BUILD_PATH} $(CLOOG_TARGET) && $(STAMP) $@

install-host-cloog: $(stamp-install-host-cloog)
ifeq ($(ENABLE_GRAPHITE),yes)
$(stamp-install-host-cloog): $(stamp-build-host-cloog)
	$(MAKE) -C ${CLOOG_BUILD_PATH} install-libLTLIBRARIES \
	   install-pkgincludeHEADERS
	$(MAKE) -C $(CLOOG_BUILD_PATH)/isl install-libLTLIBRARIES \
	   install-pkgincludeHEADERS
	$(MAKE) -C ${CLOOG_BUILD_PATH} install
	$(STAMP) $@
else # !ENABLE_GRAPHITE
$(stamp-install-host-cloog):
	$(STAMP) $@
endif # ENABLE_GRAPHITE

#=======================================
# expat
# host expat rules
.PHONY: config-host-expat build-host-expat install-host-expat

stamp-config-host-expat := $(TARGET_OUT_ROOT)/stamp-config-host-expat
stamp-build-host-expat := $(TARGET_OUT_ROOT)/stamp-build-host-expat
stamp-install-host-expat := $(TARGET_OUT_ROOT)/stamp-install-host-expat

config-host-expat: $(stamp-config-host-expat)

EXPAT_BUILD_PATH := $(TARGET_OUT_ROOT)/$(EXPAT_PATH)

EXPAT_CONFIGURE := $(WORKSPACE)/$(EXPAT_ABS_PATH)/configure
INTERNAL_EXPAT_CONFIG_ARGS := \
    --prefix=${EXPAT_DIR} \
    --build=$(CURRENT_BUILD) \
    --host=$(CURRENT_HOST) \
    --disable-shared

EXPAT_CONFIG_ARGS := \
    $(INTERNAL_EXPAT_CONFIG_ARGS) \
    $(EXTRA_EXPAT_CONFIG_ARGS)

$(stamp-config-host-expat):
	([ -d ${EXPAT_BUILD_PATH} ] || \
	  mkdir -p ${EXPAT_BUILD_PATH}) && \
	(cd ${EXPAT_BUILD_PATH} ; \
	  ${EXPAT_CONFIGURE} ${EXPAT_CONFIG_ARGS}) && \
	$(STAMP) $@

build-host-expat: $(stamp-build-host-expat)
$(stamp-build-host-expat): $(stamp-config-host-expat)
	$(MAKE) -C ${EXPAT_BUILD_PATH} && $(STAMP) $@

install-host-expat: $(stamp-install-host-expat)
$(stamp-install-host-expat): $(stamp-build-host-expat)
	$(MAKE) -C ${EXPAT_BUILD_PATH} install && $(STAMP) $@
