#include <stdio.h>
#include "lib.h"

void f()
{
	printf ("Hello world!\n");

	printf ("PROG_FULL_NAME : %s\n", PROG_FULL_NAME);
	printf ("PROG_NAME      : %s\n", PROG_NAME);
	printf ("PROG_VERSION   : %s\n", PROG_VERSION);
	printf ("PROG_TARGET    : %s\n", PROG_TARGET);
}
