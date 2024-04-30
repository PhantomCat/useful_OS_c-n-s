#!/bin/bash

dirs=$(smbd -b | egrep "LOCKDIR|STATEDIR|CACHEDIR|PRIVATE_DIR" | awk -F" " '{print $NF}')

for folder in $dirs
do
	find $folder -type f -regex '^.*\.tdb' -exec rm {} \;
done

