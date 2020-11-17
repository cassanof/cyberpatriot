#!/bin/bash
# Made and owned by Federico Cassano
# must be run as root/sudo
# before using the script:
# 1. Open updates gui app
# 2. Enable raccomended and critical updates
# 3. Enable daily updates


read -p "Do a backup of critical files? *raccomended* [y/n]: " a
if [ $a = y ];
then
	mkdir /BackUps
	#Backups the sudoers file
	sudo cp /etc/sudoers /Backups
	#Backups the home directory
	cp /etc/passwd /BackUps
	#Backups the log files
	cp -r /var/log /BackUps
	#Backups the passwd file
	cp /etc/passwd /BackUps
	#Backups the group file
	cp /etc/group /BackUps
	#Back ups the shadow file
	cp /etc/shadow /BackUps
	#Backing up the /var/spool/mail
	cp -r /var/spool/mail /BackUps
	#backups all the home directories
	for x in `ls /home`
	do
		cp -r /home/$x /BackUps
	done
fi

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

  read -p "Update LibreOffice? [y/n]" a
  if [ $a = y ];
  then
    apt-get --purge --reinstall install libreoffice -y
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
