#!/bin/bash
if [  -z $1 ]; then  
        echo "provide a basename"
	echo "$0 <basename> <dirname>"
        exit 1
else
        if [  -z $2 ]; then
                echo "provide a dir to search in"
		echo "$0 <basename> <dirname>"
                exit 1
	else
		basename=$1
		dirname=$2
	fi
fi

iFiles=$( find $dirname -name "$basename*.jpg" -type f 2> /dev/null | wc -l )

retval=1
if [ $iFiles -gt 0 ]; then
	for i in `ls $dirname/$basename*.jpg`; do
		first=${i%%.jpg}
		second=${first##*$basename}
        third=$(echo $second | sed 's/^0*//')
        retval=$(( $third + 1 ))
		#echo $first
		#echo $second
	done
fi

echo $retval


