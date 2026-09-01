#!/bin/bash
set -ex

image_file=$1

add__overlay_partition() {
	# sfdisk -l -o end -N1 "$image_file"
	# sfdisk -l -o end -N1 -q "$image_file" | grep -oP '[0-9]*'
	# sfdisk -l -o end -N1 -q "$image_file" | grep -oP '[0-9]*' | sort
	# sfdisk -l -o end -N1 -q "$image_file" | grep -oP '[0-9]*' | sort | tail -1
	startLocation=$(sfdisk -l -o end -N1 -q "$image_file" | grep -oP '[0-9]*' | sort | tail -1)
	extraSize="10M"
	startLocation=$((startLocation + 1))
	dd if=/dev/zero bs=1M count=10 >>"$image_file" # add data to end of img
	# echo "+$extraSize" | sfdisk --move-data -N 1 "$image_file"
	echo "$startLocation, $extraSize" | sfdisk -a "$image_file" # add partition at end
	sleep 5
	loop=$(kpartx -av "$image_file") # mount the image

	echo $loop
	loopvar=$(echo $loop | grep -oP 'loop[0-9]*' | head -1)
	echo $loopvar
	# get partition labels, if mirte_root is already there, don't create it again
	labels=$(lsblk -o NAME,LABEL | grep ${loopvar}p | awk '{print $2}')
	if echo "$labels" | grep -q "mirte_root"; then
		echo "mirte_root partition already exists, skipping creation"
	else
		# get number for new partition, might be 2 or 3
		partnum=$(sfdisk -l -q -o "Device" "$image_file" | grep ".img" | tail -1 | grep -oP '[0-9]*$')
		echo $partnum
		sleep 5
		mkfs.ext4 /dev/mapper/${loopvar}p${partnum} -L "mirte_root"
		sleep 5
	fi
	kpartx -dv /dev/${loopvar} #unmount the image
}

# if sfdisk -l "$image_file" | grep -q '.img2'; then # change to check for ext4?
# 	echo "Already contains extra partition"
# else
add__overlay_partition
# fi

echo "done"
