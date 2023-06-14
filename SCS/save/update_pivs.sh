#!/bin/bash
if [  -z $1 ]; then  
	echo "provide a script to run"
	exit
else
        INSCR=$1
fi
for i in `cat pivlist`; do 
         ssh pi@$i 'bash -s' < ./$INSCR; 
done
