#!/bin/bash

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
