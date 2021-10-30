#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.3.4
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
GLOBAL_VERSION='0.3.4';
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# check depends
function check_prog()
{
	for i in ${1};
	do
		if [ "$(command -v ${i})" == "" ];
		then
			echo "FATAL: you must install \"${i}\"...";
			return 1;
		fi
	done

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# view current time
function get_time()
{
	if [ "$(command -v date)" != "" ];
	then
		echo "[$(date +'%Y-%m-%d %H:%M:%S')]: ";
	fi
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# do clean
function clean()
{
	echo "$(get_time)clean";
	rm -rf bin.old &> /dev/null;
	rm -rf bin &> /dev/null;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	if [ "${CC}" == "" ];
	then
		CC='gcc';
	fi

	if [ "${CXX}" == "" ];
	then
		CXX='g++';
	fi


# check depends tools
	check_prog "awk cat chmod cp echo file g++ grep head ln md5sum mkdir mktemp mv objdump readlink rm stat uname wc ${CC} ${CXX}";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	echo;
	echo;
	echo "$(get_time)stupid_make v${GLOBAL_VERSION}";

	COMMAND="${1}";


	if [ "${COMMAND}" == "clean" ];
	then
		clean;
		return 0;
	fi


	if [ "${COMMAND}" == "help" ] || [ "${COMMAND}" == "-help" ] || [ "${COMMAND}" == "--help" ] || [ "${COMMAND}" == "-h" ];
	then
#		echo "$(get_time)example: ${0} all | clean | x32 | x64";
		echo "$(get_time)example: go.sh all | clean | x32 | x64";
		return 1;
	fi


	if [ "${COMMAND}" == "all" ];
	then
		clean;
		COMMAND='';
	fi


	if [ "${COMMAND}" == "" ];
	then
		if [ "$(uname -m | grep 'x86_64' | wc -l | awk '{print $1}')" == "0" ];
		then
			echo "$(get_time)auto detect x32";
			COMMAND='x32';
		else
			echo "$(get_time)auto detect x64";
			COMMAND='x64';
		fi
	fi


	if [ "${COMMAND}" == "x32" ];
	then
		PROG_TARGET="x32";

		if [ "${FLAG_DEBUG}" == "0" ];
		then
			CFLAGS="${CFLAGS} ${CFLAGS_x32REL}";
			LFLAGS="${LFLAGS} ${LFLAGS_x32REL}";
		else
			CFLAGS="${CFLAGS} ${CFLAGS_x32DBG}";
			LFLAGS="${LFLAGS} ${LFLAGS_x32DBG}";
		fi
	fi


	if [ "${COMMAND}" == "x64" ];
	then
		PROG_TARGET="x64";

		if [ "${FLAG_DEBUG}" == "0" ];
		then
			CFLAGS="${CFLAGS} ${CFLAGS_x64REL}";
			LFLAGS="${LFLAGS} ${LFLAGS_x64REL}";
		else
			CFLAGS="${CFLAGS} ${CFLAGS_x64DBG}";
			LFLAGS="${LFLAGS} ${LFLAGS_x64DBG}";
		fi
	fi


	if [ "${FLAG_PARANOID}" == "1" ];
	then
		echo "$(get_time)CFLAGS: ${CFLAGS}";
		echo "$(get_time)LFLAGS: ${LFLAGS}";
	fi
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
	rm -rf bin.old &> /dev/null;
	mv bin bin.old &> /dev/null;
	mkdir bin;
	mkdir bin/obj;
	chmod 777 bin;


	if [ "${PROG_NAME}" == "" ];
	then
		echo;
		echo "ERROR: PROG_NAME variable not found...";
		return 1;
	fi

	if [ "${PROG_VERSION}" == "" ];
	then
		echo;
		echo "ERROR: PROG_VERSION variable not found...";
		return 1;
	fi



	PROG_FULL_NAME="${PROG_NAME}-${PROG_VERSION}-${PROG_TARGET}";

	echo "$(get_time)make ${PROG_FULL_NAME}"

	TMP1="$(mktemp)";
	if [ "${?}" != "0" ];
	then
		echo;
		echo "ERROR: can't make tmp file";
		return 1;
	fi

	TMP2="$(mktemp)";
	if [ "${?}" != "0" ];
	then
		echo;
		echo "ERROR: can't make tmp file";
		return 1;
	fi

	FLAG_SOURCE_NEW="0";


	if [ "${FILE_LIST}" != "" ];
	then
		FILES="${FILE_LIST}";
	fi


	for i in ${FILES};
	do
		rm -rf "${TMP1}" &> /dev/null;


		i2="${i}";
		if [ -L "${i}" ];
		then
			i2=$(readlink "${i}");
		fi


		T1="$(stat --printf '%Y' "${i2}" 2> /dev/null)";
		T2="$(stat --printf '%Y' bin.old/obj/"${i}".o 2> /dev/null)";

		if [ "${T2}" != "" ] && [ ${T1} -le ${T2} ];
		then

			if [ "${COMMAND}" == "x32" ];
			then
				if [ "$(file -b bin.old/obj/"${i}".o | grep 32-bit | wc -l | awk '{print $1}')" == "1" ];
				then
#					echo "$(get_time)+";
					cp bin.old/obj/"${i}".o bin/obj/;
					continue;
				fi
			fi



			if [ "${COMMAND}" == "x64" ];
			then
				if [ "$(file -b bin.old/obj/"${i}".o | grep 64-bit | wc -l | awk '{print $1}')" == "1" ];
				then
#					echo "$(get_time)+";
					cp bin.old/obj/"${i}".o bin/obj/;
					continue;
				fi
			fi
		fi

		echo "$(get_time)compile ${i}";
		FLAG_SOURCE_NEW="1";

		"${CXX}" "${i}" -c ${CFLAGS} \
		-D"PROG_FULL_NAME=\"${PROG_FULL_NAME}\"" \
		-D"PROG_NAME=\"${PROG_NAME}\"" \
		-D"PROG_VERSION=\"${PROG_VERSION}\"" \
		-D"PROG_TARGET=\"${PROG_TARGET}\"" \
		-o bin/obj/"${i}".o \
		&> "${TMP1}";

		if [ "${?}" != "0" ];
		then
			echo;
			echo;
			cat "${TMP1}" | grep -i error | head;
			rm -rf "${TMP1}"  &> /dev/null;
			rm -rf "${TMP2}" &> /dev/null;
			return 1;
		fi

		cat "${TMP1}" >> "${TMP2}";
	done

	rm -rf "${TMP1}" &> /dev/null;
	mv "${TMP2}" bin/warning;


	if [ "${FLAG_COMPILE_ONLY}" == "1" ];
	then
		echo "$(get_time)link is disable in your config";
		echo "$(get_time)Ok.";
		return 0;
	fi


#	echo "$(get_time)${FLAG_SOURCE_NEW}";


# если даже все уже скопилированно это не значит что все было слинковано
	if [ "${FLAG_SOURCE_NEW}" == "0" ];
	then
		if [ ! -e bin.old/${PROG_FULL_NAME} ] || [ ! -e bin.old/${PROG_NAME} ] || [ ! -e bin.old/${PROG_FULL_NAME}.dump ] || [ ! -e bin.old/${PROG_FULL_NAME}.md5 ];
		then
			FLAG_SOURCE_NEW="1";
		fi
	fi


	if [ "${FLAG_SOURCE_NEW}" == "1" ];
	then
		echo "$(get_time)link";
#		echo "$(get_time)FLAG_SOURCE_NEW == 1";
		g++ bin/obj/* -o bin/${PROG_FULL_NAME} ${LFLAGS};

		if [ "${?}" != "0" ];
		then
			rm -rf "${TMP1}"  &> /dev/null;
			rm -rf "${TMP2}" &> /dev/null;
			return 1;
		fi


		ln -sf ${PROG_FULL_NAME} bin/${PROG_NAME};


		if [ "${FLAG_DEBUG}" == "1" ];
		then
			echo "$(get_time)objdump";
			objdump -Dslx bin/${PROG_FULL_NAME} > bin/${PROG_FULL_NAME}.dump;
		fi


		cd bin;
		md5sum ${PROG_FULL_NAME} > ${PROG_FULL_NAME}.md5;
		cd ..;


		if [ -e bin/${PROG_FULL_NAME} ];
		then
			if [ -e bin.old/${PROG_FULL_NAME} ];
			then
				MD5_NEW="$(md5sum bin/${PROG_FULL_NAME}.md5 | awk '{print $1}')";
				MD5_OLD="$(md5sum bin.old/${PROG_FULL_NAME}.md5 | awk '{print $1}')";

				if [ "${MD5_NEW}" == "${MD5_OLD}" ];
				then
					echo "$(get_time)bin/${PROG_FULL_NAME} == bin.old/${PROG_FULL_NAME}";
				else
					echo "$(get_time)bin/${PROG_FULL_NAME} != bin.old/${PROG_FULL_NAME}";
				fi
			fi
		fi

	else

		ln bin.old/${PROG_FULL_NAME}      bin/;
		ln bin.old/${PROG_NAME}           bin/;
		ln bin.old/${PROG_FULL_NAME}.dump bin/;
		ln bin.old/${PROG_FULL_NAME}.md5  bin/;

		echo "$(get_time)bin/${PROG_FULL_NAME} == bin.old/${PROG_FULL_NAME}";
	fi


#	rm -rf bin/*.o &> /dev/null;

	echo "$(get_time)Ok.";
	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
