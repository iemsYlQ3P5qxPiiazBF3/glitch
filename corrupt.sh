#!/bin/bash

#$1 - input file, or help
#$2 - number of corruptions
#$3 - start of corruption
#$4 - file to corrupt with
#$5 - loop of corruptions. (takes only beginning)
#$6 - debug
#if $2/$3/$4 'x', will be random


case $1 in
    "-h"|"--help")
    echo "1: input file
2: corruption number (optional)
3: corruption header (optional)
4: file to corrupt with (optional)
5: loop times"
    exit
    ;;
esac

if [ "${#}" -lt "4" ];then
    echo -e "\033[38;05;9mPlease specify 4 values\e[0m"
    re(){
    return 1
    }
    re
    exit
fi

echo "input: $1
number of corruption: $2
corruption header: $3
input file: $4
loop count: $5"


file=$1
num=$2
cp "$file" "2${file}"
tmp="$file"
file="2${file}"

case $2 in
    "x"|"-")
    num="$((RANDOM%100))"
    ;;
    *)
    num="$2"
    ;;
esac

case $3 in
    "x"|"-")
    header=$(bc<<<"ibase=A;obase=A;$(tr -cd '0-9'</dev/urandom|head -c3200)%$(wc -c<$file)"|tr -d '\\\n')
    ;;
    *)
    header="$3"
    ;;
esac


case $4 in
    "x"|"-")
    infile="/dev/urandom"
    ;;
    *)
    infile="$4"
    ;;
esac

case $5 in
	""|"1"|"x"|"-")
	dd if=$infile of=dat.tmp bs=1 count=$num status=none >/dev/null
	[ ! -z "$6" ]&&{ echo -n '0x';echo "ibase=A;obase=G;$header"|bc|tr -d '\\n';echo -n '=';xxd -u -p<dat.tmp|tr -d '\n';echo -n ' ';}
	dd if=$infile of=$file bs=1 seek=$header conv=notrunc count=$num status=none
	;;
	*)
	for i in $(seq $5);do
		header=$(bc<<<"ibase=A;obase=A;$(tr -cd '0-9'</dev/urandom|head -c3200)%$(wc -c<$file)"|tr -d '\\\n')
		dd if=$infile of=dat.tmp bs=1 count=$num status=none >/dev/null
		[ ! -z "$6" ]&&{ echo -n '0x';echo "ibase=A;obase=G;$header"|bc|tr -d '\\\n';echo -n '=';xxd -u -p<dat.tmp|tr -d '\n';echo -n ' ';}
		dd if=dat.tmp of=$file bs=1 seek=$header conv=notrunc count=$num status=none
	done
	;;
esac
