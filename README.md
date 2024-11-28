# FORGE
This is a tool born as a creative outlet rather than one born from necessity.

### Uses
[forge --setup] searches a directory for all forge related directories and files
and if any are absent, it will create them. This command does not overwrite any existing files.

Files created:
- main.cpp
- ./.util/timestamps

Directories created:
- ./build/
- ./include/
- ./src/
- ./.util/

When you have setup the project directory with forge and have ensured that the files
are compilable as your set language simply type [forge] and Forge will do the rest.
Steps take by Forge:
1. Update the timestamps of the source code files into ./build/timestamps
2. Update the object files of any source file with changes
3. Check for a linkage file to append to the compilation
4. Check for a Language file to compile as the set language
5. Compile the object code with gcc or g++ into an executable and append the linked library

### Language
By default Forge executes gcc and searches for [C] main and src/ files.
If you would like Forge to instead execute g++ and search for [C++] files then simply type [forge -L cpp].
To undo this change type [forge -L c] or delete the .util/language file.

#### Misc
Forge currently takes the project directory name and automatically uses that as the project name.

### Linkage
If you would like to link a library just type [forge -l {name_of_lib}] and a linkage
file will be created with the necessary commands added. These commands will be added
and appended to the project compilation. If you would like to add your own library
search for the handle_linakge function in the forge.sh file and add a new case similar
to the other libraries.

Currently supported libraries:
	ncurses
	raylib
