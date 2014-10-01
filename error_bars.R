# plot scatter plot with error bars

plot.error.bars <- function(x,avg,sdev,xlab,ylab,main){
 
  plot(x, avg,ylim=range(c(avg-sdev, avg+sdev)),
       pch=19, xlab=xlab, ylab=ylab,
       main=main)
  
  # hack: we draw arrows but with very special "arrowheads"
  arrows(x, avg-sdev, x, avg+sdev, length=0.05, angle=90, code=3)
}