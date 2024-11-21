#!/bin/bash

# Download
for i in `find vdelivery/Datasets/Staged/Elevation/ -name 0_file_download_links.txt` ; do
	if [[ $i == *WI_* ]] ; then
		continue
	fi
	wget --force-directories -nc -nH -w 1 -i $i
done
