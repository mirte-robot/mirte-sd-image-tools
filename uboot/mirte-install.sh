#!/bin/bash

source /usr/lib/u-boot/platform_install.sh
write_uboot_platform_mtd $DIR /dev/mtdblock0

shutdown now
