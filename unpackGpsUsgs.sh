#!/bin/bash

while read line           
do           
    ## echo -e $line
    line2=`echo $line | cut -d '.' -f 1`
    ##echo /server/scratch/mccreigh/USGS/zipped/${line2}.zip -d /server/scratch/mccreigh/USGS/unzipped/gps/${line2}/
    if [[ $line2 == n* ]]
    then  ## dont have to protect ned products from exploding
	unzip /server/scratch/mccreigh/USGS/zipped/${line2}.zip -d /server/scratch/mccreigh/USGS/unzipped/gps/
    else ## do have to protect NLCD from exploding
	unzip /server/scratch/mccreigh/USGS/zipped/${line2}.zip -d /server/scratch/mccreigh/USGS/unzipped/gps/${line2}/
    fi 

done <~/density/gps/gpsUsgsFileNamesNoAK.txt