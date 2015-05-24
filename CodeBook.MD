---
title: "CodeBook"
author: "Amisha Bhanage"
date: "Saturday, May 23, 2015"
output: html_document
---


```{r}
summary(cars)
```

You can also embed plots, for example:

```{r, echo=FALSE}
plot(cars)
```

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.


# Code Book: Getting and Cleaning Data Course Project 

## The original data set

The original data set is downloaded from [UCI repository](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) and copied to ./UCI HAR Dataset/ folder

The original data set is randomly split into training and test sets (70% and 30%, respectively) where each partition is also split into three files that contain

- measurements from the accelerometer and gyroscope (x_test.txt and y_train.txt)
- activity ID (y_test.tx and y_train.txt)
- identifier of the subject (subject_test.txt and subject_train.txt)

Note that the y data contains a ID associated with the activity performed for each row in the x data. The subject data identifies the participant in each row of the x data.

The Original data set also came with master data for Activities (activity_labels.txt) and Features (features.txt) . Each subject performed 6 activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) and 561 features were obtained by calculating variables from the time and frequency domain.

## run_analysis.R 

The first step of the preprocessing is to merge the training and test sets. Two sets combined, there are 10,299 instances where each instance contains 561 features (560 measurements and subject identifier). After the merge operation the resulting data, the table contains 562 columns (560 measurements, subject identifier and activity label).

After the merge operation, mean and standard deviation features are extracted for further processing. Out of 560 measurement features, 33 mean and 33 standard deviations features are extracted, yielding a data frame with 68 features (additional two features are subject identifier and activity label).

Next, the activity labels are replaced with descriptive activity names, defined in activity_labels.txt in the original data folder.

The final step creates a tidy data set with the average of each variable for each activity and each subject. 10299 instances are split into 180 groups (30 subjects and 6 activities) and 66 mean and standard deviation features are averaged for each group. The resulting data table has 180 rows and 66 columns. The tidy data set is exported to UCI_HAR_tidy.csv where the first row is the header containing the names for each column.
