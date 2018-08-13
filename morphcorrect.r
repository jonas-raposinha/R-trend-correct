##################################################################################
## Implentation of Tophat operator using morphological opening (dilation of     ## 
## erosion) for trend correction (Sauve & Speed, 2004, Berkeley). Implemented   ##
## in R version 3.0.2. Fuks 150328                                              ##
##################################################################################

source("dilate1d.r") # Dilation
source("erode1d.r") # Erosion

morphcorrect <- function(indata, se){

  erdata <- erode1d(indata, se) # Performs erosion
  trend <- dilate1d(erdata, se) # Performs dilation of erosion = opening

  returndata <- matrix(data = 0, nrow = length(trend), ncol = 2) # Tophat filtering
  returndata[,1] <- indata - trend
  returndata[,2] <- trend
  return(returndata)
}
