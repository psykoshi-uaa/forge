# FORGE
This is a tool born as a creative outlet rather than one born from necessity.

### Uses
[forge --setup] searches a directory for all forge related directories and files, and if absent then it will create them. This command does not overwrite any existing files.
Files created:
	- main.cpp
	- ./src/PRJ_NAME.cpp
	- ./include/PRJ_NAME.h
Directories created:
	- ./build/
	- ./include/
	- ./src/

When you have setup the project directory with forge and have ensured that the files are compilable as C++ simply type [forge] and Forge will do the rest.
Steps take by Forge:
	1. Update the object files of each source file with changes
	2. Update the timestamps of the source code files into ./build/timestamps
	3. Check for a linkage file to append to the compilation
	4. Compile the object code with g++ into an executable

### Linkage
If you would like to link a library just type [forge -l {name_of_lib}] and a linkage file will be created with the necessary commands added. These commands will be added and appended to the project compilation.
Currently supported libraries:
	ncurses

#### Misc
Forge currently takes the project directory name and automatically uses that as the project name.

#### Roadmap
1. Add a linkage file that forge reads from for all things linkage related to allow custom libraries to be added by users.
2. Rewrite the setup and asser_prj_files functions as they are virtually the same, (merge?).
3. Add more compatible languages and OS's
4. Add more compatible default libraries.
5. More user customization, (config?). 
