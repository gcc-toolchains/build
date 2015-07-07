#
# Copyright (C) 2015 The Yudatun Open Source Project
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation
#

# -----------------------------------------------------------
# Select a combo based on the platforms being used.
#
# Inputs:
#     combo_target -- prefix for final varables (HOST_ or TARGET_)
#

# Build a target string like "linux-arm" or "linux-x86'.
combo_os_arch := $($(combo_target)OS)-$($(combo_target)ARCH)

# -----------------------------------------------------------
# Set reasonable defaults for the various variables
$(combo_target)CC := $(CC)
$(combo_target)CXX := $(CXX)
$(combo_target)AR := $(AR)
$(combo_target)STRIP := $(STRIP)

$(combo_target)GLOBAL_CFLAGS := -fno-exceptions -Wno-multichar
$(combo_target)RELEASE_CFLAGS := -O2 -g -fno-strict-aliasing
$(combo_var_prefix)GLOBAL_CPPFLAGS :=
$(combo_target)GLOBAL_LDFLAGS :=
$(combo_target)GLOBAL_ARFLAGS := crsP
$(combo_var_prefix)GLOBAL_LD_DIRS :=

# Now include the combo for this specific target.
include $(BUILD_COMBOS)/$(combo_target)$(combo_os_arch).mk
