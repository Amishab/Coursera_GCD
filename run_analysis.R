# attach libraries

library(reshape2)


# Read the features.txt file

features <- read.table("./UCI HAR Dataset/features.txt", stringsAsFactors=F)

names(features) <- c("Feature_ID","Feature_Name")

head(features)


# Read the activities_labels file

activities <- read.table("./UCI HAR Dataset/activity_labels.txt", stringsAsFactors=F)

names(activities) <- c("Activity_ID","Activity_Name")

head(activities)


# Read test data

## Read test subject data

test_subj <- read.table("./UCI HAR Dataset/test/subject_test.txt")

names(test_subj) <- "Subject_ID"

head(test_subj)

# Create an additional column Subject_Type to indicate that subject was
# selected for generating the training data or the test data.

#len <- nrow(test_subj)
#test_subj_typ <- rep("Test", times = len)
#test_subj <- cbind(Subject_Type=as.vector(test_subj_typ),test_subj)

# Create an additional column Test_Subject_Seq that assigns sequence number to trials for
# each participant. This is used to recast the tables during merge.

test_subj_seq <- apply(table(test_subj), 1,function(x) seq(1,x,by=1))
test_subj <- cbind(Test_Subject_Seq=as.vector(unlist(test_subj_seq)),test_subj)

# Read x_Test data
xtest <- read.table("./UCI HAR Dataset/test/X_test.txt")

# Requirement 4: Appropriately labels the data set with descriptive variable names
names(xtest) <- features$Feature_Name
head(xtest,1)

# Read y_Test data
ytest <- read.table("./UCI HAR Dataset/test/y_test.txt")

# Requirement 4: Appropriately labels the data set with descriptive variable names
names(ytest) <- "Activity_ID"
head(ytest)

# Read train data

# Read Train subject data
train_subj <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# Requirement 4: Appropriately labels the data set with descriptive variable names
names(train_subj) <- "Subject_ID"
head(train_subj)

# Create an additional column Train_Subject_Seq that assigns sequence number to trials for
# each participant. This is used to recast the tables during merge.
train_subj_seq <- apply(table(train_subj), 1,function(x) seq(1,x,by=1))
train_subj <- cbind(Train_Subject_Seq=as.vector(unlist(train_subj_seq)), train_subj)

# Read x-Train data
xtrain <- read.table("./UCI HAR Dataset/train/X_train.txt")

# Requirement 4: Appropriately labels the data set with descriptive variable names
names(xtrain) <- features$Feature_Name

# Read y-Train data
ytrain <- read.table("./UCI HAR Dataset/train/y_train.txt")

# Requirement 4: Appropriately labels the data set with descriptive variable names
names(ytrain) <- "Activity_ID"

# Requirement 2: Extracts only the measurements on the mean and 
# standard deviation for each measurement

# Determine the indices of mean() and std() entries.
featind <- which(grepl("mean\\(\\)",features$Feature_Name) | grepl("std\\(\\)", features$Feature_Name))

# create a table containing all test data containing only 
# the measurements on the mean and standard deviation for each measurement
test <- cbind(test_subj, ytest, xtest[,featind])

# create a table containing all train data containing only 
# the measurements on the mean and standard deviation for each measurement
train <- cbind(train_subj, ytrain, xtrain[,featind])


#Requirement 3: Uses descriptive activity names to name the activities in the data set

# Replace activity IDs with activity names
for (i in activities$Activity_ID){
  test$Activity_ID[which(test$Activity_ID == i)] <- activities$Activity_Name[i]
  train$Activity_ID[which(train$Activity_ID == i)] <- activities$Activity_Name[i]
  print(i)
  print(activities$Activity_Name[i])
}

head(test)
head(train)

# Requirement 4: Appropriately labels the data set with descriptive variable names

#Rename column name from Activity_ID to Activity_Name
colnames(test)[3] <- "Activity_Name"
colnames(train)[3] <- "Activity_Name"

# Recast train and test need to be recast for merging (otherwise there it leads into
# inelegant column duplicates with NA values.)

# Melt the train and test data based on Subject ID and subject trial count.
meltedTest <- melt(test, id=c("Test_Subject_Seq","Subject_ID"))
meltedTrain <- melt(train, id=c("Train_Subject_Seq","Subject_ID"))

head(meltedTest)
head(meltedTrain)
 

# Requirement 1: Merge the training and the test sets to create one data set.

# Merge the two melted data sets into one using rbind. 
# Ensure column anmes are same in both datasets
colnames(meltedTrain)[1] <- "Subject_Seq"
colnames(meltedTest)[1] <- "Subject_Seq"
mergedData <- rbind(meltedTrain, meltedTest)


# Cast the data into a more user-friendly format.
tidyData <- dcast(mergedData, Subject_ID + Subject_Seq ~ variable, 
                  value.var="value")

head(tidyData)

# Requirement 5: From the data set in step 4, creates a second, 
# independent tidy data set with the average of each variable for each activity 
# and each subject.

# Melt the train and test data based on Subject ID and Activity_Name.
meltedTrain <- melt(train[,!(names(train)=="Train_Subject_Seq")], id=c("Subject_ID","Activity_Name"))
meltedTest <- melt(test[,!(names(test) =="Test_Subject_Seq")], id=c("Subject_ID","Activity_Name"))

head(meltedTest)
head(meltedTrain)

# Merge the two melted data sets into one using rbind.
mergedData <- rbind(meltedTrain, meltedTest)
mergedDataMeans <- dcast(mergedData, Subject_ID + Activity_Name~ variable, mean)
head(mergedDataMeans)

# Save the tidy data to file
fileName <- "./GCD_Project_tidy_data.txt"
write.table(tidyData, fileName, row.names=F, quote=F, sep="|")

# Save the tidy data Means to file
fileName <- "./GCD_Project_tidy_data_means.txt"
write.table(mergedDataMeans, fileName, row.names=F, quote=F, sep="|")
