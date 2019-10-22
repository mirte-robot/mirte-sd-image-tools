#!/bin/bash

# Install Zoef SD card scripts
sudo apt install -y git
cd ~
git clone https://gitlab.tudelft.nl/rcj_zoef/zoef_sd_card_image.git

# Install ROS Melodic
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
sudo apt update
sudo apt upgrade -y
sudo apt install -y ros-melodic-ros-base python-rosinstall python-rosinstall-generator python-wstool build-essential python-catkin-tools
grep -qxF "source /opt/ros/melodic/setup.bash" ~/.bashrc || echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
source /opt/ros/melodic/setup.bash

# Install pymata and allow usage of usb device
sudo apt install git python-pip -y
sudo -H python -m pip install pymata

# Install Zoef ROS package (TODO: create rosinstall/rosdep)
sudo apt install -y ros-melodic-controller-manager ros-melodic-rosbridge-server ros-melodic-diff-drive-controller
mkdir -p ~/zoef_ws/src
cd ~/zoef_ws/src
git clone https://gitlab.tudelft.nl/rcj_zoef/zoef_ros_package.git
cd ..
catkin build
grep -qxF "source /home/zoef/zoef_ws/devel/setup.bash" ~/.bashrc || echo "source /home/zoef/zoef_ws/devel/setup.bash" >> ~/.bashrc
source /home/zoef/zoef_ws/devel/setup.bash

# Add systemd service to start ROS nodes
sudo bash -c "echo '[Unit]' > /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo 'Description=Zoef ROS' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo 'After=network.target' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo 'After=ssh.service' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo 'After=network-online.target' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo '' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo '[Service]' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo 'ExecStart=/bin/bash -c \"source /home/zoef/zoef_ws/devel/setup.bash && roslaunch zoef_ros_package hw_control.launch\"' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo '' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo '[Install]' >> /lib/systemd/system/zoef_ros.service"
sudo bash -c "echo 'WantedBy=multi-user.target' >> /lib/systemd/system/zoef_ros.service"

#sudo bash -c "echo '#!/usr/bin/env bash' > /root/zoef_ros.sh"
#sudo bash -c "echo 'bash -c \"source /home/zoef/zoef_ws/devel/setup.bash && roslaunch zoef_ros_package hw_control.launch\"' >> /root/zoef_ros.sh"
#sudo chmod +x /root/zoef_ros.sh

sudo systemctl daemon-reload
sudo systemctl stop zoef_ros || /bin/true
sudo systemctl start zoef_ros
sudo systemctl enable zoef_ros

# Install Zoef Interface
sudo apt install -y singularity-container
cd ~
git clone https://gitlab.tudelft.nl/rcj_zoef/web_interface.git
cd web_interface
sed -i 's/From: ubuntu:bionic/From: arm32v7\/ubuntu:bionic/g' Singularity
./run_singularity.sh build_dev

# Add systemd service to start ROS nodes
# NOTE: starting singularity image form ssystemd has some issues (https://github.com/sylabs/singularity/issues/1600)
sudo bash -c "echo '[Unit]' > /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo 'Description=Zoef Web Interface' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo 'After=network.target' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo 'After=ssh.service' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo 'After=network-online.target' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo '' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo '[Service]' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo 'ExecStart=/bin/bash -c \"cd /home/zoef/web_interface/ && singularity run zoef_web_interface 2>&1 | tee\"' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo '' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo '[Install]' >> /lib/systemd/system/zoef_web_interface.service"
sudo bash -c "echo 'WantedBy=multi-user.target' >> /lib/systemd/system/zoef_web_interface.service"

sudo systemctl daemon-reload
sudo systemctl stop zoef_web_interface || /bin/true
sudo systemctl start zoef_web_interface
sudo systemctl enable zoef_web_interface

