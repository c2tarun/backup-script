#!/bin/bash

zenity --question --title="Backup" --text="Do you want to start automatic backup?"
BACKUP=$?
PERSONAL_MOUNT_POINT="$HOME/mount_points/Personal"
VA_MOUNT_POINT="$HOME/mount_points/VA"
PASSWORD=$(zenity --password --title="Enter Decryption Password" --text="Please enter password for decryption")

if [ $BACKUP == "0" ]
then
	echo "Automatic backup starting"
	
	if [ -e /media/Backup/.isPBDrive ]
	then
		# Mounting Personal folder
		truecrypt -p "$PASSWORD" /media/Backup/Personal $PERSONAL_MOUNT_POINT
		PERSONAL_MOUNT_POINT_STATUS=$?
		if [ $PERSONAL_MOUNT_POINT_STATUS == "0" ]
		then
			echo "Documents and pictures backup started"
			rsync -qarh --progress --dry-run /home/tarun/Documents /media/Backup
			rsync -qarh --progress --dry-run /home/tarun/Pictures /media/Backup
		else
			echo "Encrypted backup credentials are not supplied"
		fi
		
		
		rsync -qarh --progress --dry-run /home/tarun/E-Books /media/Backup
		rsync -qarh --progress --dry-run --delete /home/tarun/Music /media/Backup
		rsync -qarh --progress --dry-run /home/tarun/Softwares /media/Backup
		rsync -qarh --progress --dry-run --delete /home/tarun/Wallpaper /media/Backup
		echo "Automatic backup Finished"
	else
		echo "Wrong drive"
	fi
	
else
	echo "User denied automatic backup"
fi
