setwd('/home/robbert/Coursera/140407 Data Science track/03 Getting and Cleaning Data/course project/')

# If the ZIP has not been downloaded yet, do so
if(!file.exists('data.zip')) {
    fileURL <- 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
    download.file(fileURL, destfile='data.zip',method='curl')
}
# If the zip has not been unzipped yet, do so
if(!file.exists('UCI HAR Dataset/')) {
    unzip('data.zip')
}

# Check pressence of UCI HAR Dataset/train/X_train.txt
if(file.exists('UCI HAR Dataset/train/X_train.txt')) {
    print("File downloaded and unzipped successfully")
}
