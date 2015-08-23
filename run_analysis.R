## This script does 
# - Merges the training and the test sets to create one data set.
# - Extracts only the measurements on the mean and standard deviation for each measurement. 
# - Uses descriptive activity names to name the activities in the data set
# - Appropriately labels the data set with descriptive variable names. 
# - From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.
# 

# Uncomment the section below to get a fresh source data online
# fileurl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
# if(!file.exists("./data")){dir.create("./data")}
# filedest = "./data/projectDataset.zip"
# download.file(fileurl,filedest,method="curl")
# unzip(filedest, exdir = "./data")

# Sets script varables accoding to your environment.
setwd("/Volumes/DATA/Data Science/Coursera/3 GettingAndCleaningData")
tidyDataDir = "./data/project/uch_activity.txt"
testData = "./data/project/test/X_test.txt"
testLabel = "./data/project/test/y_test.txt"
testSubject = "./data/project/test/subject_test.txt"
trainData = "./data/project/train/X_train.txt"
trainLabel = "./data/project/train/y_train.txt"
trainSubject = "./data/project/train/subject_train.txt"
activityLabel = "./data/project/activity_labels.txt"
features = "./data/project/features.txt"

# Loads data
library(data.table)
library(plyr)
library(dplyr)
library(reshape2)
activityLabel <-fread(activityLabel)
testLabel <- fread(testLabel)
trainLabel <- fread(trainLabel)
features <- fread(features)
testData<-read.table(testData)
testSubject <- read.table(testSubject)
trainData <- read.table(trainData)
trainSubject <- read.table(trainSubject)

# Appropriately labels the data set with descriptive variable names. 
features$V2 <- make.names(features$V2, unique = TRUE)
setnames(testData,old = names(testData), features$V2)
setnames(trainData,old = names(trainData), features$V2)

# Merges the training and the test sets to create one data set.
testData = cbind(testData, activity.code = testLabel$V1, subject.id = testSubject$V1)
trainData = cbind(trainData, activity.code = trainLabel$V1, subject.id = trainSubject$V1)
rawdata=rbind(testData,trainData)

# Extracts only the measurements on the mean and standard deviation
# mean: Mean value
# std: Standard deviation
meanStdData=cbind(select(rawdata, contains("mean")),select(rawdata, contains("std")),rawdata["subject.id"],rawdata["activity.code"])
# check there are no empty values meanStdData[!(complete.cases(meanStdData)),]

# Uses descriptive activity names to name the activities in the data set
activityLabel$V2 = make.names(activityLabel$V2, unique = TRUE)
setnames(activityLabel,names(activityLabel),c("activity.code", "activity")) 
meanStdData = join(meanStdData,activityLabel)

# Creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.
# 
dataMelt=melt(meanStdData,id=c("activity","subject.id"),measure.vars=names(meanStdData[,1:86]))
tidyData=dcast(dataMelt,subject.id+activity~variable,mean)
write.table(tidyData,file = tidyDataDir)

