###############################################################################
## One dimensional morphological erosion based on the structural element     ## 
## 'se'. Mirror boundary conditions. Implemented in R version 3.0.2.         ##
## Fuks 150328      		                                                 ##
###############################################################################

source("mirrorbound.r") # Padds data boundaries

erode1d <- function(indata, se){
  
  sesize <- floor(se/2)
  ndata <- length(indata)
 
  filtdata <- mirrorbound(indata, sesize, 0) # Applies mirror boundary conditions
  
  outdata <- vector("numeric", ndata)
  for(m in 1:ndata){
    outdata[m] <- min(filtdata[m:(m + 2*sesize)], na.rm = T) #Calculates erosion
  }
  
  return(outdata)
}
