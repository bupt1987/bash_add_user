#!/bin/bash

if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root" 1>&2
	exit 1
fi
sDir=$(dirname $0)
. ${sDir}/lib/function.sh

lToGroup=(`cat "$sDir/conf/groups"`)
lUser=(`cd "$sDir/user/" && ls`)

echo

for user in ${lUser[@]}
do
	echo " - start add ${user} -"
	addUser ${user}
	if [ $? -ne 0 ]; then
		exit 1
	fi

	for group in ${lToGroup[@]}
	do
		addUsertoGroup ${user} ${group}
		if [ $? -ne 0 ]; then
			exit 1
		fi
	done

	while read sPubKey
	do
		addPublicKey "$user" "$sPubKey"
		if [ $? -ne 0 ]; then
			exit 1
		fi
	done < "$sDir/user/$user"

	echo " - finished add -"
	echo
done
