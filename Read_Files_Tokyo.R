# # # # Column from 1:8 = MIMS
# # # # Column from 9:23 = GPS
# # # # Column from 24:29 = TSG
# # # # Column from 30:47 = Optode
# # # # Column from 48:288 = SUNA

#####   The TSG output is:
#####	T1 = internal TSG temperature in Celsius.
#####	C1 = conductivity (S/m)
#####	S = salinity (psu) calculated from T1 and C1.
#####	SV = sound velocity (meters/sec) calculated from T2 and S.
#####	T2 = ocean surface temperature in Celsius (SBE38 probe close to sea chest).

#####   The Fluorometer output is labeled as AI.1 and is chlorophyll-a concentration (ug/L).

path<-'/Volumes/data/cruise/instrument/underway/containership_package/Tokyo_5/XLS/'
cruise <- 'Tokyo_5'
savepath <- paste('/Users/francois/Documents/DATA/SeaFlow/Tokyo/', cruise,"/",sep="")


file.list <- dir(path, recursive=T, pattern = ".xls")
file.list <- file.list[-106]

file <- file.list[1]
df <- read.delim(paste(path,file, sep=""))
mat <- data.frame(rbind(rep(NA,length(df))), row.names=NULL)
mat <- mat[0,]
names(mat) <- names(df)

#######################
#### ALL RAW DATA ##### CREATE ONE BIG FILE
#######################

for (i in file.list) {
	print(paste("processing file:",i))
	file <- paste(path,i,sep="")
	df <- read.delim(file)
	mat <- rbind(mat, df)
	print(nrow(mat))
	}
mat$id <- 1:nrow(mat) ## add number of rows

write.csv(mat,file=paste(savepath,cruise,"_raw_data_all.csv", sep=""), row.names=FALSE)

##bug for Tokyo_1 in second part of the files (05262011_080151)
mat$X18.09 <- NA
mat$X28.12 <- NA
mat$X32.09 <- NA
mat$X40.09 <- NA
mat$X44.12 <- NA
mat$TP <- NA
mat2 <- cbind(mat[,1], mat[,284:288], mat[,2], mat[,289],mat[,3:283])
colnames(mat2) <- names(mat1) #mat1 is the matrix of the files before 05262011_080151


#####################
#copy data to BLOOM #
#####################

#scp -r -c arcfour /Volumes/HDD_ribalet/Tokyo\ Cruises/Tokyo_2/* ribalet@bloom.ocean.washington.edu:/share/data/cruise/instrument/underway/containership_package/Tokyo_2




###############
#### GPS #####
###############
path<-'/Users/francois/Documents/DATA/SeaFlow/Tokyo/'
cruise <- 'Tokyo_4'
savepath <-paste(path,cruise,"/",sep="")

mat <- read.csv(paste(savepath,cruise,"_raw_data_all.csv",sep=""))
data <- mat[,9:23]

# converting DMS into decimal DEG (for Pacific (longitude 0-360))
data.w <- subset(data, data[,"E.W"] == "W")
data.w[,"long.dc"] <- 360 - (as.numeric(substr(data.w[,"Long"], 1,3)) + as.numeric(substr(data.w[,"Long"],4,9))/60)
data.e <- subset(data, data[,"E.W"] == "E")
data.e[,"long.dc"] <- as.numeric(substr(data.e[,"Long"], 1,3)) + as.numeric(substr(data.e[,"Long"],4,9))/60
data[row.names(data.e),"long.dc"] <- data.e[,"long.dc"]
data[row.names(data.w),"long.dc"] <- data.w[,"long.dc"]


data.n <- subset(data, data[,"N.S"] == "N")
data.n[,"lat.dc"] <- as.numeric(substr(data.n[,"Lat"], 1,2)) + as.numeric(substr(data.n[,"Lat"],3,8))/60
data.s <- subset(data, data[,"N.S"] == "S")
data.s[,"lat.dc"] <- -(as.numeric(substr(data.s[,"Lat"], 1,2)) + as.numeric(substr(data.s[,"Lat"],3,8))/60)
data[row.names(data.n),"lat.dc"] <- data.n[,"lat.dc"]
data[row.names(data.s),"lat.dc"] <- data.s[,"lat.dc"]

