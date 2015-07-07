#
# Copyright (C) 2015 The Yudatun Open Source Project
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation

function hmm() {
cat <<EOF
Invoke ". build/envsetup.sh" from your shell to add the following functions to your environment:
- lunch: lunch <arch>-<target>
- croot: Changes directory to the top of the tree.
EOF
}

# Clear this variable. It will be built up again when the vendorsetup.sh
# files are included at the end of this file
unset LUNCH_MENU_CHOICES
function add_lunch_combo()
{
    local new_combo=$1
    local c
    for c in ${LUNCH_MENU_CHOICES[@]} ; do
        if [ "$new_combo" = "$c" ] ; then
            return
        fi
    done
    LUNCH_MENU_CHOICES=(${LUNCH_MENU_CHOICES[@]} $new_combo)
}

add_lunch_combo arm_arm-eabi
add_lunch_combo arm_arm-linux-gnueabi

function lunch()
{
    local answer

    if [ "$1" ] ; then
        answer=$1
    else
        print_lunch_menu
        echo -n "Which would you like? [arm_arm-eabi] "
        read answer
    fi

    local selection=

    if [ -z "$answer" ] ; then
        selection="arm_arm-eabi"
    elif (echo -n $answer | grep -q -e "^[0-9][0-9]*$") ; then
        if [ $answer -le ${#LUNCH_MENU_CHOICES[@]} ] ; then
            selection=${LUNCH_MENU_CHOICES[$(($answer-1))]}
        fi
    elif (echo -n $answer | grep -q -e "^[^\-][^\-]*-[^\-][^\-]*$") ; then
        selection=$answer
    fi

    if [ -z "$selection" ] ; then
        echo
        echo "Invalid lunch combo: $answer"
        return 1
    fi

    local arch=$(echo -n $selection | sed -e "s/_.*$//")
    check_arch $arch
    if [ $? -ne 0 ] ; then
        echo
        echo "** Don't have a arch spec for: '$arch'"
        echo "** Do you have the right repo manifest?"
        arch=
    fi

    local target=$(echo -n $selection | sed -e "s/^[^\_]*_//")
    check_target $target
    if [ $? -ne 0 ] ; then
        echo
        echo "** Don't have a target spec for: '$target'"
        echo "** Do you have the right repo manifest?"
        target=
    fi

    if [ -z "$arch" -o -z "$target" ] ; then
        echo
        return 1
    fi

    set_host_info
    set_target_info $arch $target

    print_config
}

ARCH_CHOICES=(arm)
function check_arch()
{
    for v in ${ARCH_CHOICES[@]} ; do
        if [ "$v" = "$1" ] ; then
            return 0
        fi
    done
    return 1
}

TARGET_CHOICES=(arm-eabi arm-linux-gnueabi)
function check_target()
{
    for v in ${TARGET_CHOICES[@]} ; do
        if [ "$v" = "$1" ] ; then
            return 0
        fi
    done
    return 1
}

function print_lunch_menu()
{
    local uname=$(uname)
    echo
    echo "You're building on" $uname
    echo
    echo "Lunch menu ... pick a combo:"

    local i=1
    local choice
    for choice in ${LUNCH_MENU_CHOICES[@]} ; do
        echo "    $i. $choice"
        i=$(($i+1))
    done
    echo
}

function set_host_info()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree. Try setting TOP."
        return
    fi
    WORKSPACE=
    export WORKSPACE=$T

    # GCC can not find GNU as/GNU ld
    # GCC searches the PATH for an assembler and a linker
    # https://gcc.gnu.org/faq.html
    local gcc_path=$(echo -n `which gcc`)
    export PATH=${gcc_path%%gcc}:$PATH
}

function set_target_info()
{
    TARGET_TOOLCHAINS_ARCH=
    TARGET=
    export TARGET_TOOLCHAINS_ARCH=$1
    export TARGET=$2
    export TARGET_LIBC=
    export TARGET_BUILD_APP=
    case $TARGET in
        *arm-eabi*)
            ;;
        *arm-linux-gnueabi*)
            export TARGET_LIBC=glibc
            export TARGET_BUILD_APP=yes
            ;;
        *)
            echo "WARNING: $TARGET don't supported."
            ;;
    esac

    BUILD_YUDATUN_GCC=
    TARGET_OS=
    export BUILD_YUDATUN_GCC=yes
    export TARGET_OS=Yudatun

    ENABLE_GRAPHITE=
    export ENABLE_GRAPHITE=yes
    if [ "$ENABLE_GRAPHITE" = "yes" ] ; then
        local gcc_version=$(get_build_var GCC_VERSION)
        case $gcc_version in
            # See https://gcc.gnu.org/gcc-5/changes.html
            5.1.*)
                export ENABLE_GRAPHITE_USE_CLOOG=no
                ;;
            *)
                export ENABLE_GRAPHITE_USE_CLOOG=yes
                ;;
        esac
    fi

    # Deafult linker for gcc
    ENABLE_GOLD=
    ENABLE_LD_DEFAULT=
    export ENABLE_GOLD=
    export ENABLE_LD_DEFAULT=yes
}

function print_config()
{
   T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree. Try setting TOP."
        return
    fi
    get_build_var report_config
}

function get_build_var()
{
   T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree. Try setting TOP."
        return
    fi
    CALLED_FROM_SETUP=true BUILD_SYSTEM=build/core \
        make --no-print-directory -C "$T" -f build/core/config.mk dumpvar-$1
}

# Get the value of a build variable as an absolute path.
function get_abs_build_var()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree. Try setting TOP."
        return
    fi
    (\cd $T; CALLED_FROM_SETUP=true BUILD_SYSTEM=build/core \
        make --no-print-directory -C "$T" -f build/core/config.mk dumpvar-abs-$1)
}

function croot()
{
    T=$(gettop)
    if [ "$T" ] ; then
        cd $T
    else
        echo "Couldn't locate the top of the tree. Try setting TOP."
    fi
}

function gettop()
{
    local TOPFILE=build/envsetup.sh
    if [ -n "$TOP" -a -f "$TOP/$TOPFILE" ] ; then
        echo $TOP
    else
        if [ -f $TOPFILE ] ; then
            # The following circumlocution (repeated below as well) ensures
            # that we record the true directory name and not one that is faked
            # up with symlink names.
            PWD= /bin/pwd
        else
            local HERE=$PWD
            T=
            # The following codes ensures that goto a directory which can
            # found file "build/core/envsetup.mk"
            while [ \( ! \( -f $TOPFILE \) \) -a \( $PWD != "/" \) ] ; do
                \cd ..
                T=$(PWD= /bin/pwd)
            done
            \cd $HERE
            if [ -f "$T/$TOPFILE" ] ; then
                echo $T
            fi
        fi
    fi
}

if [ "x$SHELL" != "x/bin/bash" ]; then
    case `ps -o command -p $$` in
        *bash*)
            ;;
        *)
            echo "WARNING: Only bash is supported, use of other shell would lead to erroneous results"
            ;;
    esac
fi

echo "Setup environment successful."
