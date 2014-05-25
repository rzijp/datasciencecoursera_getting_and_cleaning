# Code Book
========================================================

After running run_analysis.R (as described in README.md), there will be 2 data sets, tidy1.txt and tidy2.txt.
The tidy1.txt file is the output of steps 1-4 of the exercise, tidy2.txt is the output of the 5th step.

Both files have the same set of column names, except for the very last column of tidy1.txt ('partition'), as this column is not present in tidy2.txt

## A decription of the columns:
- 1: **subject**: identifier of volunteer, values from 1-30
- 2: **activityLabel**: factor with values 
    - LAYING
    - SITTING
    - STANDING
    - WALKING
    - WALKING_DOWNSTAIRS
    - WALKING_UPSTAIRS 
- 3-68: **timeBodyAcc_mean_X** - **freqBodyGyroJerkMag_std**: features from original data, as described in './UCI HAR Dataset/features_info.txt'. For tidy1.txt the values in these columns are the original data points, for tidy2.txt the values have been averaged over all data points per subject and activityLabel.
- 69: **partition**: (only present in tidy1.txt) a factor indicating the origin of the data, either TRAIN or TEST.

## Cleaning process

### Initialization
- Clear all variables and functions
- Set working directory


### Step 1. Merges the training and the test sets to create one data set.

Load the data sets:
- X_train and X_test contain 561 features, described in features.txt
- y_train and y_test contain 1 column for the activity (walking, laying etc)
  but values are in indicators 1-6, this will be fixed later
- s_train and s_test contain 1 column with the subject (person)

Merge data sets by extending the X_??? data frames:
- First by adding a partition column that indicates the origin of the data,
  either training or test data. This is not strictly required by the exercise,
  but I consider it good practice to not delete any data that might turn out
  useful later on
- Secondly by adding the activity and subject vectors 
- Thirdly by merging the rows (rbind) of X_train and X_test into one big data
  frame.

### Steps 2-4 are combined:
#### 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
#### 3. Uses descriptive activity names to name the activities in the data set
#### 4. Appropriately labels the data set with descriptive activity names. 

First, build the list of column names
- Read the 561 features names from file, which will contain 2 variables: the 
  row number and the feature name
- Select those feature names that contain -mean() or -std(). 
- Clean up illegal characters and weird names with a couple of replacements.
  - Some features seem to have a typo with a double "Body"
  - brackets () get removed
  - hyphens get replaced by underscores
  - the t or f at the start of the feature name get extended to time or freq
- The column names that now remain are clear enough. I leave the capital 
  letters (camelCase) in place as this makes the long variable names easier to
  read.
- Extend the list of select features with 3 additional column names for 
  the partition, activity and subject

Second, subset X_all for the features defined above and set the column names for the subset data.

Third, improve the readability of the activity column by replacing the integer
indicator 1-6 with a meaningfull description
- Load the activity labels from disk
- Merge the tidy data set with the activity labels
- Move the activityLabels column (now in col 70) to the 4th column for a more 
  consistent grouping of labels (first 3 columns), features (the rest), and 
  the partition as last column
- Sort by subject and activity (initial order of tidy might have changed due 
  to merge action above)
- And remove the old 'activity' column
- Finally, write the tidy data set to disk as 'tidy1.txt' (not prescribed by exercise, but I
  consider it good practice)


### Step 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

- Load the reshape2 library for the melt and dcast functions
- Melt the tidy data set, with the subject and activityLabel columns as 
  identifiers, the rest of the columns will be repeated as variables.
- Deselect the partition column, this should not be present in the final 
  output
- Cast the melted tidy data set, taking the mean of each combination of 
  subject, activityLabel and the variable.
- Finally, write the casted tidy data set to the file 'tidy2.txt' 
