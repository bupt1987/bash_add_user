#!/bin/bash

apt-get update
apt-get install -y vim git wget

cd ~

git clone https://github.com/bupt1987/bash_add_user.git

cd bash_add_user

~/bash_add_user/add_user.sh
