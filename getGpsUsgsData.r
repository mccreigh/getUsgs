require(plyr)
options(warn=1)
source("~/USGS/getUsgsData.r")

load('/data/snow/density/gps/gpsInfo.rsav')
outDir <- '/server/scratch/mccreigh/USGS/zipped/'

fileNames <- dlply( gpsInfo, 2,
                 function(rr) getUsgsData(lon=rr$Longitude, lat=rr$Latitude, deltaLL=.005, directory=outDir,
                                          pull=FALSE) )

## one site in oregon required 2 NED tiles. so it had 4 associated files.
whAk <- which( laply( fileNames, length) <3) 

uniqueFileNames <- unique(unlist(fileNames))
uniqueFileNames <- uniqueFileNames[-(which(is.na(uniqueFileNames)))]

write.table( uniqueFileNames, file='~/density/gps/gpsUsgsFileNames.txt',
            row.names=FALSE, col.names=FALSE, quote=FALSE)

fileNames[whAk]
uniqueFileNames <- unique(unlist(fileNames[-whAk]))
uniqueFileNames <- uniqueFileNames[-(which(is.na(uniqueFileNames)))]

write.table( uniqueFileNames, file='~/density/gps/gpsUsgsFileNamesNoAK.txt',
            row.names=FALSE, col.names=FALSE, quote=FALSE)
