#!/bin/bash
# Made and owned by Federico Cassano
# its suggested to use common.sh before this script

_l="/etc/login.defs"
_p="/etc/passwd"

## get min UID limit ##
MINUID=$(grep "^UID_MIN" $_l)
 
## get max UID limit ##
MAXUID=$(grep "^UID_MAX" $_l)


read -p "Do valid user check? [y/n]: " a
if [ $a = y ];
then
  for x in `
      awk -F':' -v "min=${MINUID##UID_MIN}" -v "max=${MAXUID##UID_MAX}" '{ if ( $3 >= min && $3 <= max  && $7 != "/sbin/nologin" ) print $0 }' "$_p" \
        | cut -d: -f1 -
    `
  do
    read -p "Is $x a valid user? [y/n]: " a
    if [ $a = n ];
    then
      mv /home/$x /home/dis_$x
      sed -i -e "/$x/ s/^#*/#/" /etc/passwd
      sleep 1
    else
      echo "$x" >> ./existingusers.txt
    fi
  done
fi

read -p "Want to add any users? [y/n]: " a
if [ $a = y ];
then
  while [ $a = y ]
	do
		read -p "Please enter the name of the user: " user
		useradd $user
		mkdir /home/$user
		read -p "Are there any more users you would like to add? [y/n]: " a
	done
fi


read -p "Want to do an admin check? [y/n]: " a
if [ $a = y ];
then
  for x in `
      awk -F':' -v "min=${MINUID##UID_MIN}" -v "max=${MAXUID##UID_MAX}" '{ if ( $3 >= min && $3 <= max  && $7 != "/sbin/nologin" ) print $0 }' "$_p" \
        | cut -d: -f1 -
    `
	do
		read -p "Is $x considered an admin?[y/n]: " a
		if [ $a = y ]
		then
			#Adds to the adm group
			sudo usermod -a -G adm $x

			#Adds to the lpadmin group
			sudo usermod -a -G lpadmin $x

			#Adds to the sudo group
			sudo usermod -a -G sudo $x
		else
			#Removes from the adm group
			sudo deluser $x adm

			#Removes from the adm group
			sudo deluser $x lpadmin

			#Removes from the sudo group
			sudo deluser $x sudo
		fi
	done
fi

read -p "Change all user passwords to Cyb3rPatr!0t$ ? [y/n]: " a
if [ $a = y ];
then
	PASS='Cyb3rPatr!0t$'

  for x in `
      awk -F':' -v "min=${MINUID##UID_MIN}" -v "max=${MAXUID##UID_MAX}" '{ if ( $3 >= min && $3 <= max  && $7 != "/sbin/nologin" ) print $0 }' "$_p" \
        | cut -d: -f1 -
    `
	do
		echo -e "$PASS\n$PASS" | passwd $x
		echo -e "!!! Password for $x has been changed to $PASS"
		# Change the USER password policy
		chage -M 90 -m 7 -W 15 $x
	done
fi

read -p "Secure and lock root user? [y/n]: " a
if [ $a = y ];
then
	PASS='Cyb3rPatr!0t$'


	echo -e "$PASS\n$PASS" | passwd root
  passwd -l root
	chage -M 90 -m 7 -W 15 root
  echo "!!! Root user locked and secured"
fi

