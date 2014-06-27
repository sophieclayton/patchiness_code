# perform fft analysis on data from the tokyo containership cruises
# Sophie Clayton, June 2014
# sclayton@uw.edu

# load and interpolate data
# point to load_interpolate function
y = new.chl-mean(new.chl)
dx = new.distance[2]-new.distance[1] # km

n = length(y) # FFT length (better if is a radix 2 number)
m = n/2 # number of distinct frequency bins
fc <- 1/(2*dx) # critical frequency, dx is spacing between observations in km
f <- fc*seq(0,m,1) # frequency bins
Y <- fft(y)
Pfull <- abs(Y)^2/n # periodogram = |Y|^2
Pyy <- Re(Pfull[1:m+1])
Pyy[2:m+1] <- 2*Pyy[2:m+1] # compensate for missing negative frequencies

plot(log10(f[2:m+1]),log10(Pyy[2:m+1]),type='l',xlab=expression('log'[10]*'k'), ylab=expression('log'[10] *'PSD'))