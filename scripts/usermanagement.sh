#!/bin/sh

	for x in `cut -d: -f1 /etc/passwd`
	do
		read -p "Is $x a valid user?[y/n]: " a
		if [ $a = n ] || [ $a = "" ];
		then
			mv /home/$x /home/dis_$x
			sed -i -e "/$x/ s/^#*/#/" /etc/passwd
			sleep 1
    else
      echo "$x" >> existingusers
		fi
	done
