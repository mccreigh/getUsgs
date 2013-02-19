

LICENSE: DO WHAT YOU WILL BUT NO GUARANTEES OR WARANTIES, MAY CAUSE BAD BEHAVIOUR. USE AT OWN RISK.

BACKGROUND: Automated data pulls from the USGS are obscure at best. I had to call twice, and ask for the links to the documenation links to be restored before I could crack this. I want to share it with you because I felt the pain. If you're grateful, you could email me and say so! I'd love to hear that I saved someone the anguish of figuring this out. It's actually not that bad if you know where to start and are given the full documentation. I didnt really have either of those. 

PURPOSE: I want to pull NED and NLCD2001 products for a wide array of locations over the lower 48. The three pieces of code do this. 

OVERVIEW: 

getUsgsData.r: this is a somewhat general purpose function. 

getGpsUsgsData.r: this is essentially a loop on getUsgsData.r pulling data tiles surrounding certain GPS installations.

unpackGpsUsgs.sh: a shell script to unpack the data associated with the previous routine.

The idea is that you have a central data repository where getUsgsData always pulls data to. It uses wget with the -nc option so that the same data is not retrieved twice. Since you're keeping all your USGS data in a single directory, it's best to know what files are associated with what projects. getUsgsData.r returns the files pulled for a given lat,lon,delta and a list of these is returned for all the locations in getGpsUsgsData.r. This list is the input to unpackGpsUsgs.sh which unpacks the data to a more specific repo where it can be used for project specific purposes.

There may be a better way of doing this. You may need additional functionality that the USGS offers, namely through their seamless services. I'm only using tiled services and getting direct URLs for download. This is intended as a jumping off point for using R to get what you want, not a full-fledged set of functions to do everything. The state of this code represents my first attempt at doing this on only 1 project. If significant time has gone by please ask me if a newer version is avail as I dont plan to update regularly. 

Good luck! 