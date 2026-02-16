#!/bin/bash

# disable ipv6, as not all package repositories are available over ipv6
sudo tee /etc/apt/apt.conf.d/99force-ipv4 <<EOF
Acquire::ForceIPv4 "true";
EOF

rm /etc/resolv.conf || true
echo "nameserver 8.8.8.8" >/etc/resolv.conf || true

chmod +x /root/mirte-install.sh
cp /root/mirte-install.service /etc/systemd/system/
systemctl enable mirte-install.service
# md5sum </root/mirte_orangepi3b.img.xz >/root/mirte_orangepi3b.img.md5sum
apt update
apt install progress cmake python3 python3-pip -y

# Install picotool to flash the pico
sudo apt install build-essential pkg-config libusb-1.0-0-dev cmake -y
cd /tmp/ || exit 1
git clone https://github.com/raspberrypi/pico-sdk.git # somehow needed for picotool
export PICO_SDK_PATH=/tmp/pico-sdk
git clone https://github.com/raspberrypi/picotool.git
cd picotool || exit 1
sudo cp udev/99-picotool.rules /etc/udev/rules.d/

mkdir build
cd build || exit 1
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j
sudo make install

cd /tmp || exit 1
rm -rf pico-sdk
rm -rf picotool

#  Download latest uf2 release, resulting in Telemetrix4RpiPico.uf2
cd /root/ || exit 1
# TODO:  Downlaods from arendjan/telemetrix4rpipico, as it isn't released yet on the official repo
# curl -s https://api.github.com/repos/arendjan/telemetrix4rpipico/releases/latest |
# 	grep ".*/Telemetrix4RpiPico.uf2" |
# 	cut -d : -f 2,3 |
# 	tr -d \" |
# 	wget -qi -
wget https://github.com/ArendJan/Telemetrix4RpiPico/releases/download/rolling/Telemetrix4RpiPico.uf2

pip install git+https://github.com/arendjan/tmx-pico-aio.git@modules

sudo apt autoremove && sudo apt clean
