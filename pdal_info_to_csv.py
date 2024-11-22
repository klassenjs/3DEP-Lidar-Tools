#!/usr/bin/python3
# python3 pdal_info_to_csv.py vdelivery > a.csv 2> a.err
# ogrinfo -oo GEOM_POSSIBLE_NAMES=boundary a.csv a
# ogr2ogr -f GPKG MN-3DEP-Index-With-Tile-Stats.gpkg -oo GEOM_POSSIBLE_NAMES=boundary -a_srs EPSG:4326 -nln tindex a.csv a
# ogrinfo MN-3DEP-Index-With-Tile-Stats.gpkg -sql "alter table tindex drop column boundary"

import csv
import json
import os
import sys
import time

dims = ["Z","Intensity","ReturnNumber","GpsTime"]
stats = ["minimum","maximum","average","stddev"]
enums = ["Classification"]

c = csv.writer(sys.stdout)


head = []
head.append("filename")
head.append("boundary")
head.append("avg_pt_per_sq_m")
head.append("avg_pt_spacing")
for dim in dims:
    for stat in stats:
        head.append(dim+"_"+stat)
for enum in enums:
    head.append(enum)

c.writerow(head)

###

for root, dirs, files in os.walk(sys.argv[1]):
    for filename in files:
        if filename.endswith(".laz.json"):
            try:
                with open(os.path.join(root, filename)) as f:
                    j = json.load(f)

                    if "stages" in j:
                        # Handle `pdal pipeline` metadata format
                        j_stats = j["stages"]["filters.stats"]
                        j_boundary = j["stages"]["filters.hexbin"]
                    else:
                        # Handle `pdal info` metadata format
                        j_stats = j["stats"]
                        j_boundary = j["boundary"]

                    row = []
                    row.append(os.path.join(root,filename.replace(".json","")))
                    row.append(json.dumps(j_stats["bbox"]["EPSG:4326"]["boundary"]))
                    row.append(j_boundary.get("avg_pt_per_sq_unit"))
                    row.append(j_boundary.get("avg_pt_spacing"))

                    for dim in dims:
                        el = [x for x in j_stats["statistic"] if x["name"] == dim][0]
                        for stat in stats:
                            val = el[stat]
                            if dim == "GpsTime" and stat != "stddev":
                                val = int(val) + 315986400 + 1000000000
                                val = time.gmtime(val)
                                val = time.strftime("%Y-%m-%dT%H:%M:%SZ", val)
                            row.append(val)
                    for enum in enums:
                        el = [x for x in j_stats["statistic"] if x["name"] == enum][0]
                        row.append(" ".join(map(str, el["values"])))
                    c.writerow(row)
            except Exception as e:
                exc_type, exc_obj, exc_tb = sys.exc_info()
                sys.stderr.write(f"{os.path.join(root,filename)} failed due to {str(e)} at line {exc_tb.tb_lineno}\n")
