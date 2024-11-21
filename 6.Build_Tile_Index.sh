#!/bin/bash

# Make tindex (needs my gdaltindex first layer fix)
pdal tindex create \
		--ogrdriver GPKG --tindex tindex.gpkg --lyr_name tindex-lpc \
		--fast_boundary \
		--t_srs EPSG:6344 \
		--filespec 'vdelivery/Datasets/Staged/Elevation/LPC/Projects/*/*/LAZ/*.laz'

find vdelivery/Datasets/Staged/Elevation/OPR/Projects/*/* -name '*.tif' |	\
	xargs -n 1000 -d '\n' \
		gdaltindex -f GPKG -t_srs EPSG:6344 -lyr_name tindex-dem tindex.gpkg
