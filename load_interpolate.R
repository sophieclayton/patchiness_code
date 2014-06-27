require(signal)

# load data
data <- read.csv('/Users/sclayton/Documents/seaflow/data/tokyo_underway/Tokyo_underway_chl1.csv')

# clean out NA values
cl.data <- na.omit(data)
  
# calculate distance between points
point1 <- cbind(cl.data$long.dc[1:(length(cl.data$long.dc)-1)],cl.data$lat.dc[1:(length(cl.data$lat.dc)-1)])
point2 <- cbind(cl.data$long.dc[-1],cl.data$lat.dc[-1])

cl.dist <- distance.chord.mat(point1,point2)
distance <- vector()
tmp <- cumsum(cl.dist)
distance[1]=0
distance[2:(length(tmp)+1)]=tmp
rm(tmp)

# interpolate onto regular grid
dx=0.5
new.distance <- seq(0,floor(max(distance)),by=dx)
new.chl <- interp1(distance,cl.data$chl,new.distance,method="nearest")
new.temp <- interp1(distance,cl.data$T1,new.distance,method="nearest")
acf(new.chl,lag=5000,demean=T)
  

