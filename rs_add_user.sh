#!/bin/bash

if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi
newLine="==========================================="
sDir=$(dirname $0)
. ${sDir}/lib/function.sh

lToGroup=(`cat "$sDir/conf/groups"`)

echo ${newLine}

while read user
do
	IFS=:
	aUser=($user)
	if [ ${#aUser[*]} -gt 1 ]; then
		$(addUser ${aUser[0]})
		if [ $? -ne 0 ]; then
			exit 1
		fi
		for group in ${lToGroup[@]}
		do
			$(addUsertoGroup ${aUser[0]} ${group})
			if [ $? -ne 0 ]; then
				exit 1
			fi
		done
		$(addPublicKey ${aUser[0]} ${aUser[1]})
		if [ $? -ne 0 ]; then
			exit 1
		fi
		echo ${newLine}
	fi
done < "$sDir/conf/user_list"
