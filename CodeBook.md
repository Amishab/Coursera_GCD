---
title: "CodeBook"
author: "Amisha Bhanage"
date: "Saturday, May 23, 2015"
output: html_document
---
## Code Book: Getting and Cleaning Data Course Project 

### The original data set

The original data set is downloaded from [UCI repository](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) and copied to ./UCI HAR Dataset/ folder

The original data set is randomly split into training and test sets (70% and 30%, respectively) where each partition is also split into three files that contain

- measurements from the accelerometer and gyroscope (x_test.txt and y_train.txt)
- activity ID (y_test.tx and y_train.txt)
- identifier of the subject (subject_test.txt and subject_train.txt)

Note that the y data contains a ID associated with the activity performed for each row in the x data. The subject data identifies the participant in each row of the x data.

The Original data set also came with master data for Activities (activity_labels.txt) and Features (features.txt) . Each subject performed 6 activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) and 561 features were obtained by calculating variables from the time and frequency domain.

### run_analysis.R 

The first step was reading data from all the files provided and attaching libraries needed for the code. Then renamed column names for all data loaded in R data frames.

Added a column to subject data frames viz. Train_Subject_Seq and Test_Subject_Seq that assigns sequence number to trials for each participant. This is needed to recast the tables during merge. Transformation for the columns are as under: 
```{r evaluate=F}
train_subj_seq <- apply(table(train_subj), 1,function(x) seq(1,x,by=1))
train_subj <- cbind(Train_Subject_Seq=as.vector(unlist(train_subj_seq)), train_subj)

test_subj_seq <- apply(table(test_subj), 1,function(x) seq(1,x,by=1))
test_subj <- cbind(Test_Subject_Seq=as.vector(unlist(test_subj_seq)),test_subj)
```
Added column names for X data set using feature names from feature.

Next, filter data which has measurements on the mean and standard deviation. 33 mean and 33 standard deviations features are extracted, yielding a data frame with 69 variables (additional three variables are subject identifier, activity label and 
additinal column added for Subject Sequence.
```{r evaluate=F}
# Determine the indices of mean() and std() entries.
featind <- which(grepl("mean\\(\\)",features$Feature_Name) | grepl("std\\(\\)", features$Feature_Name))

# create a table containing all test data containing only 
# the measurements on the mean and standard deviation for each measurement
test <- cbind(test_subj, ytest, xtest[,featind])

# create a table containing all train data containing only 
# the measurements on the mean and standard deviation for each measurement
train <- cbind(train_subj, ytrain, xtrain[,featind])
```
Next, the activity labels are replaced with descriptive activity names, defined in activity_labels.txt in the original data folder.
```{r evaluate=F}
# Replace activity IDs with activity names
for (i in activities$Activity_ID){
  test$Activity_ID[which(test$Activity_ID == i)] <- activities$Activity_Name[i]
  train$Activity_ID[which(train$Activity_ID == i)] <- activities$Activity_Name[i]
  print(i)
  print(activities$Activity_Name[i])
}
```
Then melted the train and test data based on Subject ID and subject sequence number
```{r evaluate=F}
meltedTest <- melt(test, id=c("Test_Subject_Seq","Subject_ID"))
meltedTrain <- melt(train, id=c("Train_Subject_Seq","Subject_ID"))
```
Then merged the two melted data frames using rbind. dcast the merged data gives the final tidy data (10299 obs. of 69 variables) which is written to the pipe-delimited text file named `GCD_Project_tidy_data.txt`

The final step creates a tidy data set calculating mean of each variable for each activity and each subject. 10299 observations from tidy data set are split into 180 groups (30 subjects and 6 activities) and 66 mean and standard deviation features are averaged for each group. We dropped the column subject sequence created for merging data. The resulting data table has 180 rows and 68 columns. The tidy data set is exported to pipe-delimited text file named `GCD_Project_tidy_data_means.txt` where the first row is the header containing the names for each column.
