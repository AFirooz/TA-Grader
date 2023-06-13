#!/bin/sh

# $./grader.sh |& tee ./hw##/output.log

<<============================================================================
Name        : grade02.sh

Author      : Seyed Ali Firooz Abadi

Version     : 2.0

Description : This will go through each student's folder and run the .cpp script
		Uncomment code lines (commented using ### ) if you want to be able to go through the HW and choose a student each time
		If there is header files in different folders, change the path in line 78 (g++ ...)
		This program will check for memory leaks using Valgrind if it is installed
		
Copyright © 2022 Ali Firooz. All rights reserved.
============================================================================

# TODO :
#	- Make the file run as $./grader.sh |& tee ./hw#-240/output.log using if statement and echo the file https://www.conjur.org/blog/improving-logs-in-bash-scripts/
#		You can't put the code in a function and run it with tee, you need to find another way.
#	- Use `gdb` to further debug and give better comments



#############################################################

read -p "Enter the homework (like 02) number: " hwNUM
cd "hw$hwNUM"

#Checking if valgrind is installed
valInstalled=0
dpkg-query -Wf '${Status}' "valgrind" > vStatus.temp
grep -qiF "ok installed" vStatus.temp && valInstalled=1


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


# the option -Q will enclose entry names in double quotes (to solve the problem with them having a space)
# the option -X will sort alphabetically by entry extension
# the option -1 will list an entry per line
numOfDir=$(ls -QX1 | grep -i "_file_" | wc -l)

echo " "
echo 'Welcom to c++ grader of HW '$hwNUM
#echo 'you can enter a number between 0 to '$numOfDir

index=1

while [ true ]; do
	###read -p "Enter folder number:" index

	# check if the number is valid
	if [ $index -gt $numOfDir ]; then
		echo "the number entered is invalid"
		###continue
		break
	fi
	if [ $index -eq 0 ]; then
		echo "Goodbye"
		break
	fi
	
	# get the folder you want to test
	studentName=$(ls -X | head -n $index | tail -n 1)
	cd "$studentName"
	
	# These count variables are used in printing the content of .cpp and .h files
	cnum=$(ls -1 *.cpp | wc -l) || 0
	hnum=$(ls -1 *.h | wc -l) || 0
	num=$(($cnum+$hnum))
	
	
	echo " "
	echo "======================================================"
	echo " "
	
	echo "${B_YELLOW}$index - $studentName${NC}"
	
	echo " "
	echo "======================================================"
	echo " "
	
	# printing the content of the files (see line63 for num, cnum, and hnum)
	t=1
	th=1
	while [ $t -le $num ]; do
		if [ $t -le $cnum ]; then
			echo "${B_BLUE}$(ls -X *.cpp | head -n $t | tail -n 1)${NC}"
			echo " "
			cat --number $(ls -X *.cpp | head -n $t | tail -n 1)
		else
			echo "${B_BLUE}$(ls -X *.h | head -n $th | tail -n 1)${NC}"
			echo " "
			cat --number $(ls -X *.h | head -n $th | tail -n 1)
			th=$((th+1))
		fi
		
		t=$((t+1))
		
		echo " "
		echo "======================================================"
		echo " "
	done
		
	# compiling
	# the `-I` option is for specifying the headers location
	# the `-g` option is for debugging, to get more info form Valgrind
	fileCompiled=0
	g++ -g -I ./ ./*.cpp -o compiledFile 2> /dev/null && fileCompiled=1 && echo "${GREEN}Compiled Successfully${NC}" || echo "${RED}Compile Failed${NC}"
	# compile using NVIDIA C++ compiler
	#nvc++ -g -I ./ ./*.cpp -o compiledFile 2> /dev/null && fileCompiled=1 && echo "${GREEN}Compiled Successfully${NC}" || echo "${RED}Compile Failed${NC}"
	
	echo " "
	echo "======================================================"
	echo " "
	
	# Runing the program
	runMe="y"
	
	###echo "Should I run?"
	###read -p "Enter (y) for yes: " runMe
	
	if [ "$runMe" = "y" ]; then
		keepRunning="y"
		while [ "$keepRunning" = "y" ]; do
			# $(stat compiledFile | grep -q "No such file or directory")
			if [ $fileCompiled -ge 1 ]; then	# compiled file found
				
				if [ $valInstalled -ge 1 ] ; then	# valgrind is installed
					valgrind -q --leak-check=yes ./compiledFile
				else
					echo "You need to install valgrind to run it"
					echo ""
					./compiledFile
				fi
			else	# compiled file not found
				echo " "
				break
			fi
			
			# Asking the user if the app should run again
			# TODO: Find a better way to compare strings (I'm having problem with !=)
			read -p "Run again YES(y)/NO(n)? " keepRunning
			while [ true ]; do
				if [ "$keepRunning" = "y" ]; then
					break
				elif [ "$keepRunning" = "n" ]; then
					break
				else
					read -p "Run again YES(y)/NO(n)? " keepRunning
				fi
			done
			
			echo " "
			echo "======================================================"
			echo " "
		done
	fi
	
	#echo " "
	#echo "======================================================"
	#echo " "
	
	# giving credit
	cd ..	# Now we are inside the directory: hw##
	read -p "Enter a grade 0-100: " myGrade
	
	comment="N/A"
	read -p "Enter any comments, ${RED}DO NOT use commas!${NC}: " comment
	
	echo "$index,$studentName,$myGrade,$comment" >> record.csv
	echo " "
	echo "${B_PURP}xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx${NC}"
	echo " "
	index=$((index+1))
done

rm -f *.temp



