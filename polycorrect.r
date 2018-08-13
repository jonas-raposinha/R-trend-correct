##################################################################################
## Applies trend correction  based on iterative polynomial interpolation (Gan,	##
## Ruan & Mo, 2006, Chemometrics Intel. Lab. Sys.). Implemented in R version    ##
## 3.0.2. Fuks 150328                                                           ##
##################################################################################

polycorrect <- function(indata, degree){

  #Calculates the first approximation of the baseline
  sourcedata <- c(1:length(indata))
  filtdata <- indata
  oldtrend <- vector("numeric", length(indata))+1
  reg <- lm(filtdata ~ poly(sourcedata, degree)) #Polynomial fitting
  trend <- predict(reg, data.frame(sourcedata))
  normval <- norm(as.matrix(trend-oldtrend))/norm(as.matrix(oldtrend))
  
  #Refines the baseline approx. using interative interpolation
  while(normval > 0.005){
    reg <- lm(filtdata ~ poly(sourcedata, degree))
    trend <- predict(reg, data.frame(sourcedata))
    normval <- norm(as.matrix(trend-oldtrend))/norm(as.matrix(oldtrend))
    oldtrend <- trend
    for(k in 1:length(filtdata)){
      if(filtdata[k] > trend[k]){
       filtdata[k] <- trend[k]
      }
    }
  }

  #Performs the trend correction
  outdata <- matrix(data = 0, nrow = length(trend), ncol = 2)
  outdata[,1] <- indata - trend
  outdata[,2] <- trend
  return(outdata)
}
