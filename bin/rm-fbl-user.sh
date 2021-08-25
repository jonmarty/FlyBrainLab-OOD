#!/bin/bash

user_exists(){ id "$1" &>/dev/null; }

if [ "$(hostname)" != "login01" ]; then
	echo "rm-fbl-user needs to be executed from login01"
	exit 1
fi

if [ $# -ne 1 ]; then
	echo "Usage: rm-fbl-user RMUSER"
	exit 1
fi

RMUSER=$1

if [ id "$1" &>/dev/null ]; then
       echo "Found user ${RMUSER}, deleting"
else
       echo "user ${RMUSER} does not exist"
       exit 1
fi

# Environment variables
OODPASSWDFILE="/etc/apache2/.htpasswd"
OODUNIXGROUP="ood"
OODSLURMACCOUNT="${OODUNIXGROUP}"

echo [RM-FBL-USER] Removing unix user ${RMUSER} on login01
sudo gpasswd -d ${RMUSER} ${OODUNIXGROUP}
sudo userdel -r ${RMUSER}
echo [RM-FBL-USER] Removed unix user ${RMUSER} on login01

echo [RM-FBL-USER] Removing user ${RMUSER} from ssh
sudo sed -i "/AllowUsers ${RMUSER}/d" /etc/ssh/sshd_config
echo [RM-FBL-USER] Removed user ${RMUSER} from ssh

echo [RM-FBL-USER] Removing slurm user ${RMUSER} on login01
sudo sacctmgr delete user name=${RMUSER} account=${OODSLURMACCOUNT}
echo [RM-FBL-USER] Removed slurm user ${RMUSER} on login01

echo [RM-FBL-USER] Removing ${RMUSER} from Open OnDemand
sudo htpasswd -D ${OODPASSWDFILE} ${RMUSER}
echo [RM-FBL-USER] Removed ${RMUSER} from Open OnDemand

echo [RM-FBL-USER] Restarting Apache2 server
sudo service apache2 restart
echo [RM-FBL-USER] Restarted Apache2 server

ssh bionet@gpu01 << EOF
	
	echo [RM-FBL-USER] Removing unix user ${RMUSER} on gpu01
	sudo gpasswd -d ${RMUSER} ${OODUNIXGROUP}
	sudo userdel ${RMUSER}
	echo [RM-FBL-USER] Removed unix user ${RMUSER} on gpu01
	
	#echo [RM-FBL-USER] Removing user ${RMUSER} from ssh on gpu01
	#sudo sed -i "/AllowUsers ${RMUSER}/d" /etc/ssh/sshd_config	
	#echo [RM-FBL-USER] Removed user ${RMUSER} from ssh on gpu01
	
	echo [RM-FBL-USER] Removing /mnt/nvme/node04/${RMUSER}
	sudo rm -r /mnt/nvme/node04/${RMUSER}
	echo [RM-FBL-USER] Removed /mnt/nvme/node04/${RMUSER}
	
EOF
