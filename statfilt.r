##################################################################################
## Implementation of 1d mean or median filters for trend correction. Mirror     ## 
## boundary conditions. Implemented in R version 3.0.2. Fuks 150401		    	   	##
##################################################################################

source("mirrorbound.r") # Padds data boundaries

statfilt <- function(indata, filtsize, choice){

  sesize <- floor(filtsize/2)
  ndata <- length(indata)

  filtdata <- mirrorbound(indata, sesize, 0) # Applies mirror boundary conditions
  trend <- vector("numeric", ndata)
  
  switch(choice, # Implements choice of filter
  	meanfilt={
  		for(m in 1:ndata){
  		trend[m] <- mean(filtdata[m:(m + 2*sesize)], na.rm = T) # Applies mean filter
  		}
  	},
  	medianfilt={
  		for(m in 1:ndata){
  		trend[m] <- median(filtdata[m:(m + 2*sesize)], na.rm = T) # Applies median filter
  		}
  	},
  	stop("error: invalid choice of filter")
  )
  	
  returndata <- matrix(data = 0, nrow = length(trend), ncol = 2) # Returns corrected data and the trend
  returndata[,1] <- indata - trend
  returndata[,2] <- trend
  return(returndata)
}
