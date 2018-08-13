###############################################################################
## One dimensional morphological dilation based on the structural element    ## 
## 'se'. Mirror boundary conditions. Implemented in R version 3.0.2.         ##
## Fuks 150328    			                                                ##
###############################################################################

source("mirrorbound.r") # Padds data boundaries

dilate1d <- function(indata, se){

  sesize <- floor(se/2)
  ndata <- length(indata)

  filtdata <- mirrorbound(indata, sesize, 0) # Applies mirror boundary conditions

  outdata <- vector("numeric", ndata)
  for(m in 1:ndata){
    outdata[m] <- max(filtdata[m:(m + 2*sesize)]) #Calculates dilation
  }

  return(outdata)
}
