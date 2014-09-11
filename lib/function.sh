#!/bin/bash

function checkSystem() {
	case $1 in
			'ubuntu')
			;;
			*)
				echo 'ERROR : System version is error' 1>&2
				exit 1
			;;
	esac
	exit 0
}
function checkGroup() {
	cat /etc/group | grep -q "$1:x:"
	if [ $? -ne 0 ]; then
		rs=`groupadd $1`
		if [ $? -ne 0 ]; then
			echo "ERROR : $rs" 1>&2
			return $?
		fi
		echo "add group $1 success" 1>&2
	fi
	return 0
}

function addUser() {
	rs=`id $1 2>&1`
	if [ $? -ne 0 ]; then
		rs=`useradd $1`
		if [ $? -ne 0 ]; then
			echo "ERROR : $rs" 1>&2
			return $?
		fi
		echo "add user $1 success" 1>&2
	else
		echo "user $1 exist" 1>&2
	fi
	return 0
}

function addUsertoGroup() {
	$(checkGroup $2)
	if [ $? -ne 0 ]; then
		return $?
	fi
	id $1 | grep -q "($2)"
	if [ $? -ne 0 ]; then
			rs=`usermod -a -G $2 $1 2>&1`
		if [ $? -ne 0 ]; then
			echo "ERROR : $rs" 1>&2
			return $?
		else
			echo "add $1 to $2 group success" 1>&2
		fi
	else
		echo "user $1 already in $2 group" 1>&2
	fi
	return 0
}

function addPublicKey() {
	homePath="/home/$1/"
	basePath="${homePath}.ssh/"
	filePath="${basePath}authorized_keys"
	if [ ! -d ${homePath} ]; then
		mkdir ${homePath}
		chown -R $1:$1 ${homePath}
	fi
	if [ ! -d ${basePath} ]; then
		sudo -u $1 mkdir ${basePath}
	fi
	if [ ! -f ${filePath} ]; then
		sudo -u $1 touch ${filePath}
	fi
	sudo -u $1 cat ${filePath} | grep -q "$2"
	if [ $? -ne 0 ]; then
		rs=`sudo -u $1 echo "$2" >> ${filePath}`
		if [ $? -ne 0 ]; then
			echo "ERROR : $rs" 1>&2
		else
			echo "insert pulic key to authorized_keys success" 1>&2
		fi
	else
		echo "pulic key already in authorized_keys" 1>&2
	fi
	sudo -u $1 chmod 600 ${filePath}
}