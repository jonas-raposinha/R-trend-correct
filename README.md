# R-trend-correct
4 methods for trend correction or analysis using boundary conditions

The terms "trend" and "baseline" can often enough refer to the same phenomenon in practice but with different underlying assumptions. In the case of trend, we mean the overall direction of change over time in a data set, not considering changes of smaller orders of magnitude, and may be important to the analysis. The baseline is usually taken to be the background signal level (whichever shape it may have) from which we distinguish our signal of interest. Changes in the baseline (due to experitmental artifacts or other factors) are thus often either not interesting or actually impede analysis. What both cases have in common though, is that we need to separate the trend or baseline from the rest of the data before we can perform further analysis.
Below, I will present 4 different approaches to do this, all with different pros and cons. I will not discuss these in great detail but give some pointers as to their respective applications. The approaches are: mean filter, median filter, polynomial interpolation and the morphological tophat.

Firstly, let's look at two different data sets. The first one is Long-Term Government Bond between Jan 1960 and Jan 2018, from the [Federal Reserve Economic Data, St Louis](ttps://fred.stlouisfed.org/).

```
sa_data <- read.table("sa_lt_govt_bond_yields.csv", sep = ",", header = T)
plot(sa_data$IRLTLT01ZAM156N, type = "l", main = "LT Government Bond Yields, South Africa, 1960-2018", ylab = "Percent", xlab = "Month")
```

![plot1](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/Rplot.png)

The second one is (slightly altered) experimental data on flourescence intensity over time with a varying baseline. Our interest in this case is the intensity peaks.
```
int_data <- read.table("peaks_test.csv", sep = ";", dec = ",")
plot(int_data$V3, main = "Flourescence intensity over time", ylab = "Intensity (a.u.)", xlab = "Time (s)")
```

![plot2](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/Rplot01.png)

Next, we go through the approaches one by one, starting with the mean filter, essentially a classic low-pass filter. We need to specify the size of the filter kernel (matrix) that decides how rapid changes will be filtered and will of course depend on the data set. To illustrate we try 3 different values.
```
source("mirrorbound.r") # Call the boundary condition routine
source("statfilt.r") # Mean and median filters
filt_data1 <- statfilt(sa_data$IRLTLT01ZAM156N, 10, 1) #Applies the mean filter
filt_data2 <- statfilt(sa_data$IRLTLT01ZAM156N, 50, 1)  
filt_data3 <- statfilt(sa_data$IRLTLT01ZAM156N, 150, 1)

plot(sa_data$IRLTLT01ZAM156N, col =  "blue", type = "l", main = "Kernel size 10", ylab = "Percent", xlab = "Month") #Plots original data
points(filt_data1[,2], col = "red", pch = 16, type = "l") 
plot(sa_data$IRLTLT01ZAM156N, col =  "blue", type = "l", main = "Kernel size 50", ylab = "Percent", xlab = "Month") 
points(filt_data2[,2], col = "red", pch = 16, type = "l")
plot(sa_data$IRLTLT01ZAM156N, col =  "blue", type = "l", main = "Kernel size 150", ylab = "Percent", xlab = "Month")
points(filt_data3[,2], col = "red", pch = 16, type = "l")
```

![plot3](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/Rplot02.png)
![plot4](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/Rplot03.png)
![plot5](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/Rplot04.png)
