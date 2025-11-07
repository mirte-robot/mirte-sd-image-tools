#!/bin/bash
set -xe
echo "${type:=""}"

# disable ipv6, as not all package repositories are available over ipv6
sudo tee /etc/apt/apt.conf.d/99force-ipv4 <<EOF
Acquire::ForceIPv4 "true";
EOF

# Fix DNS on rpi4b
# if [[ $type == "mirte_rpi4b" ]]; then
rm /etc/resolv.conf || true
echo "nameserver 8.8.8.8" >/etc/resolv.conf || true
# fi
nslookup ports.ubuntu.com || true

sudo rm /etc/apt/sources.list.d/armbian.list || true

chown root:root /usr/bin/sudo && chmod 4755 /usr/bin/sudo # something with sudo otherwise complaining about "sudo: /usr/bin/sudo must be owned by uid 0 and have the setuid bit set"
. /usr/local/src/mirte/settings.sh                        # load settings
mkdir /usr/local/src/mirte/build_system/ || true
apt update
apt install -y git python3-pip curl

apt update || true
pip3 install vcstool
apt install -y python3-pip python3-dev libblas-dev liblapack-dev libatlas-base-dev gfortran
cd /usr/local/src/mirte/
# Download all the mirte repos
vcs import --workers 1 --input ./repos.yaml --skip-existing --shallow || true

# pip3 install "deepdiff[cli]"
# deep diff --ignore-order --ignore-string-case ./repos.yaml ./mirte-install-scripts/repos.yaml # to show the difference between the repos.yaml in here and in mirte-install-scripts/repos.yaml
# overwrite the repos.yaml in mirte-install-scripts with the one in here
cp ./repos.yaml ./mirte-install-scripts/repos.yaml

# create mirte user and allow sudo without password
cd /usr/local/src/mirte/mirte-install-scripts/ && ./create_user.sh
echo 'mirte ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers
chown -R mirte /usr/local/src/mirte/*

if false; then
	sed -i 's/PermitRootLogin.*$/PermitRootLogin no/g' /etc/ssh/sshd_config
fi
# install prebuilt wheels when on orangepizero, as numpy takes ages to build
if [[ $type == "mirte_orangepizero" ]]; then
	pip3 install /usr/local/src/mirte/wheels/*
fi

# install mirte
sudo -i -u mirte bash -c 'export MAKEFLAGS=\"-j$(nproc)\"; cd /usr/local/src/mirte/mirte-install-scripts/ && ./install_mirte.sh'
sed -i '$ d' /etc/sudoers

# if expire passwd is enabled, expire the password
if $EXPIRE_PASSWD; then passwd --expire mirte; fi
if $INSTALL_NETWORK; then /usr/local/src/mirte/mirte-install-scripts/network_install.sh; fi
# for script in $${EXTRA_SCRIPTS[@]}; do /usr/local/src/mirte/$script; done

# to use overlayroot: create an sd or usb with an ext4 partition with the label mirte_root. Any changes on the system will be put on the sd/usb instead of the main root file system (emmc)
echo 'overlayroot=device:dev=LABEL=mirte_root,timeout=2' | sudo tee -a /etc/overlayroot.conf # overlayroot

# install provisioning (not yet on main branch)
# if $INSTALL_PROVISIONING; then
#     mkdir /mnt/mirte # create mount point and automount it
#     echo 'UUID="9EE2-A262" /mnt/mirte/ vfat rw,relatime,uid=1000,gid=1000,errors=remount-ro 0 0' >>/etc/fstab;
# fi

if $ADD_OVERLAY_PARTITION; then
	systemctl disable armbian-resize-filesystem # this will be done better by our script
fi

sudo apt autoremove && sudo apt clean && sudo rm -rf /var/lib/apt/lists/*
