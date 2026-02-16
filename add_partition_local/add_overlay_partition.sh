#!/bin/bash
set -ex

image_file=$1

add__overlay_partition() {
	startLocation=$(sfdisk -l -o end -N1 "$image_file" | tail -1)
	extraSize="10M"
	startLocation=$((startLocation + 1))
	dd if=/dev/zero bs=1M count=10 >>"$image_file"
	# echo "+$extraSize" | sfdisk --move-data -N 1 "$image_file"
	echo "$startLocation, $extraSize" | sfdisk -a "$image_file"
	sleep 5
	loop=$(kpartx -av "$image_file")
	echo $loop
	loopvar=$(echo $loop | grep -oP 'loop[0-9]*' | head -1)
	echo $loopvar
	mkfs.ext4 /dev/mapper/${loopvar}p2 -L "mirte_root"
	sleep 5
	kpartx -dv /dev/${loopvar}
}

if sfdisk -l "$image_file" | grep -q '.img2'; then
	echo "Already contains extra partition"
else
	add__overlay_partition
fi

echo "done"
