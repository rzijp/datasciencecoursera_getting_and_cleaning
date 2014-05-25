README
========================================================

This repo contains 2 R-scripts (whose workings are documented in comments in the scripts themselves, not repeated here):
- **load_data.R** will download the Samsung data and unzip it in the current working directory. If the data has already been downloaded before, the script will skip the download, and likewise for the unzipping.
- **run_analysis.R** will read the downloaded data and create a tidied up data sets from it, as described in the assignment.

Dependencies: In order to run successfully:
- Change the **path to the working directory** in line 17 of run_analysis.R to the value applicable to your local workstation.
- run_analysis.R depends on the libraries **plyr** and and **reshape2**. If these have not been installed, run the commands 

```{r}
install.packages(c('plyr', 'reshape2'))
```

After running run_analysis.R, there will be 2 .txt-files:
- **tidy1.txt** contains the tidied data set that is the result of steps 1-4, so this will contain 10299 rows.
- **tidy2.txt** contains the smaller tidied data set that is the result of step 5 and will have 180 rows.