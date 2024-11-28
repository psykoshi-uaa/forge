#  _____________________________________________________________________
# |				 FORGE					|
# |_____________________________________________________________________|
# | Author: Calvin Michele (psykoshi)					|
# |									|
# | Info: This is a personal script I use in order to quickly setup	|
# | and compile multi-directory c++ projects based on my own 		|
# | preferences (and really just because I like making my own tools).	|
# |									|
# |									|
#___________VERSION__________ 						|
#			     |						|
        forge_ver=0.36	    #|			     created: 29AUG24	|
#____________________________|			     updated: 5SEP24	|
# |									|
# |_____________________________________________________________________|
#
#				   ***
#
#  _____________________________________________________________________
# |			GLOBAL VARIABLES				|
# |_____________________________________________________________________|
PRJ_NAME=$(echo ${PWD/*\//})
PRJ_EXE=$PRJ_NAME.exe

PRJ_PATH=$PWD/
BLD_PATH=${PRJ_PATH}build/
SRC_PATH=${PRJ_PATH}src/
INC_PATH=${PRJ_PATH}include/
UTL_PATH=${PRJ_PATH}.util/

LINKAGE_FILE=${UTL_PATH}linkage
LANGUAGE_FILE=${UTL_PATH}language
LANG_TYPE='c'
GGG='gcc'

if [[ -e "${LANGUAGE_FILE}" ]]; then
	LANG_TYPE=$(awk 'NR==1' $LANGUAGE_FILE)
	GGG=$(awk 'NR==2' $LANGUAGE_FILE)
fi

#  _____________________________________________________________________
# |			FUNCTION DEFINITIONS				|
# |_____________________________________________________________________|
function assert_dirs() {
	while [ $# -gt 0 ]; do
		if [[ ! -d $1 ]]; then
			return 1
		fi
	shift
	done
	return 0
}


function assert_files() {
	while [ $# -gt 0 ]; do
		if [[ ! -e $1 ]]; then
			return 1
		fi
	shift
	done
	return 0
}


function echo_dirs() {
	local missing_dirs
	while [ $# -gt 0 ]; do
		if [[ ! -d $1 ]]; then
			missing_dirs="$missing_dirs $1"
		fi
	shift
	done
	echo $missing_dirs
}


function echo_files() {
	local missing_files
	while [ $# -gt 0 ]; do
		if [[ ! -e $1 ]]; then
			missing_files="$missing_files $1"
		fi
	shift
	done
	echo $missing_files
}


function mkdir_missing(){
	while [ $# -gt 0 ]; do
		mkdir $1
	shift
	done
}


function fancify_created(){
	local verbose
	while [ $# -gt 0 ]; do
		verbose="${verbose}\ncreated\e[30;1m-\e[32;1m+\e[30;1m->\e[0m$1"
	shift
	done
	echo $verbose
}


function fancify_missing(){
	local verbose
	while [ $# -gt 0 ]; do
		verbose="${verbose}\nmissing\e[30;1m-\e[31;1mx\e[30;1m->\e[0m$1"
	shift
	done
	echo $verbose
}


function create_missing_dirs() {
	while [ $# -gt 0 ]; do
		mkdir $1
	shift
	done
}


function create_missing_files() {
	while [ $# -gt 0 ]; do
		touch $1
	shift
	done
}

function assert_project() {
	local error
	error=$(assert_dirs ${BLD_PATH} ${SRC_PATH} ${INC_PATH} ${UTL_PATH})
	error=$(assert_files ${PRJ_PATH}main.${LANG_TYPE} ${UTL_PATH}timestamps)
	return $error
}


function create_missing_content() {
	$(create_missing_dirs $(echo_dirs ${BLD_PATH} ${SRC_PATH} ${INC_PATH} ${UTL_PATH}))
	$(create_missing_files $(echo_files ${PRJ_PATH}main.${LANG_TYPE} ${UTL_PATH}timestamps))
}


function echo_missing_content() {
	local verbose
	if [[ $1 == "setup" ]]; then
		verbose="$(fancify_created $(echo_dirs ${BLD_PATH} ${SRC_PATH} ${INC_PATH} ${UTL_PATH}) )"
		verbose="$verbose$(fancify_created $(echo_files ${PRJ_PATH}main.${LANG_TYPE} ${UTL_PATH}timestamps) )"
		if [[ -z verbose ]]; then
			verbose="all necessary files and directories are present, no changes made."
		fi
	else
		verbose="$verbose$(fancify_missing $(echo_dirs ${BLD_PATH} ${SRC_PATH} ${INC_PATH} ${UTL_PATH}) )"
		verbose="$verbose$(fancify_missing $(echo_files ${PRJ_PATH}main.${LANG_TYPE} ${UTL_PATH}timestamps) )"
		if [[ verbose != "" ]]; then
			verbose="files or directories missing, type \e[30;1m[\e[033;1mforge --help\e[30;1m]\e[0m\n$verbose"
		fi
	fi
	echo $verbose
}


function help_menu() {
	local help_text=$(echo "Forge is a multi-directory c/c++ Make substitute written by Calvin Michele.\n
		\t-s --setup\t\t\t|\tSets up a directory for Forge. This will not overwrite any files or directories.\n
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


function set_lang() {
	if [[ $# -eq 0 ]]; then
		echo "No languages indicated, currently accepted languages are: [C] [C++]"
		exit 1
	else
		if [[ !(-e "$LANGUAGE_FILE") ]]; then
			touch $LANGUAGE_FILE
		fi

		case $1 in
		c|C)
			echo "c" > $LANGUAGE_FILE
			echo "gcc" >> $LANGUAGE_FILE
			;;
		cpp|CPP|c++|C++)
			echo "cpp" > $LANGUAGE_FILE
			echo "g++" >> $LANGUAGE_FILE
			;;
		esac
		echo "$1 set as project language. Your project will now compile with $1."
	fi
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
	echo FILE UPDATES > ${UTL_PATH}timestamps
	while [ $# -gt 0 ]; do
		echo $1: $(date -r $1) >> ${UTL_PATH}timestamps
		shift
	done
}


function update_obj_files() {
	local num_files=0
	local which_files="\n"

	cd ${BLD_PATH}
	while [ $# -gt 0 ]; do
		if [[ !($(cat ${UTL_PATH}timestamps) =~ $(echo $(date -r ${PRJ_PATH}$1)) ) ]] || [[ ! -e $(echo $1 | sed "s/\.${LANG_TYPE}/\.o/g" | sed 's/src\///g') ]]; then
			if (${GGG} -c ${PRJ_PATH}$1); then
				which_files="$which_files \e[33;1m*bang* \e[0m$1\n"
				num_files=$num_files+1
			else
				rm ${BUILD_PATH}$(echo $1 | sed "s/\.${LANG_TYPE}/\.o/g" | sed 's/src\///g')
			fi
		fi
		shift
	done
	cd ..
	if [[ num_files -gt 0 ]]; then
		echo $which_files
	fi
}


function version() {
	echo "Forge Version [\e[1;33m$forge_ver\e[0m]
	\ncompatibile languages:\t[c] [c++]
	\ncompatible libraries:\t[ncurses]"
}


function clean() {
	rm $PRJ_EXE
	rm ${BLD_PATH}*.o
}


function clean_all() {
	rm main.${LANG_TYPE}
	rm -r ${BLD_PATH}
	rm -r ${SRC_PATH}
	rm -r ${INC_PATH}
	rm -r ${UTL_PATH}
}


#  _____________________________________________________________________
# |			COMPILATION					|
# |_____________________________________________________________________|
if [[ $# -eq 0 ]]; then
	if ($(assert_project 0)); then
		SRC_FILES=$(find -iname "*.${LANG_TYPE}")
		echo -e $(update_obj_files $SRC_FILES)
		$(time_stamp $SRC_FILES)
		OBJ_FILES=$(find ${BLD_PATH}*.o)

		if [[ -e "${UTL_PATH}/linkage" ]]; then
			LINKAGE=$(cat $LINKAGE_FILE)
		else
			LINKAGE=""
		fi


		if (${GGG} -o $PRJ_EXE $OBJ_FILES $LINKAGE); then
			echo -e "\e[30;1m-- \e[32;1mforge succesful \e[30;1m --\e[0m\n"
		else
			echo -e "\n\e[30;1m-- \e[31;1mforge failed \e[30;1m --\e[0m\n"
		fi
		exit 0
	else
		echo -e $(echo_missing_content)
		echo -e "\n\e[30;1m-- \e[31;1mforge failed \e[30;1m --\e[0m\n"
		exit 1
	fi
fi


#  _____________________________________________________________________
# |			HANDLE FLAGS					|
# |_____________________________________________________________________|
while [ $# -gt 0 ]; do
	case $1 in
	-s | --setup)
		echo -e $(echo_missing_content "setup")
		$(create_missing_content)
		echo -e "\n\e[30;1m -- \e[33;1msetup finished \e[30;1m--\n"
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
		echo 'sweeping...'
		echo -e $(clean)
		;;
	-t | --type)
		echo -e $(set_lang $2)
		;;
	--clean-all)
		echo 'sweeping...'
		echo -e $(clean_all)
		;;
	esac
	shift
done
exit 0
