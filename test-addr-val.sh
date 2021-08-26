#!/bin/bash
for i in $(cat|tr '=' '_'|sed 's/0x//g');do
	cp $1 2$1
	poke 2$1 $(echo "$i"|tr '_' ' ')
	echo "0x$i"|tr '_' ' '
	read -s
done
