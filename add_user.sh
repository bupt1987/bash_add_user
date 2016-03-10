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

	sSudoerFile=/etc/sudoers.d/${user}

	cat /etc/sudoers | grep -q "${user} ALL=(ALL) NOPASSWD: ALL"

	if [ $? -ne 0 ]; then
		echo "add ${user} into /etc/sudoers"
		chmod 640 /etc/sudoers
		echo "${user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
		chmod 440 /etc/sudoers
	fi

	while read sPubKey
	do
		addPublicKey "$user" "$sPubKey"
		if [ $? -ne 0 ]; then
			exit 1
		fi
	done < "$sDir/user/$user"

	echo " - finished add ${user} -"
	echo
done
