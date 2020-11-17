#!/bin/bash
# Made and owned by Federico Cassano
# must be run as root/sudo
# before using the script:
# 1. Open updates gui app
# 2. Enable raccomended and critical updates
# 3. Enable daily updates


read -p "Install updates and programs? (libx,make,vim,zsh) [y/n]: " a
if [ $a = y ];
then
  # update and upgrade
  apt update -y
  apt upgrade -y
  apt dist-upgrade -y
  # and try to install programs
  apt install gcc make vim zsh libx11-dev libxinerama libxft -y

  read -p "Update firefox? WILL KILL FIREFOX PROCESS! [y/n]: " a
  if [ $a = y ];
  then
    killall firefox
    apt-get --purge --reinstall install firefox -y
  fi
fi

read -p "Enable firewall (ufw)? [y/n]: " a
if [ $a = y ];
then
  # enable ufw
  ufw enable

  read -p "Any services/ports to ALLOW? [y/n]: " a
  while [ $a = y ]
	do
		read -p "Enter the service/port (ufw allow [option]): " option
		ufw allow $option
		read -p "Are there any more services/ports to ALLOW? [y/n]: " a
	done

  read -p "Any services/ports to DENY? [y/n]: " a
  while [ $a = y ]
	do
		read -p "Enter the service/port (ufw deny [option]): " option
		ufw deny $option
		read -p "Are there any more services/ports to DENY? [y/n]: " a
	done
fi
