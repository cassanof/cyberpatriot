#!/bin/bash
# Made and owned by Federico Cassano
# must be run as root/sudo
# before using the script:
# 1. Open updates GUI app
# 2. Enable raccomended and critical updates
# 3. Enable daily updates


read -p "Do a backup of critical files? *raccomended* [y/n]: " a
if [ $a = y ];
then
	mkdir /Backups
	#Backups the sudoers file
	sudo cp /etc/sudoers /Backups
	#Backups the home directory
	cp /etc/passwd /Backups
	#Backups the log files
	cp -r /var/log /Backups
	#Backups the passwd file
	cp /etc/passwd /Backups
	#Backups the group file
	cp /etc/group /Backups
	#Back ups the shadow file
	cp /etc/shadow /Backups
	#Backing up the /var/spool/mail
	cp -r /var/spool/mail /Backups
	#backups all the home directories
	for x in `ls /home`
	do
		cp -r /home/$x /Backups
	done
  echo "!!! Backup done! can be found at the folder /Backups"
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
  echo "!!! Installed updates and programs"

  read -p "Update firefox? *WILL KILL FIREFOX PROCESS!* [y/n]: " a
  if [ $a = y ];
  then
    killall firefox
    echo "!!! Firefox killed"
    apt-get --purge --reinstall install firefox -y
    echo "!!! Updated and reinstalled Firefox"
  fi

  read -p "Update LibreOffice? [y/n]" a
  if [ $a = y ];
  then
    apt-get --purge --reinstall install libreoffice -y
    echo "!!! Updated and reinstalled LibreOffice"
  fi
fi

read -p "Enable firewall (ufw)? [y/n]: " a
if [ $a = y ];
then
  # install ufw
  apt install ufw -y

  # enable ufw
  ufw enable
  echo "!!! Ufw firewall installed and enabled"

  read -p "Any services/ports to ALLOW? [y/n]: " a
  while [ $a = y ]
	do
		read -p "Enter the service/port (ufw allow [option]): " option
		ufw allow $option
    echo "!!! Service/port: $option allowed in the firewall"
		read -p "Are there any more services/ports to ALLOW? [y/n]: " a
	done

  read -p "Any services/ports to DENY? [y/n]: " a
  while [ $a = y ]
	do
		read -p "Enter the service/port (ufw deny [option]): " option
		ufw deny $option
    echo "!!! Service/port: $option disabled in the firewall"
		read -p "Are there any more services/ports to DENY? [y/n]: " a
	done
fi


read -p "Set and password and lockout policy? [y/n]: " a
if [ $a = y ];
then
  # install cracklib
  apt install libpam-cracklib -y
  echo "!!! Cracklib installed"

  # set password policy
 	sed -i -e 's/PASS_MAX_DAYS\t[[:digit:]]\+/PASS_MAX_DAYS\t90/' /etc/login.defs
	sed -i -e 's/PASS_MIN_DAYS\t[[:digit:]]\+/PASS_MIN_DAYS\t10/' /etc/login.defs
	sed -i -e 's/PASS_WARN_AGE\t[[:digit:]]\+/PASS_WARN_AGE\t7/' /etc/login.defs
	sed -i -e 's/difok=3\+/difok=3 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1/' /etc/pam.d/common-password
  echo "!!! Password policy set"

  # set lockout policy
  sed -i 's/auth\trequisite\t\t\tpam_deny.so\+/auth\trequired\t\t\tpam_deny.so/' /etc/pam.d/common-auth
	sed -i '$a auth\trequired\t\t\tpam_tally2.so deny=5 unlock_time=1800 onerr=fail' /etc/pam.d/common-auth
	sed -i 's/sha512\+/sha512 remember=13/' /etc/pam.d/common-password

  echo "!!! Lockout policy set"
fi

read -p "Secure shadow file? [y/n]: " a
if [ $a = y ];
then
  chmod 640 /etc/shadow
	ls -l /etc/shadow
fi

read -p "Remove world readability permissions from /home/*? [y/n]: " a
if [ $a = y ];
then
  chmod 0750 /home/*
	ls -l /home/
fi

read -p "Log running processes? [y/n]: " a
if [ $a = y ];
then
  lsof -Pnl +M -i > runningProcesses.log

	# Remove "normal" processes
	sed -i '/avahi-dae/ d' runningProcesses.log
	sed -i '/cups-brow/ d' runningProcesses.log
	sed -i '/dhclient/ d' runningProcesses.log
	sed -i '/dnsmasq/ d' runningProcesses.log
	sed -i '/cupsd/ d' runningProcesses.log
fi
