#!/bin/bash
set -ex

image_file=$1
parent_path=$(
	cd "$(dirname "${BASH_SOURCE[0]}")"
	pwd -P
)

add_partition() {
	startLocation=$(sfdisk -l -o start -N1 "$image_file" | tail -1)
	# should be 40960 for zero2, 8192 for zero1

	extraSize="100M"

	dd if=/dev/zero bs=1M count=100 >>"$image_file"
	echo "+$extraSize" | sfdisk --move-data -N 1 "$image_file"
	echo "$startLocation, $extraSize, b" | sfdisk -a "$image_file"
	sleep 5
	loop=$(kpartx -av "$image_file")
	echo $loop
	loopvar=$(echo $loop | grep -oP 'loop[0-9]*' | head -1)
	echo $loopvar
	mkfs.fat /dev/mapper/${loopvar}p2 -n "MIRTE" -i "9EE2A262" # some random id from a previous build, must be the same as in build.pkr.hcl
	mount_dir=$(mktemp -d)
	echo $mount_dir
	mount -v /dev/mapper/${loopvar}p2 $mount_dir
	cp -r "$parent_path/default_partition_files/." $mount_dir
	ls $mount_dir
	sleep 5
	umount -v /dev/mapper/${loopvar}p2
	sleep 5
	kpartx -dv /dev/${loopvar}
	rm -rf $mount_dir
}

copy_files() {
	loop=$(kpartx -av "$image_file")
	echo $loop
	loopvar=$(echo $loop | grep -oP 'loop[0-9]*' | head -1)
	echo $loopvar
	mount_dir=$(mktemp -d)
	echo $mount_dir
	mount -v /dev/mapper/${loopvar}p2 $mount_dir
	cp -r "$parent_path/default_partition_files/." $mount_dir
	ls $mount_dir
	sleep 5
	umount -v /dev/mapper/${loopvar}p2
	sleep 5
	kpartx -dv /dev/${loopvar}
	rm -rf $mount_dir
}

if sfdisk -l "$image_file" | grep -q '.img2'; then
	echo "Already contains extra partition, only copying default files"
else
	add_partition
fi

copy_files

$parent_path/../pishrink.sh "$image_file"

echo "done"
