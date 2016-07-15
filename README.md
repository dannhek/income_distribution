# Income Distribution Over Time
This repo exists to support a project that stemmed from a friendly debate with my father-in-law. I want to understand how income distribution is changing over time. This project will pull Current Population Survey data to graph income distributions.  

After adjusting to a common inflation standard, I use R's GGPLOT2 package to take a density of the distribution, and then take the difference in densities over time. This creates a map of how the US income distribution is changing in 5 year increments.  

##Structure of Files
This repo contains 4 main files:  

- BuildHHCSV.R - this file downloads CPS ASEC Data if needed, parses it, and then saves the fields I care about into a CSV File that gets saved to the working directory.
- hh compare years.R - this file is the real workhorse of the analysis. For performance and ease of use, it runs entirely on the CSV file generated in BuildHHCSV. 
- hhwagesalary.csv - data file built by BuildHHCSV and used by hh compare years.
- writeup.rmd - the final report writeup. It calls hh compare years using the R `source` command, but primarily contains text and only contains code needed for demonstration and explanation purposes.  

There is also a file with misc. tests and abandoned explorations (hh experimentation.R), but that file exists just to outsource my memory to my computer and isn't intended to add any value to the overall project.  

##Publications
RPubs: http://rpubs.com/tattooed_economist/income
Github: https://github.com/dannhek/income_distribution

##Citations
<a name="citation1">1</a>: US Census Bureau. (n.d.). Small Area Income and Poverty Estimates. Retrieved from [https://www.census.gov/did/www/saipe/data/model/info/cpsasec.html]  
<a name="citation2">2</a>: Damico, A. J. (2016) Curren Population Survey. ASDFree. Github Repository. [https://github.com/ajdamico/asdfree/tree/master/Current%20Population%20Survey]; commit c680eec92cbba64512d756e533696dedaa3d415e  
<a name="citation3">3</a>: [CPS Data Dictionary](https://www.census.gov/prod/techdoc/cps/cpsmar13.pdf)  
<a name="citation4">4</a>: Ryan, J. A.; Ulrich, J. M.; Thielen, W. (2015). Quantmod. CRAN Package. [https://cran.r-project.org/web/packages/quantmod/quantmod.pdf]  
<a name="citation5">5</a>: Burkhauser, R. (2012). Podcast interview with Russ Roberts. Retrieved from http://www.econtalk.org/archives/2012/04/burkhauser_on_t.html  
<a name="citation6">6</a>: Kochhar, R.; Fry, R.; Rohal, M. (2015). The American Middle Class is Losing Ground. Pew Research Center. Retrieved from http://www.pewsocialtrends.org/files/2015/12/2015-12-09_middle-class_FINAL-report.pdf  
<a name="citation7">7</a>: Planet Money. (2016). Episode 682: When CEO Pay Exploded. Retrieved from http://www.npr.org/sections/money/2016/02/05/465747726/-682-when-ceo-pay-exploded


