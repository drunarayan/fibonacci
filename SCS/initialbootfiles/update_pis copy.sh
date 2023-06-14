#!/bin/bash
if [  -z $1 ]; then  
	echo "provide a script to run"
	exit
else
	if [  -z $2 ]; then
		echo "provide a list of pis to run on"
		exit
	else
        	INSCR=$1
		INPIS=$2
		for i in `cat $INPIS`; do 
         		ssh pi@$i 'bash -s' < ./$INSCR; 
		done
	fi
fi
