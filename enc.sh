#!/bin/bash
#


usage () {
    echo "USAGE"
    echo "  enc [format] [sample] [filename]"
    echo ""
    echo "    format:   encode format (mp3 only)"
    echo "    sample:   sampling rate (default 192)"
    echo "    filename: [audio_nn.inf, audio.cddb, or audio.cdindex]"
    echo ""
    echo "  - examples -"
    echo ""
    echo "     $ enc"
    echo "     $ enc mp3"
    echo "     $ enc mp3 192 audio_01.inf"
    exit 0
}

FMT="mp3"
SMP="192"

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
	*)
	    usage
    esac
done


if [ -z "$INF" ]; then
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


# confirm
for src in $SOURCES; do
    echo -e $src "\t->\t" ${targs[$ix]}
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
    trg=${targs[$ix]}
    ix=$((ix + 1))

    if [ -e "$trg" ]; then
	echo "$trg is existed"
    else
	#echo lame -b $SMP $src $trg
	lame -b $SMP $src $trg
    fi
done
