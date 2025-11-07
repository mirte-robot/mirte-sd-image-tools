#!/bin/bash

export INSTALL_DOCS=false
export INSTALL_ROS=true # FIXME: Non-functional: can a useable mirte install be made without ROS?
export INSTALL_ARDUINO=false
export INSTALL_WEB=true
# Python should also be active when Web is active, however this is not enforced (otherwise limited functionality)
# TODO: Should this be enforced
export INSTALL_PYTHON=true
export INSTALL_JUPYTER=false # FIXME: Non-functional: Not setup for ROS2
export EXPIRE_PASSWD=true
export INSTALL_NETWORK=true
export INSTALL_PROVISIONING=false # FIXME: Non-functional: Not setup
export INSTALL_VSCODE=true
export INSTALL_PAM=true     # FIXME: Non-functional: can a useable mirte install be made without?
export MIRTE_TYPE="default" # or mirte-master
export EXTRA_SCRIPTS=(
	# "testExtra.sh"
	# "testExtra2.sh"
)
export PARALLEL=true
export ADD_OVERLAY_PARTITION=true
export INSTALL_ARDUINO_ALL=false # install all arduino&pico things (compiler, sdks, ...)
# Functional Settings:
#  - INSTALL_WEB
#  - INSTALL_PYTHON
#  - INSTALL_VSCODE
