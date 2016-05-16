# Income Distribution Over Time
This repo exists to support a project that stemmed from a friendly debate with my father-in-law. I want to understand how income distribution is changing over time. This project will pull Current Population Survey data to graph income distributions.  

After adjusting to a common inflation standard, I use R's GGPLOT package to take a density of the distribution, and then take the difference in densities over time. This creates a map of how the US income distribution is changing in 5 year increments.  

To Do and Document  

* Pull 1990, 1995, 2000, 2005, 2010, and 2015 CPS data into MySQL database.   
* Get BLS Inflation data    
* Pull CPS data into R  
* Graph Income Distribution (density)  
* Graph Difference in densities  
* Knitr Writeup and Economic interpretation.
