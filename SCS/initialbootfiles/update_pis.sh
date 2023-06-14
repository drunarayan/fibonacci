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
				THISPI=$i
				if [ "${THISPI:0:1}" = "#" ]; then 
					echo "skip $THISPI"
				else
					echo "Updating $THISPI ..."
					ssh pi@$i 'bash -s' < ./$INSCR;
 				fi
		done
	fi
fi
