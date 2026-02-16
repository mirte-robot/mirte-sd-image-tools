#!/bin/bash

chmod +x /root/mirte-install.sh
cp /root/mirte-install.service /etc/systemd/system/
systemctl enable mirte-install.service
