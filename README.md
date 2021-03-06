# R-trend-correct
4 methods for trend extraction or baseline correction using boundary conditions

For the sake of the discussion below, I make the claim that the terms "trend" and "baseline" often enough refer to the same phenomenon in practice, but with different underlying assumptions.
In the case of trend, we here mean the overall direction of change over time in a data set that may be important to the analysis, not considering changes of smaller orders of magnitude.
The baseline is here taken to be the background signal level (whichever shape it may have), from which we distinguish our signal of interest. Changes in the baseline (due to experimental artifacts or other factors) are thus often at best not interesting or, worse, impede analysis.
What both cases have in common though, is that we need to separate the trend or baseline from the rest of the data before we can perform further analysis. Below, I will present 4 different approaches to separate the trend or baseline from the rest of the data, all with different pros and cons. For the sake of space, I won't be discussing these approaches in great detail (especially not their mathematical foundations, as they are adequately described elsewhere), but rather give some pointers as to their respective applications. At times where I think it benefits the discussion though, I will include references to more in depth treatments.
Disclaimer 1: As always, the more we know about our data (signal characteristics, noise frequencies, sampling procedure etc), the better informed our choice of processing approach will be. Thus, automatic trend extraction or baseline correction will often fall short for some types of data, while working well on others.
Disclaimer 2: I will not cover the related problem of trend detection, i.e. determining whether or not a statistically significant trend exists in the data set.
The approaches I will cover here are: mean filter, median filter, polynomial interpolation and the morphological tophat.
Side note: all 4 approaches require boundary conditions, meaning some way of handling the beginning and end of the data set. I picked "mirror" boundary conditions, which I briefly discuss [here](https://github.com/jonas-raposinha/R-mirrorbound).

Firstly, let's look at two different data sets. The first one is South African Long-Term Government Bond Yields between Jan 1960 and Jan 2018, from the [Federal Reserve Economic Data, St Louis](https://fred.stlouisfed.org/).

```R
sa_data <- read.table("sa_lt_govt_bond_yields.csv", sep = ",", header = T)
plot(sa_data$IRLTLT01ZAM156N, type = "l", main = "LT Government Bond Yields, South Africa, 1960-2018", ylab = "Percent", xlab = "Month")
```

![plot1](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/1.png)

The second one is (slightly altered) experimental data on fluorescence intensity over time with a varying baseline. Our interest in this case is the intensity peaks.

```R
int_data <- read.table("peaks_test.csv", sep = ";", dec = ",")
plot(int_data$V3, main = "Fluorescence intensity over time", ylab = "Intensity (a.u.)", xlab = "Time (s)")
```

![plot2](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/2.png)

Next, we go through the approaches one by one, starting with the mean filter (aka "moving average" or "blurring"). This is a simple, linear low-pass filter that turns each data point into the mean of itself and its neighbours. The size of the neighbourhood considered (ie the filter kernel size) decides how rapid changes will be filtered and needs to be adjusted to each data set. To illustrate we compare 4 different values. For the sake of clarity, code that constitutes simple repetition of data treatment or plotting will be excluded, and axis labels in the tile plots removed.

```R
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

```R
plot(filt_data3[,1], main = "LT Government Bond Yields, South Africa, 1960-2018, trend subtracted", col =  "blue", type = "l", ylab = "Percent", xlab = "Month") #Plots data set with trend subtracted
abline(a = 0, b = 0, col = "red")
```

![plot4](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/4.png)

Let's try the second data set to see how the mean filter handles baseline correction. Here, I will just use a kernel size of 15.

```R
filt_data <- statfilt(int_data[,3], 15, 1) 
plot(int_data[,3], col =  "blue", type = "l",
     main = "Fluorescence intensity over time", ylab = "Intenstiy", xlab = "Time")
points(filt_data[,2], col = "red", pch = 16, type = "l") 
plot(filt_data[,1], col =  "blue", type = "l",
     main = "Fluorescence intensity over time, trend subtracted", ylab = "Intenstiy", xlab = "Time")
abline(a = 0, b = 0, col = "red")
```
![plot5](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/5.png)

Not a great approximation of the baseline. The mean filter has issues with separating the large peaks from the smaller changes in the baseline. Also, since the peaks are closely spaced, they influence the mean enough to inflate the baseline, which results in the corrected curve not having its base at zero. 
Side note: There exists a wealth of different linear filters with varying characteristics, which may be of interest for these applications. The interested reader is encouraged to dig further.


Let's compare with the non-linear median filter that operates in a similar way to the mean filter, but instead replaces each data point with the median of itself and its neighbours. Since the median value is unaffected by transient changes, we will see that these are replaced by distinctive plateaus, as compared to the smoother curves produced by the mean filter.

```R
filt_data <- statfilt(int_data[,3], 15, 2) # Applies the median filter
plot(int_data[,3], col =  "blue", type = "l",
     main = "Fluorescence intensity over time", ylab = "Intenstiy", xlab = "Time")
points(filt_data[,2], col = "red", pch = 16, type = "l") 
plot(filt_data[,1], col =  "blue", type = "l", 
     main = "Fluorescence intensity over time, baseline subtracted", ylab = "Intenstiy", xlab = "Time")
abline(a = 0, b = 0, col = "red")
```

![plot6](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/6.png)

The baseline correction is clearly better than above (effectively centring the baseline around zero), although there are still difficulties in distinguishing some elements. Also, the last peak is clipped relative to the others, even at an "optimal" filter size. What about the trend extraction? 

```R
filt_data1 <- statfilt(sa_data$IRLTLT01ZAM156N, 10, 2)
filt_data2 <- statfilt(sa_data$IRLTLT01ZAM156N, 50, 2) 
filt_data3 <- statfilt(sa_data$IRLTLT01ZAM156N, 150, 2) 
filt_data4 <- statfilt(sa_data$IRLTLT01ZAM156N, 500, 2)

plot(sa_data$IRLTLT01ZAM156N, col =  "blue", type = "l", lwd = 2,
     main = "Median, kernel size 10", cex.main = 3, ylab = "", xlab = "", xaxt = 'n', yaxt = "n")
points(filt_data1[,2], col = "red", pch = 16, type = "l", lwd = 2)
```

![plot7](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/7.png)

Here, the median filter performance is closer to that of the mean. It does perhaps not catch the shape of the curve quite as nicely, but fares slightly better in regions with large variation.
A nice discussion on median filters (for image processing, which I find sometimes makes for more pedagogical presentations) can be found in [(Peng, Seminar report, 2004)](http://www.massey.ac.nz/~mjjohnso/notes/59731/presentations/Adaptive%20Median%20Filtering.doc)


Next, we turn to polynomial interpolation, in which a polynomial is fitted to the data set according to certain criteria. A common approach is to make iterations of interpolation and baseline/trend subtraction until a satisfactory result is reached, as described in [(Gan et al, Chemometrics Intel. Lab. Sys., 2006)](https://doi.org/10.1016/j.chemolab.2005.08.009).
We compare two different degrees of polynomials to see how it handles trend extraction and baseline correction.

```R
source("polycorrect.r")
filt_data1 <- polycorrect(sa_data$IRLTLT01ZAM156N, 8) # Applies the iterative interpolation
filt_data2 <- polycorrect(sa_data$IRLTLT01ZAM156N, 16)

plot(sa_data$IRLTLT01ZAM156N, col =  "blue", type = "l", lwd = 2,
     main = "Polynomial, 8th degree", cex.main = 3, ylab = "", xlab = "", xaxt = 'n', yaxt = "n") #Plots original data
points(filt_data1[,2], col = "red", pch = 16, type = "l", lwd = 2) #Plots the extracted trend in red
```

![plot8](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/8.png)

Firstly, this approach produces beautifully smooth curves, since they are based on polynomials. We can also observe what is sometimes a significant drawback of this approach though, termed Runge's phenomenon, i.e. oscillations at the edges produced by high order polynomials. This is annoying since those are typically needed to fit complex data, as seen when comparing the two examples above. 

To solve this, we can use interpolating splines (piecewise interpolation of lower degree polynomials, typically cubic). Fortunately, R has an implementation of smoothing splines, which differ from regular splines by a roughness penalty, typically based on the second derivative of the data set. The interested reader is also referred to more advanced splines-based methods, e.g. the Hodrick-Prescott filter.

```R
filt_data <- smooth.spline(sa_data$IRLTLT01ZAM156N, spar = 0.7) #cubic smoothing splines
plot(sa_data$IRLTLT01ZAM156N, col =  "blue", type = "l", lwd = 2)
points(filt_data, col = "red", pch = 16, cex = 0.4)
```

![plot9](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/12.png)

Let's briefly look at baseline correction using interative interpolation or smoothing splines as well.

```R
filt_data1 <- polycorrect(int_data$V3, 4)
filt_data2 <- polycorrect(int_data$V3, 9)
filt_data3 <- polycorrect(int_data$V3, 18)
filt_data4 <- smooth.spline(int_data$V3, spar = 0.7)

plot(int_data$V3, col =  "blue", type = "l", lwd = 2,
     main = "Polynomial, 9th degree", cex.main = 3, ylab = "", xlab = "", xaxt = 'n', yaxt = "n") #Plots original data
points(filt_data1[,2], col = "red", pch = 16, type = "l", lwd = 2) #Plots the extracted trend in red
plot(int_data$V3, col =  "blue", type = "l", main = "Splines, spar = 0.7", lwd = 2, cex.main = 3, ylab = "", xlab = "", xaxt = 'n', yaxt = "n")
points(filt_data4, col = "red", type = "l", lwd = 2)
```
![plot10](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/ip2x2.png)

The iterative interpolation does a decent job with an 9th degree polynomial, although it has issues with sharp changes.
Of note is that while the smoothing splines manage to model the baseline shape quite well, they, similarly to the mean filter, fail to trace its level and will thus not bring it down to zero.

Side note 1: There are several more or less advanced polynomial interpolation-based methods that the interested reader may want to look into, one being the recently published Goldindec algorithm [(Liu et al, Appl Spectrosc, 2015)](http://dx.doi.org/10.1366/14-07798).

Side note 2: It's of course possible to fit of other kinds of mathematical expressions than polynomials. This is more common in image feature extraction and examples include exponential and hyperbolic expressions [(Yan et al, Sensor Mater, 2012)](http://myukk.org/SM2017/sm_pdf/SM869.pdf), and parabolas and power expressions [(Kumar et al, Natl Acad Sci Lett, 2014)](https://doi.org/10.1007/s40009-014-0253-4).

The fourth approach, the Tophat, is an operator in mathematical morphology that is again mainly used for image feature extraction and segmentation (eg to correct for nonuniform lighting conditions), but has been implemented for one-dimensional trend correction, e.g. by [(Breen et al, Electrophoresis, 2000)](https://doi.org/10.1002/1522-2683(20000601)21:11<2243::AID-ELPS2243>3.0.CO;2-K) and [(Sauve & Speed, Procedings Gensips, 2004](https://pdfs.semanticscholar.org/c04c/afc9b2670edd1ea38f0f724cadbe2ec321e9.pdf). 
Without entering into too much detail, mathematical morphology deals with geometrical structures, by means of probing them with a simple shape, the "structuring element" (which in 1-d signal processing becomes analogous to the filter size, as discussed for mean and median filters above). For those further interested, the Tophat is defined as the difference between the input data and its morphological opening (which in turn is the dilation of the erosion of the data).

```R
source("morphcorrect.r")
filt_data1 <- morphcorrect(int_data$V3, 5) # Applies the Tophat
filt_data2 <- morphcorrect(int_data$V3, 10) 
filt_data3 <- morphcorrect(int_data$V3, 30) 

plot(int_data$V3, col =  "blue", type = "l", lwd = 2,
     main = "Tophat, se size 5", cex.main = 3, ylab = "", xlab = "", xaxt = 'n', yaxt = "n") #Plots original data
points(filt_data1[,2], col = "red", pch = 16, type = "l", lwd = 2) #Plots the extracted trend in red
plot(filt_data2[,1], col =  "blue", type = "l", 
     main = "Intensity over time, baseline corrected", xlab = "Time", ylab = "Intensity",
     lwd = 2, cex.main = 3, cex.lab = 2, cex.axis = 2)
abline(a = 0, b = 0, col = "red", lwd = 2)
```

![plot11](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/11.png)

The Tophat does an excellent job with separating the peaks from the baseline once we find a good size structuring element. 

```R
filt_data1 <- morphcorrect(sa_data$IRLTLT01ZAM156N, 10) 
filt_data2 <- morphcorrect(sa_data$IRLTLT01ZAM156N, 40) 
filt_data3 <- morphcorrect(sa_data$IRLTLT01ZAM156N, 120) 
filt_data4 <- morphcorrect(sa_data$IRLTLT01ZAM156N, 300)

plot(sa_data$IRLTLT01ZAM156N, col =  "blue", type = "l", lwd = 2,
     main = "Tophat, se size 10", cex.main = 3, ylab = "", xlab = "", xaxt = 'n', yaxt = "n")
points(filt_data1[,2], col = "red", pch = 16, type = "l", lwd = 2)
```

![plot12](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/10.png)

Trend extraction is less successful in this data set. Especially the region with large variation is not well represented. It's possible to think of morphological filters that would potentially do a better job at this, but that again is outside of the present discussion.

Finally, let's time the different approaches. To be able to see any difference, we use a slightly larger data set containing [daily air temperatures recorded in Stockholm, Sweden](https://bolin.su.se/data/stockholm/), between the years 1756 and 2017, containing 95694 observations.

```R
system.time(statfilt(temp_data$V4, 14, 1)) # Mean
 user  system elapsed 
 1.18    0.01    1.20 
system.time(statfilt(temp_data$V4, 14, 2)) # Median
 user  system elapsed 
 4.40    0.00    4.43 
system.time(polycorrect(na.omit(temp_data$V4), 8)) # Iterative polynomial interpolation
 user  system elapsed
 53.88   14.54   68.91
system.time(morphcorrect(temp_data$V4, 14)) # Tophat
 user  system elapsed 
 0.52    0.00    0.52 
system.time(smooth.spline(na.omit(temp_data$V4), spar = 0.7)) # Smoothing splines
 user  system elapsed 
 0.11    0.00    0.11 
```

Out of the 4 approaches implemented, the Tophat wins this round, although the differences are not that big, except for the iterative polynomial interpolation. That comparison is a bit unfare though since the iterations are implemented using a normal R loop, but still, iterative approaches in general are slow. Thankfully, the smoothing splines do not have this issue and are even faster than the Tophat.

I hope that this provided more clarification than confusion and wish you good luck with your trends and baselines!
