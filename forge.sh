#!/bin/bash
#  _____________________________________________________________________
# |				 FORGE					|
# |_____________________________________________________________________|
# | Author: Calvin Michele (psykoshi)					|
# |									|
# | Info: This is a personal script I use in order to quickly setup	|
# | and compile multi-directory c++ projects based on my own 		|
# | preferences (and really just because I like making my own tools).	|
# |									|
#_|_____VERSION__________ 						|
#			 |						|
	forge_ver=0.25	#|						|
#________________________|			created: 	29AUG24	|
# |_____________________________________________________________________|

#				   ***

#  _____________________________________________________________________
# |			GLOBAL VARIABLES				|
# |_____________________________________________________________________|
PRJ_NAME=$(echo ${PWD/*\//})
PRJ_EXE=$PRJ_NAME.exe

PRJ_PATH=$PWD/
BLD_PATH=${PRJ_PATH}build/
SRC_PATH=${PRJ_PATH}src/
INC_PATH=${PRJ_PATH}include/


LINKAGE_FILE=${BLD_PATH}linkage
#  _____________________________________________________________________
# |			FUNCTION DEFINITIONS				|
# |_____________________________________________________________________|
function setup_prj_dir() {
	local verbose=""
	local fancy="created\e[32;1m+\e[30;1m-->\e[0m"
	if [[ ! -d "${BLD_PATH}" ]]; then
		mkdir ./build
		verbose="$verbose$fancy$BLD_PATH\n"
	fi
	if [[ ! -d "${SRC_PATH}" ]]; then
		mkdir ./src
		verbose="$verbose$fancy$SRC_PATH\n"
	fi
	if [[ ! -d "${INC_PATH}" ]]; then
		mkdir ./include
		verbose="$verbose$fancy$INC_PATH\n"
	fi
	if [[ ! -e "main.cpp" ]]; then
		touch main.cpp
		echo '#include' \"${INC_PATH}${PRJ_NAME}.h\" > main.cpp
		verbose="$verbose$fancy${PRJ_PATH}main.cpp\n"
	fi
	if [[ ! -e "${BLD_PATH}timestamps" ]]; then
		touch ${BLD_PATH}timestamps
		verbose="$verbose$fancy${BLD_PATH}timestamps\n"
	fi
	if [[ ! -e "${SRC_PATH}$PRJ_NAME.cpp" ]]; then
		touch ${SRC_PATH}$PRJ_NAME.cpp
		echo '#include' \"${INC_PATH}${PRJ_NAME}.h\" > ${SRC_PATH}$PRJ_NAME.cpp
		verbose="$verbose$fancy$SRC_PATH${PRJ_NAME}.cpp\n"
	fi
	if [[ ! -e "${INC_PATH}$PRJ_NAME.h" ]]; then
		touch ${INC_PATH}$PRJ_NAME.h
		verbose="$verbose$fancy${INC_PATH}${PRJ_NAME}.h\n"
	fi
	if [[ $verbose = "" ]]; then
		verbose="No directories or files are missing. No changes made."
	else
		verbose="${verbose}\n\e[30;1m-- \e[32;1mset up complete\e[30;1m--\e[0m\n"
	fi
	echo $verbose
}


function assert_project_files() {
	local verbose=""
	local fancy="missing\e[30;1m-\e[31;1mx\e[30;1m->\e[0m"


	if [[ !(-d "${BLD_PATH}") ]]; then
		verbose="${verbose}${fancy}$BLD_PATH\n"
		verbose="${verbose}$fancy${BLD_PATH}timestamps\n"
	else
		if [[ !(-e "${BLD_PATH}timestamps") ]]; then
			verbose="${verbose}$fancy${BLD_PATH}timestamps\n"
		fi
	fi

	if [[ !(-d "${SRC_PATH}") ]]; then
		verbose="${verbose}$fancy$SRC_PATH\n"
		verbose="${verbose}$fancy$SRC_PATH${PRJ_NAME}.cpp\n"
	else
		if [[ !(-e "${SRC_PATH}$PRJ_NAME.cpp") ]]; then
			verbose="${verbose}$fancy$SRC_PATH${PRJ_NAME}.cpp\n"
		fi
	fi

	if [[ !(-d "${INC_PATH}") ]]; then
		verbose="${verbose}$fancy$INC_PATH\n"
		verbose="${verbose}$fancy${INC_PATH}${PRJ_NAME}.h\n"
	else
		if [[ !(-e "${INC_PATH}$PRJ_NAME.h") ]]; then
			verbose="${verbose}$fancy${INC_PATH}${PRJ_NAME}.h\n"
		fi
	fi

	if [[ !(-e "main.cpp") ]]; then
		verbose="${verbose}$fancy${PRJ_PATH}main.cpp\n"
	fi


	if [[ $verbose != "" ]]; then
		verbose="${verbose}files or directories missing. Please run \e[30;1m[\e[33;1mforge -s\e[0m\e[30;1m]\e[0m to create the missing files."
		if [[ $1 -eq 1 ]]; then
			echo $verbose
		fi
		exit 1
	fi
	exit 0
}


function assert_exe() {
	local verbose=""
	if [[ -e "${PRJ_NAME}.exe" ]]; then
		echo "updated\e[30;1m--->\e[32;1m${PRJ_NAME}.exe\e[0m"
	else
		echo "created\e[30;1m--->\e[32;1m${PRJ_NAME}.exe\e[0m"
	fi
	if [[ $verbose != "" ]]; then
		echo $verbose
		exit 0
	fi
	exit 1
}


function help_menu() {
	local help_text=$(echo "Forge is a multi-directory c++ Make substitute written by Calvin Michele.\n
		\t-s --setup\t\t\t|\tSets up a directory for Forge.\n
		\t-l --linkage [library-name]\t|\tCreates a linkage file and writes needed linkage commands to the file.\n
		\t-h --help\t\t\t|\tShow this menu.\n
		\t-v --version\t\t\t|\tDisplay Forge Version [$forge_ver].\n
		\t-c --clean\t\t\t|\tremoves the .o and .exe files.\n
		\t--clean-all\t\t\t|\tremoves all directories and files created by forge.
\n\t\t\t\t\t\t\tUSE WITH CAUTION, THIS WILL WIPE THE DIRECTORIES BY NAME RECURSIVELY.
\n\nBe sure to run \e[30;1m[\e[0mforge --setup\e[30;1m]\e[0m before attempting to compile the program for the first time.
\nCompilation can be done without any flags, e.g. \e[30;1m[\e[0mforge\e[30;1m]\e[0m\n
		")
	echo  $help_text
}


function handle_linkage() {
	if [[ $# -eq 0 ]]; then
		echo "No libraries indicated, currently accepted libraries are: [ncurses]"
		exit 1
	else
		if [[ !(-e "$LINKAGE_FILE") ]]; then
			touch $LINKAGE_FILE
		fi
		
		case $1 in
		ncurses)
			echo "-lncurses" > $LINKAGE_FILE
			;;
		esac
		echo "$1 link created. Your project will now compile with $1."
	fi
}


function time_stamp() {
	echo FILE UPDATES > ${BLD_PATH}timestamps
	while [ $# -gt 0 ]; do
		echo $1: $(date -r $1) >> ${BLD_PATH}timestamps
		shift
	done
}


function update_obj_files() {
	local $which_files
	cd ${BLD_PATH}
	while [ $# -gt 0 ]; do
		if [[ !($(cat ${BLD_PATH}timestamps) =~ $(echo $(date -r ${PRJ_PATH}$1)) ) ]] || [[ ! -e $(echo $1 | sed 's/cpp/o/g' | sed 's/src\///g') ]]; then
			g++ -c ${PRJ_PATH}$1
			which_files="$which_files $1"
		fi
		shift
	done
	cd ..
	echo $which_files
}


function version() {
	echo "Forge Version $forge_ver
	\ncompatibile languages:\t[c++]
	\ncompatible libraries:\t[ncurses]"
}


function clean() {
	rm $PRJ_EXE
	rm ${BLD_PATH}*.o
}


function clean_all() {
	rm $PRJ_EXE
	rm main.cpp
	rm -r ${BLD_PATH}
	rm -r ${SRC_PATH}
	rm -r ${INC_PATH}
}
#  _____________________________________________________________________
# |			COMPILATION					|
# |_____________________________________________________________________|
if [[ $# -eq 0 ]]; then
	if ($(assert_project_files 0) ); then
		SRC_FILES=$(find -iname '*.cpp')
		echo $(update_obj_files $SRC_FILES)
		$(time_stamp $SRC_FILES)
		OBJ_FILES=$(find ${BLD_PATH}*.o)


		if [[ -e "${BLD_PATH}/linkage" ]]; then
			LINKAGE=$(cat $LINKAGE_FILE)
		else
			LINKAGE=""
		fi


		if (g++ -o $PRJ_EXE $OBJ_FILES $LINKAGE); then
			echo -e "\n\e[30;1m-- \e[32;1mforge succesful \e[30;1m --\e[0m\n"
		else
			echo -e "\n\e[30;1m-- \e[31;1mforge failed \e[30;1m --\e[0m\n"
		fi
		exit 0
	else
		echo -e $(assert_project_files 1)
		echo -e "\n\e[30;1m-- \e[31;1mforge failed \e[30;1m --\e[0m\n"
		exit 1
	fi
fi
#  _____________________________________________________________________
# |			HANDLE FLAGS					|
# |_____________________________________________________________________|
while [ $# -gt 0 ]; do
	case $1 in
	-s | --setup-dir)
		echo -e $(setup_prj_dir)
		;;
	-l | --link) 
		if [[ $# -eq 0 ]]; then 
			exit 1
		else
			echo -e $(handle_linkage $2)
		fi
		;;
	-h | --help)
		echo -e $(help_menu)
		;;
	-v | --version)
		echo -e $(version)
		;;
	-c | --clean)
		$(clean)
		;;
	--clean-all)
		echo -e $(clean_all)
	esac
	shift
done
exit 0
