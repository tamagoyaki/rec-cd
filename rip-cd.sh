#!/bin/bash
#


RIPPER=cdda2wav
RIPPEROPT="-D /dev/cdrom cddb=0"

if [ "infoonly" = "$1" ]; then
    RIPPEROPT=`echo $RIPPEROPT " -J -v titles"`
elif [ "alltracks" = "$1" ]; then
    RIPPEROPT=`echo $RIPPEROPT " -alltracks"`
else
    echo "USAGE"
    echo "  rip [infoonly|alltracks]"
    exit 0
fi

$RIPPER $RIPPEROPT