gps <- cbind(data[,1:4], data[,16:17])


write.csv(data,file=paste(savepath,cruise,"_gps.csv", sep=""), row.names=FALSE)



##########################
#### ALL BUT RAW SUNA ####
##########################
merged <- cbind(mat[,1:61], gps)
write.csv(merged, file=paste(savepath,cruise,"_merged.csv", sep=""), row.names=FALSE)

################
##### MIMS #####
################
#mims <- cbind(mat[,1:8], gps)
#write.csv(mims,file=paste(savepath,cruise,"_mims.csv", sep=""), row.names=FALSE)
#
#
###############
##### TSG #####
###############
#tsg <- cbind(mat[,24:29], gps)
#write.csv(tsg,file=paste(savepath,cruise,"_tsg.csv", sep=""), row.names=FALSE)
#
#
################
##### Optode ###
################
#optode <- cbind(mat[,30:47], gps)
#write.csv(optode,file=paste(savepath,cruise,"_optode.csv", sep=""), row.names=FALSE)
#
#
###############
##### SUNA ####
###############
#raw_suna <- cbind(mat[,48:288], gps)
#write.csv(raw_suna,file=paste(savepath,cruise,"_raw_suna.csv", sep=""), row.names=FALSE)
#suna <- cbind(mat[,49:51], gps)
#write.csv(suna,file=paste(savepath,cruise,"_suna.csv", sep=""), row.names=FALSE)
#
#
#
##################
### FLUORIMETER ##
##################
#fluo <- cbind(mat[,7], gps)




#### PLOT DATA
library(mapproj)
library(maps)
library(mapdata)
library(plotrix)

jet.colors <- colorRampPalette(c("#00007F", "blue", "#007FFF", "cyan", "#7FFF7F", "yellow",	"#FF7F00", "red", "#7F0000"))
df <- read.csv("/Users/francois/Documents/DATA/SeaFlow/Tokyo/Tokyo_1/Tokyo_1_merged.csv")


#####The TSG output is:
#####	T1 = internal TSG temperature in Celsius.
#####	C1 = conductivity (S/m)
#####	S = salinity (psu) calculated from T1 and C1.
#####	SV = sound velocity (meters/sec) calculated from T2 and S.
#####	T2 = ocean surface temperature in Celsius (SBE38 probe close to sea chest).

#####The Fluorometer output is labeled as AI.1 and is chlorophyll-a concentration (ug/L).

xmin <- min(df[,"long.dc"]) ; xmax <- max(df[,"long.dc"]); ymin <- min(df[,"lat.dc"]); ymax <- max(df[,"lat.dc"])
#xmin <- 116 ; xmax <- 145 ; ymin <- 38 ; ymax <- 42
margin <- (xmax-xmin)/25

par(mfrow=c(1,1), oma=c(2,2,2,2), mar=c(4,4,1,4))
para <- "S"
percentile <- cut(df[,para], 100)
leg <- pretty(range(df[,para]), n=7)
plot(df[,"long.dc"], df[,"lat.dc"], type='p',col=jet.colors(100)[percentile], xlab="Longitude (deg)", ylab="Latitude", asp=1, xlim=c(xmin,xmax), ylim=c(ymin,ymax))
try(maps::map('worldHires',add=TRUE))
try(map("world2Hires", add=TRUE))
ylim <- par('usr')[c(3,4)]
xlim <- par('usr')[c(1,2)]
color.legend(xlim[2]- (margin * 1/2) , ylim[1], xlim[2], ylim[2], legend=leg, rect.col=jet.colors(100), gradient='y',align='rb')
mtext(para, side=4, line=3)


#plot(df[,"seconds.in.week"], df[,para], xlim=c(250000,600000), ylim=c(-25,10), type='l')