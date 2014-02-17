#!/bin/bash

zenity --question --title="Backup" --text="Do you want to start automatic backup?"
BACKUP=$?
PERSONAL_MOUNT_POINT="$HOME/mount_points/Personal"
VA_MOUNT_POINT="$HOME/mount_points/VA"
ENCRYPT_BACKUP="TRUE"
PASSWORD_HASH_CODE="7de66dc1e1977a75ce7a9c28637b5622"

if [ $BACKUP == "0" ]
then
	echo "Automatic backup starting"
	
	if [ -e /media/Backup/.isPBDrive ]
	then
		# Mounting Personal folder
		PASSWORD=$(zenity --password --title="Enter Decryption Password")
		ENTERED_HASH_CODE=$(echo "$PASSWORD" | md5sum)
		while [ ${#PASSWORD} -gt 0 ] && [ $ENCRYPT_BACKUP == "TRUE" ]
		do
			echo "$ENTERED_HASH_CODE"
			echo "$PASSWORD_HASH_CODE"
			if [ "${ENTERED_HASH_CODE:0:32}" == "$PASSWORD_HASH_CODE" ]
			then
				echo "Mounting truecrypt volumes"
				
				mountpoint -q "$PERSONAL_MOUNT_POINT"
				if [ $? == "1" ]
				then
					truecrypt -p "$PASSWORD" /media/Backup/Personal $PERSONAL_MOUNT_POINT
				fi
				mountpoint -q "$VA_MOUNT_POINT"
				if [ $? == "1" ]
				then
					truecrypt -p "$PASSWORD" /media/Backup/VA $VA_MOUNT_POINT
				fi
				PERSONAL_MOUNT_POINT_STATUS=$?
				if [ $PERSONAL_MOUNT_POINT_STATUS == "0" ]
				then
					echo "Documents and pictures backup started"
					rsync -qarh --progress /home/tarun/Documents /media/Backup
					rsync -qarh --progress /home/tarun/Pictures /media/Backup
					ENCRYPT_BACKUP="FALSE"
				else
					echo "Some error occured in truecrypt mounting"
				fi
			else
				PASSWORD=$(zenity --password --title="Enter Decryption Password")
				echo $PASSWORD
				ENTERED_HASH_CODE=$(echo "$PASSWORD" | md5sum)
			fi
		done
		
		if [ $ENCRYPT_BACKUP == "TRUE" ] && [ ${#PASSWORD} -eq 0 ]
		then
			echo "User didn't enter the password"
			echo "Ignoring backup of Personal files"
		fi
		
		#rsync -qarh --progress /home/tarun/E-Books /media/Backup
		#rsync -qarh --progress --delete /home/tarun/Music /media/Backup
		#rsync -qarh --progress /home/tarun/Softwares /media/Backup
		#rsync -qarh --progress --delete /home/tarun/Wallpaper /media/Backup
	else
		echo "HDD absent OR WRONG Drive"
		echo "Encrypted backup credentials are not supplied"
	fi
	echo "Automatic backup Finished"
else
	echo "User denied automatic backup"
fi
