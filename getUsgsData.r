## all the WSDLs and documentation are here 
## http://cumulus.cr.usgs.gov/app_services.php

## if (!require(XML)) install.packages("XML")
## if (!require(SSOAP)) install.packages('SSOAP', repos = "http://www.omegahat.org/R", type = "source")
require(XML)
require(SSOAP)
#require(RCurl)
require(plyr)

##'#####################################################################
## get all the functions from their WSDLS
IndexService <-
  genSOAPClientInterface(def='http://ags.cr.usgs.gov/index_service/Index_Service_SOAP.asmx?WSDL')
IS <- IndexService@functions

RequestValidationService <-
 genSOAPClientInterface(def='http://extract.cr.usgs.gov/requestValidationService/wsdl/RequestValidationService.wsdl')
RVS <- RequestValidationService@functions

DownloadService <- genSOAPClientInterface(def='http://extract.cr.usgs.gov/axis2/services/DownloadService?wsdl')
DS <- DownloadService@functions

##'#####################################################################
## some helper functions
namedList <- function(vec, names=vec) {
  l <- as.list(vec)
  names(l) <- names
  l
}

## the return xml has malformed amperstands
fixAmperstands <- function(string) gsub('&','&amp;',string)

##'#####################################################################
if (FALSE) {
  ## use Boulder as an example location
  lat <- 40.04
  lon <- -105.23
  deltaLL <- .001
  directory <- '/data/mccreigh/USGS/'
}
  ## purpose:
## automate the grab of 3 USGS products: NED
##   1) 1/3 arc second
##   2) NLCD 2001 class 
##   3) NLCD 2001 canpoy fraction

## INPUT
## lon, lat, deltaLL:  
##   - In western and southern hemispheres, the lon and lat (respectively) are negative.
##   - deltaLL is a scalar delta (square radius) which applies to both lon and lat.
## directory:
##   - path to save the data. file names are generated for the files are based on the bounding
##     box of the tiled data set returned by the server.
## pullData: do or do not pull the data from the server. Can be useful to recreate file names associated
##           with certain locations.

## OUTPUT
## reutrns a list of files that were pulled for the given lon, lat, and deltaLL inputs.
## i'm pulling all my tiles to a single directory and then pulling out files for individual products using
## this returned list for each product. I use/included a shell script to unpack a subset of files
## in the directory given a text file of the file names.

getUsgsData <- function(lon, lat, deltaLL, directory, pullData=TRUE) {
  ## this gets the product key/
  ##attributeList <- IS$return_Attributes(XMin=XMin, XMax=XMax, YMin=YMin, YMax=YMax, EPSG=EPSG,
  ##                                      Attribs='SEAMTITLE,PRODUCTKEY')
  ## this return list is not parsed correctly compared to the xml file. but i can still see the product keys.

  EPSG <- 4326 
  XMin <- lon-deltaLL
  XMax <- lon+deltaLL
  YMin <- lat-deltaLL
  YMax <- lat+deltaLL
  
  ## product keys
  ## NED 1/3: N3F (float), N3G (arcGrid)
  ## NLCD 2001 cover class: L1L
  ## NLCD 2001 canopy fraction: L1C
  pks <- c('N3F','L1L','L1C')
  pkInfo <- IS$return_Product_Info(paste(pks,collapse=','))
  
  layerIds <- paste(pks,collapse=',') ## in the case of tiled downloads, this is comma separated product keys.
  chunkSize=''
  json='FALSE' ## only TRUE returns a json string
  x1 <- "<REQUEST_SERVICE_INPUT>"
    x2 <- "<AOI_GEOMETRY>"
      x3 <- "<EXTENT>"
        x4 <- paste0("<TOP>",YMax,"</TOP>")
        x5 <- paste0("<BOTTOM>",YMin,"</BOTTOM>")
        x6 <- paste0("<LEFT>",XMin," </LEFT>")
        x7 <- paste0("<RIGHT>",XMax,"</RIGHT>")
      x8 <- "</EXTENT>"
      x9 <- "<SPATIALREFERENCE_WKID/>"
    x10 <- "</AOI_GEOMETRY>"
    x11 <- "<LAYER_INFORMATION>"
      x12 <- paste0("<LAYER_IDS>",layerIds,"</LAYER_IDS>")
    x13 <- "</LAYER_INFORMATION>"
    x14 <- paste0("<CHUNK_SIZE>",chunkSize,"</CHUNK_SIZE>")
    x15 <- "<ORIGINATOR/>"
    x16 <- paste0("<JSON>",json,"</JSON>")
  x17 <- "</REQUEST_SERVICE_INPUT>"
  requestInfoXml=paste(laply( 1:17, function(xx) get(paste0('x',xx)) ), collapse='')

  dataDirect <-
    xmlToDataFrame(
      fixAmperstands(
        RVS$getTiledDataDirectURLs2(requestInfoXml=requestInfoXml)@getTiledDataDirectURLs2Return ) )

  ## -nc is "dont not get newer versions of existing files." as per the wget help. 
  wgetUrl <- function(url) system( paste0("wget -nc --directory-prefix=",directory," '",url,"'" ) )
  if (pullData) dum <- laply( dataDirect$DOWNLOAD_URL, wgetUrl )

  url2FileName <-
    function(url)
      strsplit( as.character(url),
               paste0('http://gisdata.usgs.gov/TDDS/DownloadFile.php\\?TYPE=ned3f_zip&FNAME=|',
                      'http://gisdata.usgs.gov/TDDS/DownloadFile.php\\?TYPE=NLCD&FNAME=2001/landcover/conus/|',
                      'http://gisdata.usgs.gov/TDDS/DownloadFile.php\\?TYPE=NLCD&FNAME=2001/canopy/conus/|',
                      '&ORIG=RVS') )[[1]][2]
  fileNames <- laply( dataDirect$DOWNLOAD_URL, url2FileName )
  fileNames
}



