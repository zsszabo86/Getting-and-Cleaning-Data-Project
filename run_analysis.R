# This script
  # Merges the training and the test sets to create one data set.
  # Extracts only the measurements on the mean and standard deviation for each measurement. 
  # Uses descriptive activity names to name the activities in the data set
  # Appropriately labels the data set with descriptive variable names. 
  # From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(dplyr)
rm(list=ls())

# fetch column header
features<-read.table("./UCI HAR Dataset/features.txt")

# we want to retain all the XXXXmean() and XXXXstd() measures. first fetch the column indeces.
columnIdx <- sort(c(grep(".*mean\\(\\).*",features$V2), grep(".*std\\(\\).*",features$V2)))

# fetch x data
xTest  <- read.table("./UCI HAR Dataset/test/X_test.txt")
xTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")

# filter out the columns we are interested in. 
xTest  <- xTest[ , columnIdx]
xTrain <- xTrain[ , columnIdx]

# name the column headers given as in features.txt
names(xTest) <- features$V2[columnIdx]
names(xTrain) <- features$V2[columnIdx]

# add subject id 
subjectTest <-read.table("./UCI HAR Dataset/test/subject_test.txt")
subjectTrain<-read.table("./UCI HAR Dataset/train/subject_train.txt")
xTest$subjectId <- subjectTest$V1
xTrain$subjectId <- subjectTrain$V1

# add activity data
yTest <- read.table("./UCI HAR Dataset/test/y_test.txt")
names(yTest) <- c('code')
yTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
names(yTrain) <- c('code')
activityLabels<-read.table("./UCI HAR Dataset/activity_labels.txt")
names(activityLabels) <- c('code', 'description')
activityTest  <- left_join(yTest,activityLabels,by='code')
activityTrain <- left_join(yTrain,activityLabels,by='code')
xTest$activity  <- activityTest$description 
xTrain$activity <- activityTrain$description

# combine test and train datasets into one data frame
acc_data_meanandstd <- rbind(xTest,xTrain)

# get the summary of the dataset grouped by the subject and the type of activity
summary <- acc_data_meanandstd              %>% 
           group_by(subjectId, activity)    %>%
           summarise_each(c('mean'))

# save the new summary tidy dataset into a txt file
write.table(summary,file='meansOfMeasuresBySubjectActivity.txt', row.names=FALSE, col.names=TRUE, sep='\t')