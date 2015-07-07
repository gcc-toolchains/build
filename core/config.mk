#
# Copyright (C) 2015 The Yudatun Open Source Project
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation
#

include $(BUILD_SYSTEM)/envsetup.mk

BUILD_COMBOS := $(BUILD_SYSTEM)/combo

combo_target := HOST_
include $(BUILD_COMBOS)/select.mk

include $(BUILD_SYSTEM)/dumpvar.mk
