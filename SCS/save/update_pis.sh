#!/bin/bash
if [  -z $1 ]; then  
	echo "provide a script to run"
	exit
else
        INSCR=$1
fi
for i in `cat pilist`; do 
         ssh pi@$i 'bash -s' < ./$INSCR; 
done
