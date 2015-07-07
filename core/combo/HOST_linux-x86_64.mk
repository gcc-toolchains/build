#
# Copyright (C) 2015 The Yudatun Open Source Project
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation
#

# Configuration for builds hosted on linux-x86_64.
# Included by combo/select.mk

ifeq ($(strip $(HOST_TOOLCHAIN_PREFIX)),)
HOST_TOOLCHAINS_PREFIX := prebuilts/x86_64-linux-glibc2.15-4.8/bin/x86_64-linux-
endif
