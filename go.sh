#!/bin/bash
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
export PROG_NAME="test";
export PROG_VERSION="0.0.1";
export FLAG_DEBUG=1;

export FILES=" \
test.cpp \
lib.cpp \
";
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
export CFLAGS_x32DBG="-m32 -ggdb -O0   -std=c++0x -Wall -Wextra -Wlong-long -Wunused";
export CFLAGS_x32REL="-m32       -O777 -std=c++0x -Wall -Wextra -Wlong-long -Wunused";
export CFLAGS_x64DBG="-m64 -ggdb -O0   -std=c++0x -Wall -Wextra -Wlong-long -Wunused";
export CFLAGS_x64REL="-m64       -O777 -std=c++0x -Wall -Wextra -Wlong-long -Wunused";
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
export LFLAGS_x32DBG="-m32 -lpthread -ggdb";
export LFLAGS_x32REL="-m32 -lpthread -s";
export LFLAGS_x64DBG="-m64 -lpthread -ggdb";
export LFLAGS_x64REL="-m64 -lpthread -s";
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
stupid_make.sh "${@}";
exit "${?}";