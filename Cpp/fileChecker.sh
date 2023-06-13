#!/bin/sh

<<============================================================================
Name        : FileChecker.sh

Author      : Seyed Ali Firooz Abadi

Version     : 2.0

Description : This will go through each student's folder and check the number of files.
		Run me using $./fileChecker.sh |& tee ./fileChecker.log
		
Copyright © 2022 Ali Firooz. All rights reserved.
============================================================================

# TODO :
#	- Find a way to get the stderr back to screen. Or better yet, make no overwrites and keep the stderr as is
#	- if a folder __macox exists, we need to skip it

#############################################################

originalPath=$(pwd -P)

read -p "Enter the homework (like 02) number: " hwNUM
cd "hw$hwNUM"

# Defining Colores to be used
PURP='\e[0;35m'
B_PURP="\e[1;${PURP}"
GREEN='\e[0;32m'
BLUE='\e[0;34m'
B_BLUE="\e[1;${BLUE}"
RED='\e[0;31m'
YELLOW='\e[0;33m'
B_YELLOW="\e[1;${YELLOW}"
NC='\e[0m'

numOfDir=$(ls -QX1 | grep -i "_file_" | wc -l)

echo " "
echo 'Welcom to c++ HW '$hwNUM' file checker'
read -p "How many files should be in each folder? " filesNum
read -p "Do you want to unzip any files if exists (y/n)? " unzip

if [ "$unzip" = "y" ]; then
	read -p "Do you want to delete zip files after they have been unzipped (y/n)? " deletezip
	read -p "Should I check and move everything in one folder (y/n)? " move2src
else
	unzip="n"
	deletezip="n"
	read -p "Do you want to check and move everything in one folder (y/n)? " move2src
fi

echo " "

index=1

while [ true ]; do
	
	# Halting condition
	if [ $index -gt $numOfDir ]; then
		break
	fi
	
	# get the folder you want to test
	studentName=$(ls -X | head -n $index | tail -n 1)
	cd "$studentName"
	
	#echo ""
	echo "======================================================"
	#echo ""
	echo "${BLUE}$index - $studentName${NC}"
	
	# extracting zip files
	tar_file=false
	zip_file=false
	rar_file=false
	if [ "$unzip" = "y" ]; then
		#exec 2> /dev/null
		for file in ./*
		do
			# -o == --no-same-owner : to change the ownership to the current user
			# -p == --preserve-permissions
			# -x : extract
			# -f : name of the file
			# -z == --gzip, --ungzip : to specifically choose tar.gz files
			# -j == --bzip2 : to specifically choose tar.bz2 files
			
			$(tar -xopf "$file" --keep-newer-files --restrict && tar_file=true) || \
			$(unzip -nqq "$file" && zip_file=true) || \
			$(unrar e -o- -inul "$file" && rar_file=true)		
		done
		
		# deleting zip files
		if [ "$deletezip" = "y" ]; then
			$(rm -f *.tar*)
			$(rm -f *.zip)
			$(rm -f *.rar)
		fi
		#exec 2> "$originalPath/stderr"
	fi
	
	# removing sub-directories
	if [ "$move2src" = "y" ]; then
		tempPath=$(pwd -P)
		subFileNum=$(ls -QXd1 */ | wc -l) || subFileNum=-1
		tempIndex=1
		while [ true ] ; do
			# for some reason the while loop don't break
			if [ $tempIndex -gt $subFileNum ]; then
				break
			fi
			# Note that the output will be like: "folder/"
			tempFileName=$(ls -Xd */ | head -n $index | tail -n 1)
			cd "$tempPath/$tempFileName"
			mv --interactive ./* "$tempPath"
			cd "$tempPath"
			rm -rf "$tempPath/$tempFileName"
			tempIndex=$((tempIndex+1))
		done
	fi
	
	# number of files inside each folder
	filesNumTest=$(ls -X1 | wc -l)
	
	# printing
	if [ $filesNum -eq $filesNumTest ]; then
		echo "${GREEN}ALL GOOD${NC}"
	else
		#echo "${RED}NOT CORRECT \n $index - $studentName\t\t ==> $filesNumTest${NC}"
		echo "${RED}NOT CORRECT ==> $filesNumTest${NC}"
	fi

	index=$((index+1))
	cd ..
done

#echo ""
echo "======================================================"
echo ""

#echo "Errors:"
#cat "$originalPath/stderr"
#rm -f "$originalPath/stderr"

echo ""


