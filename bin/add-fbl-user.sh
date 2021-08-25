#!/bin/bash

user_exists(){ id "$1" &>/dev/null; }
next_uid(){ awk -F: '{uid[$3]=1}END{for(x=2000; x<=9000; x++) {if(uid[x] != ""){}else{print x; exit;}}}' /etc/passwd; }

if [ "$(hostname)" != "login01" ]; then
	echo "add-fbl-user needs to be executed from login01"
	exit 1
fi

if [ $# -lt 2 ]; then
	echo "Usage: add-fbl-user NEWUSER NEWPASS [NEWUID]"
	exit 1
fi

if [ $# -lt 3 ]; then
        if [ id "$1" &>/dev/null ]; then
	    NEWUID=$(id -u $1)
	else
	    NEWUID=$(next_uid)
	fi
else
	if [ id "$1" &>/dev/null]; then
		NEWUID=$(id -u $1)
	else
		NEWUID=$3
	fi
fi

NEWUSER=$1
NEWPASS=$2

# Environment variables
OODPASSWDFILE="/etc/apache2/.htpasswd"
OODUNIXGROUP="ood"
OODSLURMACCOUNT="${OODUNIXGROUP}"

RETURNVALUE='$?'

echo [ADD-FBL-USER] Adding unix user on login01
echo ${NEWUID}
sudo useradd -m -u ${NEWUID} -p `mkpasswd ${NEWPASS}` -s /bin/bash -d /home/${NEWUSER} ${NEWUSER}
sudo usermod -aG ${OODUNIXGROUP} ${NEWUSER}
echo [ADD-FBL-USER] Added unix user on login01

echo [ADD-FBL-USER] Setting permissions for /home/${NEWUSER}
sudo chmod go-rwx /home/${NEWUSER}
echo [ADD-FBL-USER] Set permissions for /home/${NEWUSER}

echo [ADD-FBL-USER] Configuring ssh to allow ${NEWUSER}
sudo grep -F "AllowUsers ${NEWUSER}" /etc/ssh/sshd_config
if [ $? ]; then
	echo SSH already configured to allow ${NEWUSER}, skipping...
else
        echo "AllowUsers ${NEWUSER}" | sudo tee -a /etc/ssh/sshd_config
        sudo systemctl restart ssh
	sudo systemctl restart sshd
fi
echo [ADD-FBL-USER] Configured ssh to allow ${NEWUSER}

echo [ADD-FBL-USER] Adding slurm user on login1
sudo sacctmgr add user ${NEWUSER} account=${OODSLURMACCOUNT}
echo [ADD-FBL-USER] Added slurm user on login1

echo [ADD-FBL-USER] Adding ${NEWUSER} to Open OnDemand
sudo htpasswd -b ${OODPASSWDFILE} ${NEWUSER} ${NEWPASS}
echo [ADD-FBL-USER] Added ${NEWUSER} to Open OnDemand

echo [ADD-FBL-USER] Restarting Apache2 server
sudo service apache2 restart
echo [ADD-FBL-USER] Restarted Apache2 server

ssh bionet@gpu01 << EOF
	
	echo [ADD-FBL-USER] Adding unix user on gpu01
	echo ${NEWUID}
	sudo useradd -u ${NEWUID} -p `mkpasswd ${NEWPASS}` -s /bin/bash -d /home/${NEWUSER} ${NEWUSER}
	sudo usermod -aG ${OODUNIXGROUP} ${NEWUSER}
	echo [ADD-FBL-USER] Added unix user on gpu01
	
	#echo [ADD-FBL-USER] Configuring ssh to allow ${NEWUSER} on gpu01
	#sudo grep -F "AllowUsers ${NEWUSER}" /etc/ssh/sshd_config
	#if [ $RETURNVALUE ]; then
        # 	echo SSH already configured to allow ${NEWUSER} on gpu01, skipping...
	#else
        #	echo "AllowUsers ${NEWUSER}" | sudo tee -a /etc/ssh/sshd_config
	#fi
	#echo [ADD-FBL-USER] Configured ssh to allow ${NEWUSER} on gpu01

	
	echo [ADD-FBL-USER] Adding user directory under /mnt/nvme/node04 on gpu01
	sudo mkdir /mnt/nvme/node04/${NEWUSER}
	echo [ADD-FBL-USER] Added user directory under /mnt/nvme/node04 on gpu01
	
	echo [ADD-FBL-USER] Setting permissions for /mnt/nvme/node04/${NEWUSER} on gpu01
	sudo chown -R ${NEWUSER}:${NEWUSER} /mnt/nvme/node04/${NEWUSER}
	sudo chmod go-rwx /mnt/nvme/node04/${NEWUSER}
	echo [ADD-FBL-USER] Set permissions for /mnt/nvme/node04/${NEWUSER} on gpu01
	
	echo [ADD-FBL-USER] Copying fruitflybrain+fbl+latest sandbox directory to /mnt/nvme/node04/${NEWUSER}
	sudo cp -r /mnt/nvme/node04/bionet/fruitflybrain+fbl+latest /mnt/nvme/node04/${NEWUSER}/fruitflybrain+fbl+latest
	echo [ADD-FBL-USER] Copied fruitflybrain+fbl+latest sandbox directory to /mnt/nvme/node04/${NEWUSER}
	
	# Each user has exclusive write access to their image, having multiple users writing to the same image would 
	echo [ADD-FBL-USER] Giving ${NEWUSER} ownership of /mnt/nvme/node04/${NEWUSER}/fruitflybrain+fbl+latest
	sudo chown -R ${NEWUSER}:${NEWUSER} /mnt/nvme/node04/${NEWUSER}/fruitflybrain+fbl+latest
	sudo chmod go-rwx /mnt/nvme/node04/${NEWUSER}/fruitflybrain+fbl+latest
	echo [ADD-FBL-USER] Gave ${NEWUSER} ownership of /mnt/nvme/node04/${NEWUSER}/fruitflybrain+fbl+latest

EOF
