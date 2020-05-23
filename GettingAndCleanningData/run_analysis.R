#######################################################################################################################
# The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set.
#
# Review criteria 
# The submitted data set is tidy.
# The Github repo contains the required scripts.
# GitHub contains a code book that modifies and updates the available codebooks with the data to indicate all 
#the variables and summaries calculated, along with units, and any other relevant information.
# The README that explains the analysis files is clear and understandable.
# The work submitted for this project is the work of the student who submitted it.

##### Getting and Cleaning Data Course Project 
#
#  The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. 
#
#  The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a 
# series of yes/no questions related to the project. You will be required to submit: 
#
# 1) a tidy data set as described below, 
# 2) a link to a Github repository with your script for performing the analysis, and 
# 3) a code book that describes the variables, the data, and any transformations or work that you performed to 
#    clean up the data called CodeBook.md. 
#  You should also include a README.md in the repo with your scripts. 
#  This repo explains how all of the scripts work and how they are connected.
#
#  One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:
#    
#    http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
#
#  Here are the data for the project:
#    
#    https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#
##### You should create one R script called run_analysis.R that does the following.
#
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
### Good luck!


### Loading Packages.
library(data.table)
library(reshape2)


### Getting the working directory
path <- getwd()

### Setting the url for downloading the Dataset.zip and unpack.
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(path, "Dataset.zip"))
unzip(zipfile = "Dataset.zip")

### Loading activity labels, features and mesurements.
activityLabels <- fread(file.path(path, "UCI HAR Dataset/activity_labels.txt"), col.names = c("classLabels", "activityName"))
features <- fread(file.path(path, "UCI HAR Dataset/features.txt"), col.names = c("index", "featureNames"))
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted, featureNames]
measurements <- gsub('[()]', '', measurements)

### Loading the train datasets and labeling cols properly.
train <- fread(file.path(path, "UCI HAR Dataset/train/X_train.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt"), col.names = c("Activity"))
trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt"), col.names = c("SubjectNum"))
train <- cbind(trainSubjects, trainActivities, train)

### Loading the test datasets and labeling cols properly.
test <- fread(file.path(path, "UCI HAR Dataset/test/X_test.txt"))[, featuresWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt"), col.names = c("Activity"))
testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt"), col.names = c("SubjectNum"))
test <- cbind(testSubjects, testActivities, test)

### merging datasets.
mergedDataset <- rbind(train, test)

### Naming properly the mergedDataset. 
mergedDataset[["Activity"]] <- factor(mergedDataset[, Activity], levels = activityLabels[["classLabels"]], labels = activityLabels[["activityName"]])
mergedDataset[["SubjectNum"]] <- as.factor(mergedDataset[, SubjectNum])
mergedDataset <- reshape2::melt(data = mergedDataset, id = c("SubjectNum", "Activity"))
mergedDataset <- reshape2::dcast(data = mergedDataset, SubjectNum + Activity ~ variable, fun.aggregate = mean)

### Writting the tidyData file.
data.table::fwrite(x = mergedDataset, file = "tidyData.txt", quote = FALSE)
