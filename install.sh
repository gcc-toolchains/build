#!/bin/bash

usage="Usage: $0 SRC_DIR DST_DIR"

if [ ! \( -d "$1" \) ] ; then
    echo $usage
    exit 1
fi

src_dir=$1
dst_dir=$2

src_dir_len=`echo ${#src_dir}`

STRIP_CMD="strip --strip-all"
TARGET_STRIP_CMD="$TARGET-strip --strip-debug"

function do_dir()
{
    for item in [ `ls $1` ] ; do
        if [ -d "$1/$item" ] ; then
            do_dir "$1/$item"
        elif [ \( "$item" != "[" \) -a \( "$item" != "]" \) ] ; then
            str=$1
            sub_dir=${str:$src_dir_len}
            dst_sub_dir=$dst_dir/$sub_dir

            mkdir -p $dst_sub_dir
            format=`file $1/$item`
            case $format in
                *ELF*x86-64*)
                    echo "Strip $1/$item to $dst_sub_dir/$item ..."
                    $STRIP_CMD $1/$item -o $dst_sub_dir/$item
                    ;;
                *ELF*ARM*)
                    echo "Strip $1/$item to $dst_sub_dir/$item ..."
                    $TARGET_STRIP_CMD $1/$item -o $dst_sub_dir/$item
                    ;;
                *)
                    echo "Copy $1/$item to $dst_sub_dir/$item ..."
                    cp -d $1/$item $dst_sub_dir/$item
                    ;;
            esac
        fi
    done
}

do_dir $src_dir
