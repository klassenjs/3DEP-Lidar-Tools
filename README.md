Scripts to download and index Minnesota 3DEP data from USGS Rockyweb
====================================================================

Run numbered scripts in order.  Make sure the previous step finishes
successfully before running the next step.  Edit the PROJECTS list as
more data is posted to Rockyweb.  Scripts can be run again and will
run incrementally.

The scripts in this repository assume a standard Linux environment
with:
  - `bash`
  - `find`
  - `jq`
  - `python >= 3.11`
  - `sem` (from GNU Parallel)
  - `wget`
  - `xargs`
  
Also, [GDAL](https://gdal.org) >= 3.6 and [PDAL](https://pdal.io) >=
2.5 are needed for reading and indexing the DEM TIFF files and LAZ
files.

As of December 2024, the total download size is approximately 34TiB,
with 1.6TiB of that being the DEMs and the rest being the LAZ point
clouds.
