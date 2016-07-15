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

##Citations
RPubs: 
Github: https://github.com/dannhek/income_distribution


Other citations....


