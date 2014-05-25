# Assigment description:
# You should create one R script called run_analysis.R that does the following. 
# 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each 
#    measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive activity names. 
# 5. Creates a second, independent tidy data set with the average of each 
#    variable for each activity and each subject. 
# 

# Initialization
# - Clear all variables and functions
rm(list=ls())
# - Set working directory
setwd('/home/robbert/Coursera/140407 Data Science track/03 Getting and Cleaning Data/course project/')


### Step 1. Merges the training and the test sets to create one data set.

# Load the data sets:
# - X_train and X_test contain 561 features, described in features.txt
# - y_train and y_test contain 1 column for the activity (walking, laying etc)
#   but values are in indicators 1-6, this will be fixed later
# - s_train and s_test contain 1 column with the subject (person)

X_train <- read.delim('UCI HAR Dataset/train/X_train.txt', 
                      sep="", colClasses=c("numeric"), header=FALSE)
y_train <- read.delim('UCI HAR Dataset/train/y_train.txt', sep="", 
                      colClasses=c("numeric"), header=FALSE)
s_train <- read.delim('UCI HAR Dataset/train/subject_train.txt', sep="", 
                      colClasses=c("numeric"), header=FALSE)
X_test  <- read.delim('UCI HAR Dataset/test/X_test.txt', sep="", 
                      colClasses=c("numeric"), header=FALSE)
y_test  <- read.delim('UCI HAR Dataset/test/y_test.txt', sep="", 
                      colClasses=c("numeric"), header=FALSE)
s_test  <- read.delim('UCI HAR Dataset/test/subject_test.txt', sep="", 
                      colClasses=c("numeric"), header=FALSE)

# Merge data sets by extending the X_??? data frames:
# - First by adding a partition column that indicates the origin of the data,
#   either training or test data. This is not strictly required by the exercise,
#   but I consider it good practice to not delete any data that might turn out
#   useful later on
X_train['partition'] <- factor('TRAIN')
X_test['partition']  <- factor('TEST')

# - Secondly by adding the activity and subject vectors 
X_train['activity']  <- y_train
X_train['subject']   <- s_train
X_test['activity']   <- y_test
X_test['subject']    <- s_test

# - Thirdly by merging the rows (rbind) of X_train and X_test into one big data
#   frame.
X_all <- rbind.data.frame(X_train, X_test)


### I'm combining steps 2-4:
###
### Step 2. Extracts only the measurements on the mean and standard deviation 
###         for each measurement. 
### 3. Uses descriptive activity names to name the activities in the data set
### 4. Appropriately labels the data set with descriptive activity names. 

# First, build the list of column names
# - Read the 561 features names from file, which will contain 2 variables: the 
#   row number and the feature name
features <- read.delim('UCI HAR Dataset/features.txt', sep=" ", header=FALSE, 
                       col.names=c("nr","name"), 
                       colClasses=c("integer","character"))

# - Select those feature names that contain -mean() or -std(). 
selFeatures <- features[grep(features$name, pattern="-(mean|std)\\(\\)"),]

# - Clean up illegal characters and weird names with a couple of replacements.
#   - Some features seem to have a typo with a double "Body"
selFeatures$name <- gsub(pattern="BodyBody",replacement="Body", 
                         selFeatures$name)
#   - brackets () get removed
selFeatures$name <- gsub(pattern="\\(\\)",replacement="", selFeatures$name)
#   - hyphens get replaced by underscores
selFeatures$name <- gsub(pattern="-",replacement="_", selFeatures$name)
#   - the t or f at the start of the feature name get extended to time or freq
selFeatures$name <- gsub(pattern="^t",replacement="time", selFeatures$name)
selFeatures$name <- gsub(pattern="^f",replacement="freq", selFeatures$name)
#   The column names that now remain are clear enough. I leave the capital 
#   letters (camelCase) in place as this makes the long variable names easier to
#   read.

# - Extend the list of select features with 3 additional column names for 
#   the partition, activity and subject
selFeatures <- rbind(c(563, "activity"),
                     c(564, "subject"),
                     selFeatures,
                     c(562, "partition"))

# Second, subset X_all for the features defined above
tidy <- X_all[,as.numeric(selFeatures$nr)]
# Now set the column names for the subset dat
colnames(tidy) <- selFeatures$name

# Third, improve the readability of the activity column by replacing the integer
# indicator 1-6 with a meaningfull description
# - Load the activity labels from disk
activityLabels <- read.delim('UCI HAR Dataset/activity_labels.txt', sep=" ", 
                             header=FALSE, 
                             col.names=c("activity","activityLabel"), 
                             colClasses=c("integer","character"))
# - Merge the tidy data set with the activity labels
tidy <- merge(tidy, activityLabels)
# - Move the activityLabels column (now in col 70) to the 4th column for a more 
#   consistent grouping of labels (first 3 columns), features (the rest), and 
#   the partition as last column
tidy <- tidy[, c(1:2, 70, 3:69)]
# - Sort by subject and activity (initial order of tidy might have changed due 
#   to merge action above)
library(plyr)
tidy <- arrange(tidy, subject, activity)
# - And remove the old 'activity' column
tidy <- subset(tidy, select = -activity)
# - Finally, write the tidy data set to disk (not prescribed by exercise, but I
#   consider it good practice)
write.table(tidy, "tidy1.txt",sep=";", row.names=FALSE)


### Step 5. Creates a second, independent tidy data set with the average of each 
###         variable for each activity and each subject. 

# - Load the reshape2 library for the melt and dcast functions
library(reshape2)
# - Melt the tidy data set, with the subject and activityLabel columns as 
#   identifiers, the rest of the columns will be repeated as variables.
#   Deselect the partition column, this should not be present in the final 
#   output
mtidy <- melt(subset(tidy, select=-partition),
              id.vars=c("subject","activityLabel"))
# - Cast the melted tidy data set, taking the mean of each combination of 
#   subject, activityLabel and the variable.
ctidy <- dcast(mtidy,subject + activityLabel ~ variable, fun.aggregate=mean)

# - Finally, write the casted tidy data set to the file 'tidy2.txt' 
write.table(ctidy, "tidy2.txt",sep=";", row.names=FALSE)
