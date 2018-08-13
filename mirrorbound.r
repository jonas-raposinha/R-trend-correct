###############################################################################
## Applies mirror boundary conditions to a 1d or 2d object. Implemented in R ##
## version 3.4.3. Last update: Fuks 180203                                   ##
###############################################################################

mirrorbound <- function(indata, ypadding, xpadding){
  
  indata <- as.matrix(indata)
  ny <- dim(indata)[1] #Object dimensions
  nx <- dim(indata)[2]
  
  if(xpadding >= nx){ # Reduces size of padding if equal to or larger than object
    xpadding <- xpadding-1
  }
  
  if(xpadding >= nx){ # Reduces size of padding if equal to or larger than object
    xpadding <- xpadding-1
  }
  
  outdata <- matrix(0, ny+2*ypadding, nx+2*xpadding)
  sum <- 0
  yiter <- 0
  xiter <- 0
  kloop <- c((-ypadding):(ny+ypadding))[-(ypadding+1)] # Loop vectors excluding "0" position
  lloop <- c((-xpadding):(nx+xpadding))[-(xpadding+1)]
  
  for(k in kloop){ # Loops through y
    yout <- k # Position in the original matrix
    if(k < 0){
      yout <- -k
    }
    if(k > ny){
      yout <- 2*ny-k+1 
    }
    yiter <- yiter+1
    for(l in lloop){ # Loops through x
      xout <- l # Position in the original matrix
      if(l < 0){
        xout <- -l
      }
      if(l > nx){
        xout <- 2*nx-l+1
      }
      xiter <- xiter+1
      outdata[yiter, xiter] <- indata[yout, xout] # Prints the padded matrix
    }
    xiter <- 0
  }
  if(xpadding == 0){
    outdata <- as.numeric(outdata)
  }
  return(outdata)
}