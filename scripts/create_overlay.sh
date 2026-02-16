#!/bin/bash
set -xe
# This script creates an overlay partition on an empty img file for users to flash when they dont have linux

CURR_DIR=$(dirname "$(readlink -f "$0")")
mkdir -p "$CURR_DIR/../build"
image_location=$(realpath "$CURR_DIR/../build/overlay.img")
dd if=/dev/zero of=$image_location bs=1M count=512
# create one partition called mirte_root with ext4 in the overlay
parted $image_location mklabel msdos
LOOP_DEV=$(losetup -f --show $image_location)
ls -lh $LOOP_DEV
{
	fdisk $LOOP_DEV <<EOF
n
p
1


w
EOF
} || true
sync
partx -a $LOOP_DEV
# create a filesystem on the partition
mkfs.ext4 "${LOOP_DEV}p1" -L mirte_root

# # unmount the loop device
losetup -d $LOOP_DEV
wget https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh -O pishrink.sh
chmod +x pishrink.sh
./pishrink.sh -s -v -Z $image_location
