#!/bin/bash
# G1034 Team 1 Project
# Mihalovici Tudor-Ioan Rusu Sergiu-Ioan Nistor Ștefana
# The script is a general purpose text editing and helping script, with commands like:
# 1 Find a word in a specified directory and the amount of times it appears
# 2 Replace a word in a file (also make them red)
# 3 Creating a quick script file with all the necessary setup (shebang/permissions/extension)
# 4 Changing the extensions of a file (or giving an extension to a file who doesn't have one)
# 5 All properties for a certain file or directory (read/write/executable/directory or character count, lines used, etc.)
# use -c argument when calling the script to clear screen on exit
while [[ "$REPLY" != 0 ]]; do
clear
echo "----------------------"
echo "Select an option:"
echo "----------------------"
echo "1. Find a word"
echo "2. Replace a word"
echo "3. Quick new script"
echo "4. Change extension"
echo "5. File properties"
echo "0. Exit"
echo "----------------------"
read -p "Input > " REPLY
if [[ "$REPLY" == *[0-5] ]]; then
	if [[ "$REPLY" == 1 ]]; then
		echo -e "----------------------\nDirectories in current directory:\n`ls -p | grep --color=always /`\n----------------------"
		read -rep $'Directory name: ' DIR
		#while dir exists and is a directory
		if [[ -e "$DIR" && -d "$DIR" ]]; then
			read -p "Word to search for: " WORD
			echo "----------------------"
			#number of instances of the word
			INS=`grep -rwo "$DIR" -e "$WORD" | wc -l`
			#if we have found at least 1 word, enter the grep
			if [[ "$INS" != 0 ]]; then
				#show the found words with color
				grep --color=always -rnw "$DIR" -e "$WORD"
				#show the amount of appearances
				echo -e "----------------------\nFound "$INS" instances of the word \""$WORD"\"";
			else
				echo "The word "$WORD" hasn't been found"
			fi
		else
			echo -e "----------------------\nThe directory "$DIR" either doesn't exist or it isn't a directory"
		fi
	fi
	if [[ "$REPLY" == 2 ]]; then
		#prepare the colors
		red=$'\e[31m'
		white=$'\e[0m'
		echo -e "----------------------\nFiles in current directory:\n`ls -p | grep --color=always -v /`\n----------------------"
		read -p "File name: " FILE
		#if the file exists
		if [[ -e "$FILE" ]]; then
			echo -e "----------------------\nContents of file "$FILE": "
			#show the contents of the file
			cat "$FILE"
			read -rep $'\n----------------------\nWord to search for: ' WORD
			#see if the file has the word
			INS=`grep -wo "$WORD" "$FILE" | wc -l`
			#if we can find a word enter the loop
			if [[ "$INS" != 0 ]]; then
				#show the amount of appearances
				echo -e "----------------------\nFound "$INS" instances of the word "$WORD":";
				#present all the found words
				grep --color=always -wno "$WORD" "$FILE" | nl 
				read -rep $'----------------------\nWhich one would you like to replace? (1, 2, ... , all): ' REPLY2
				#if we get a correct response
				if [[ "$REPLY2" == *[1-"$INS"] || "$REPLY2" == "all" ]]; then
					read -rep $'----------------------\nWord to replace it with: ' WORD2
					#if response is a number
					if [[ "$REPLY2" == *[1-"$INS"] ]]; then
						sed -zi "s/"$WORD"/"$red""$WORD2""$white"/"$REPLY2"" "$FILE"
					fi
					#if response is all
					if [[ "$REPLY2" == "all" ]]; then
						sed -i "s/"$WORD"/"$red""$WORD2""$white"/" "$FILE"
					fi
					echo -e "----------------------\nSuccessfully replaced, contents of file:\n`cat "$FILE"`"
				else
					echo -e "----------------------\nOutside of range"
				fi
			else
				echo "The word "$WORD" hasn't been found"
			fi
		else
			echo -e "----------------------\n"$FILE" does not exist"
		fi
	fi
	if [[ "$REPLY" == 3 ]]; then
		read -rep $'----------------------\nEnter the name for the new script: ' FILE
		#if the file already exists don't overwrite it
		if [[ -e "$FILE.sh" ]]; then
			echo -e "----------------------\nFile "$FILE".sh already exists"
		else
			#create file
			touch "${FILE}.sh"
			#give all perms for user and limited for group and other
			chmod 755 "${FILE}.sh"
			#add shebang to the beginning
			echo "#!/bin/bash" > "${FILE}.sh"
			echo -e "----------------------\nFile "${FILE}.sh" has been created"
		fi
	fi
	if [[ "$REPLY" == 4 ]]; then
		echo -e "----------------------\nFiles in current directory:\n`ls -p | grep --color=always -v /`\n----------------------"
		read -p "File name: " FILE
		#if the file exists
		if [[ -e "$FILE" ]]; then
			#if the file is a directory don't enter the loop
			if [[ -d "$FILE" ]]; then
				echo -e "----------------------\n"$FILE" is a directory"
			else
				#if the file has an extension replace it
				if [[ "$FILE" == *.* ]]; then
					echo "----------------------"
					read -p "File has extension `echo .${FILE##*.}`, change it to: " var1
					mv "$FILE" "${FILE%.*[a-z]}.$var1"
					echo -e "----------------------\nFile name has been successfully changed to ${FILE%.*[a-z]}.$var1"
				else
					#if the file doesn't have an extension add one
					read -rep $'----------------------\nThe file does not have an extension, make it: ' var1
					mv "$FILE" "${FILE}.$var1" 
					echo -e "----------------------\nFile name has been successfully changed to ${FILE%.*[a-z]}.$var1"
				fi
			fi
		else
			echo -e "----------------------\n"$FILE" does not exist"
		fi
	fi
	if [[ "$REPLY" == 5 ]]; then
		echo -e "----------------------\nFiles/Directories in current directory:\n`ls -p`\n----------------------"
		read -p "File/Directory name: " FILE
		#if the file exists
		if [[ -e "$FILE" ]]; then
			echo "----------------------"
			test -f "$FILE" && echo "[x] Regular file" || echo "[ ] Regular file" #if it's a file
			test -d "$FILE" && echo "[x] Directory" || echo "[ ] Directory" #if it's a directory
			test -r "$FILE" && echo "[x] Readable" || echo "[ ] Readable" #if it's readable
			test -w "$FILE" && echo "[x] Writable" || echo "[ ] Writable" #if it's writable
			test -x "$FILE" && echo "[x] Executable" || echo "[ ] Executable" #if it's executable
			#if the file given is a directory
			if [[ -d "$FILE" ]]; then
				echo -e "----------------------\nDirectory size: `du -sh "$FILE" | awk '{print $1}'`"
				echo "Files inside: `ls "$FILE" | wc -l`"
			#if the file given is a regular file
			else
				echo -e "----------------------\nFile type: `file -b "$FILE"`"
				read -rep $'----------------------\nWhat do you want to see? (1-file size, 2-line count, 3-word count): ' REPLY3
				while [[ "$REPLY3" == *[1-3] ]]; do
					if [[ "$REPLY3" == 1 ]]; then
						echo -e "----------------------\nFile size: `wc -c < "$FILE"`"
					fi
					if [[ "$REPLY3" == 2 ]]; then
						echo -e "----------------------\nLine count: `wc -l < "$FILE"`"
					fi
					if [[ "$REPLY3" == 3 ]]; then
						echo -e "----------------------\nWord count: `wc -w < "$FILE"`"
					fi
					read -rep $'----------------------\nWhat do you want to see? (1-file size, 2-line count, 3-word count, 0 - exit): ' REPLY3
				done
			fi
		else
			echo -e "----------------------\n"$FILE" does not exist"
		fi
	fi
	if [[ "$REPLY" == 0 ]]; then
		echo "----------------------"
		if [[ $1 == "-c" ]]; then
			clear
		fi
		exit 0
	else
		echo "----------------------"
		read -n 1 -s -r -p "Press any key to continue (or 0 to exit): "; echo -e "\n----------------------"
		if [[ "$REPLY" == 0 ]]; then
			#if flag -c is set when calling the script, clear the screen on exit
			if [[ "$1" == "-c" ]]; then
				clear
			fi
			exit 0
		fi
	fi
else
	#safety measure
	echo -e "----------------------\nInvalid input\n----------------------"; exit 1
fi
done