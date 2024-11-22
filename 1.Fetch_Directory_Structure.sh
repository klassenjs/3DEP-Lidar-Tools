#!/bin/bash

PROJECTS=(
	MN_BeckerCounty_2021_D21
	MN_CentralMissRiver_B22
	MN_GoodhueCounty_2020_A20
	MN_LakeCounty_2018_C20
	MN_LakeSuperior_2021_B21
	MN_MissouriRiverBigSioux_2021_B21
	MN_RainyLake_2020_B20
	MN_RiverEast_B23
	MN_RiverWest_B23
	MN_SE_Driftless_2021_B21
	MN_UpperMissRiver_B22
)

# Get folder structure
for project in ${PROJECTS[@]} ; do
	wget --mirror -np -nH -A txt --level=1 https://rockyweb.usgs.gov/vdelivery/Datasets/Staged/Elevation/LPC/Projects/${project}/
	wget --mirror -np -nH -A txt --level=1 https://rockyweb.usgs.gov/vdelivery/Datasets/Staged/Elevation/OPR/Projects/${project}/
done

# Get list of files
for i in vdelivery/Datasets/Staged/Elevation/*/Projects/*/*; do
	[ -d "$i" ] && wget --force-directories -nH -w 1 https://rockyweb.usgs.gov/$i/0_file_download_links.txt
done

# Create symlink so DEMs from S3 get put in the right place
if [ ! -e StagedProducts ] ; then
	ln -s vdelivery/Datasets/Staged StagedProducts
fi
