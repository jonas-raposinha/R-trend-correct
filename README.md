# R-trend-correct
4 methods for trend extraction or baseline correction using boundary conditions

For the sake of the discussion below, I make the claim that the terms "trend" and "baseline" often enough refer to the same phenomenon in practice, but with different underlying assumptions.
In the case of trend, we here mean the overall direction of change over time in a data set that may be important to the analysis, not considering changes of smaller orders of magnitude.
The baseline is here taken to be the background signal level (whichever shape it may have), from which we distinguish our signal of interest. Changes in the baseline (due to experimental artifacts or other factors) are thus often at best not interesting or, worse, impede analysis.
What both cases have in common though, is that we need to separate the trend or baseline from the rest of the data before we can perform further analysis. Below, I will present 4 different approaches to separate the trend or baseline from the rest of the data, all with different pros and cons. For the sake of space, I won't be discussing these approaches in great detail (especially not their mathematical foundations, as they are adequately desscribed elsewhere), but rather give some pointers as to their respective applications. At times where I think it benefits the discussion though, I will include references to more in depth treatments.
Disclaimer 1: As always, the more we know about our data (signal characteristics, noise frequencies, sampling procedure etc), the better informed our choice of processing approach will be. Thus, automatic trend extraction or baseline correction will often fall short for some types of data, while working well on others.
Disclaimer 2: I will not cover the related problem of trend detection, i.e. determining whether or not a statistically significant trend exists in the data set.
The approaches I will cover here are: mean filter, median filter, polynomial interpolation and the morphological tophat.
Side note: all 4 approaches require boundary conditions, meaning some way of handling the beginning and end of the data set. I picked "mirror" boundary conditions, which I will introduce at another time.

Firstly, let's look at two different data sets. The first one is Long-Term Government Bond between Jan 1960 and Jan 2018, from the [Federal Reserve Economic Data, St Louis](https://fred.stlouisfed.org/).

```
sa_data <- read.table("sa_lt_govt_bond_yields.csv", sep = ",", header = T)
plot(sa_data$IRLTLT01ZAM156N, type = "l", main = "LT Government Bond Yields, South Africa, 1960-2018", ylab = "Percent", xlab = "Month")
```

![plot1](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/1.png)

The second one is (slightly altered) experimental data on flourescence intensity over time with a varying baseline. Our interest in this case is the intensity peaks.
```
int_data <- read.table("peaks_test.csv", sep = ";", dec = ",")
plot(int_data$V3, main = "Flourescence intensity over time", ylab = "Intensity (a.u.)", xlab = "Time (s)")
```

![plot2](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/2.png)

Next, we go through the approaches one by one, starting with the mean filter (aka moving average or blurring). This is a simple, linear low-pass filter that turns each data point into the mean of itself and its neighbours. The size of the neighbourhood that is considered (ie the filter kernel size) decides how rapid changes will be filtered and needs to be adjusted to each data set. To illustrate we compare 4 different values. For the sake of clarity, I will exclude code that constitutes simple repetition of data treatment or plotting.

```
source("mirrorbound.r") # Boundary condition routine
source("statfilt.r") # Mean and median filters
filt_data1 <- statfilt(sa_data$IRLTLT01ZAM156N, 10, 1) #Applies the mean filter
filt_data2 <- statfilt(sa_data$IRLTLT01ZAM156N, 50, 1) 
filt_data3 <- statfilt(sa_data$IRLTLT01ZAM156N, 150, 1) 
filt_data4 <- statfilt(sa_data$IRLTLT01ZAM156N, 500, 1)

plot(sa_data$IRLTLT01ZAM156N, col =  "blue", type = "l", main = "Kernel size 10", ylab = "Percent", xlab = "Month") #Plots original data
points(filt_data1[,2], col = "red", pch = 16, type = "l")
```

![plot3](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/3.png)

Kernel size 150 seems to represent the trend quite well. Let's see what the data looks like without the trend.

```
plot(filt_data3[,1], main = "LT Government Bond Yields, South Africa, 1960-2018, trend subtracted", col =  "blue", type = "l", ylab = "Percent", xlab = "Month") #Plots data set with trend subtracted
abline(a = 0, b = 0, col = "red")
```

![plot4](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/4.png)

Let's try the second data set to see how the mean filter handles baseline correction. Here, I will just use a kernel size of "".

```
filt_data <- statfilt(int_data[,3], 15, 1) 
plot(int_data[,3], col =  "blue", type = "l",
     main = "Flourescence intensity over time", ylab = "Intenstiy", xlab = "Time")
points(filt_data[,2], col = "red", pch = 16, type = "l") 
plot(filt_data[,1], col =  "blue", type = "l",
     main = "Flourescence intensity over time, trend subtracted", ylab = "Intenstiy", xlab = "Time")
abline(a = 0, b = 0, col = "red")
```
![plot5](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/5 .png)

Not a great approximation of the baseline. The mean filter has issues with with the large peaks from the smaller changes in the baseline. Also, since the peaks are closely spaced, they influence the mean enough to inflate the baseline, which results in the corrected curve not having its base at zero. 
Side note: There exists a wealth of different linear filters with varying characteristics, which may be of interest for these applications. The interested reader is encouraged to dig further.
