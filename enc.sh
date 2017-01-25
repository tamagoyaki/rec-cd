#!/bin/bash
#


usage () {
    echo "USAGE"
    echo "  enc [-n] [format] [sample] [filename]"
    echo ""
    echo "    -n:       eliminate tracknumber from target filename"
    echo "    format:   encode format (mp3 only)"
    echo "    sample:   sampling rate (default 192)"
    echo "    filename: [audio_nn.inf, audio.cddb, or audio.cdindex]"
    echo ""
    echo "  - examples -"
    echo ""
    echo "     $ enc"
    echo "     $ enc mp3"
    echo "     $ enc mp3 192 audio_01.inf"
    echo "     $ enc -n mp3 192 audio.cdindex"
    exit 0
}

FMT="mp3"
SMP="192"
NON=false

for opt in "$@"
do
    case $opt in
	mp3)
	    FMT=$opt
	;;
	[0-9]*)
	    SMP=$opt
	;;
	audio_*.inf)
	    INF=$opt
	;;
	audio.cddb)
	    INF=$opt
	;;
	audio.cdindex)
	    INF=$opt
	;;
	-n)
	    NON=true
	;;
	*)
	    usage
    esac
done


if [ -z "$INF" ]; then
    NON=true
    SOURCES=`ls *.wav`
    TARGETS=`ls *.wav | sed 's/\.wav/\.mp3/g'`
elif [ "audio.cddb" = "$INF" ]; then
    SOURCES=`ls *.wav`
    TARGETS=`cat $INF | grep '^TTITLE' | sed 's/^[^=]*=\(.*\)/\1\.mp3/'`
elif [ "audio.cdindex" = "$INF" ]; then
    SOURCES=`ls *.wav`
    TARGETS=`cat $INF | grep '<Name>' | sed 's/<Name>\(.*\)<\/Name>/\1\.mp3/'`
else
    SOURCES=`echo $INF | sed 's/inf/wav/'`
    TARGETS=`cat $INF | grep 'Tracktitle' | sed 's/^.*=..\(.*\).$/\1\.mp3/'`
fi

# for debug
#echo $FMT, $SMP, $INF, $SOURCES, $TARGETS


# as array
IFS=$'\n'
targs=( $TARGETS )
ix=0

#
# $1 index for targs array
# $2 eliminate track number, if it's true
#
function trgname
{
    index=$1
    nonum=$2
    trg=`echo ${targs[$index]} | sed 's/^[[:blank:]]*//'`

    if [ true == $nonum ]; then
	echo $trg
    else
	echo `printf "%02d - %s" $((index + 1)) $trg`
    fi
}


# confirm
for src in $SOURCES; do
    trg=`trgname $ix $NON`
    echo -e $src "\t->\t" $trg
    ix=$((ix + 1))
done

echo "WITH: lame -b $SMP"

read -p "Are you sure? " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "aborted"
    exit -1
fi


# encoding
ix=0

for src in $SOURCES; do
    trg=`trgname $ix $NON`
    ix=$((ix + 1))

    if [ -e "$trg" ]; then
	echo "$trg is existed"
    else
	#echo lame -b $SMP $src $trg
	lame -b $SMP $src $trg
    fi
done
