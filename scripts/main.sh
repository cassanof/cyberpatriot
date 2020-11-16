#!/bin/bash
# Made and owned by Federico Cassano
# must be run as root/sudo
# before using the script, enable raccomended and critical updates

# update and upgrade
apt update
apt upgrade
# and try to install programs
apt install gcc make vim zsh libx11-dev libxinerama libxft

# enable ufw, with ports to ssh
ufw enable
ufw allow ssh
