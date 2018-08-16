# R-trend-correct
4 methods for trend correction or analysis using boundary conditions

The terms "trend" and "baseline" can often enough refer to the same phenomenon in practice but with different underlying assumptions. In the case of trend, we mean the overall direction of change over time in a data set, not considering changes of smaller orders of magnitude, and may be important to the analysis. The baseline is usually taken to be the background signal level (whichever shape it may have) from which we distinguish our signal of interest. Changes in the baseline (due to experitmental artifacts or other factors) are thus often either not interesting or actually impede analysis. What both cases have in common though, is that we need to separate the trend or baseline from the rest of the data before we can perform further analysis.
Below, I will present 4 different approaches to do this, all with different pros and cons. I will not discuss these in great detail but give some pointers as to their respective applications. The approaches are: mean filter, median filter, polynomial interpolation and the morphological tophat.

Firstly, let's look at two different data sets. The first one is Long-Term Government Bond between Jan 1960 and Jan 2018, from the [Federal Reserve Economic Data, St Louis](ttps://fred.stlouisfed.org/).

```
sa_data <- read.table("sa_lt_govt_bond_yields.csv", sep = ",", header = T)
plot(sa_data$IRLTLT01ZAM156N, type = "l", main = "LT Government Bond Yields, South Africa, 1960-2018", ylab = "Percent", xlab = "Month")
```

[!plot1](https://github.com/jonas-raposinha/R-trend-correct/blob/master/images/01.png)

