# Set the workspce location
setwd("./UCI HAR Dataset/")

#load "plyr" package
library(plyr)

#load traninng and test data
trainData <- read.table("train/X_train.txt")
trainLabel <- read.table("train/Y_train.txt")
trainSubject <- read.table("train/subject_train.txt")
testData <- read.table("test/X_test.txt")
testLabel <- read.table("test/Y_test.txt")
testSubject <- read.table("test/subject_test.txt")
featureName <- read.table("features.txt")
activityLabel <- read.table("activity_labels.txt")

#merge training and test data
traintestData <- rbind(trainData,testData)

#assign the featureName to the merged data
colnames(traintestData) <- featureName$V2

#Extracts only the measurements on the mean and standard deviation for each measurement
colextracts <- grep("mean\\(\\)|std\\(\\)",names(traintestData))
dataextracts <- traintestData[,colextracts]

#Merge the labels of training and test data
traintestlabels <- rbind(trainLabel,testLabel)
colnames(traintestlabels) <- c("ActivityName")
traintestlabels <-merge(traintestlabels,activityLabel,by.x="ActivityName",by.y="V1")
colnames(traintestlabels) <- c("Activity","ActivityName")


#Merge the subjects of training and test data
traintestSubjects <- rbind(trainSubject,testSubject)
colnames(traintestSubjects) <- c("SubjectID")

#merge the labels and subjects to the data
allData <- cbind(traintestSubjects,traintestlabels,dataextracts)
allData <- allData[,c(1,3:length(allData))]

#Appropriately labels the data set with descriptive variable names
names(allData) <- gsub("Acc", "Accelerator", names(allData))
names(allData) <- gsub("Mag", "Magnitude", names(allData))
names(allData) <- gsub("Gyro", "Gyroscope", names(allData))
names(allData) <- gsub("^t", "time", names(allData))
names(allData) <- gsub("^f", "frequency", names(allData))

#creates a second, independent tidy data set with the average of each variable for each activity and each subject
tidyData <- ddply(allData, c("SubjectID", "ActivityName"), function (x) { 
        colMeans(x[3:length(allData)])
})

# Write tidyData.txt to file
write.table(tidyData, "TidyData.txt", row.names=FALSE)

# Write codeBook.md to file
cbContent = paste("* ", names(tidyData), sep="")
write.table(cbContent, file="CodeBook.md", quote=FALSE,
            row.names=FALSE, col.names=FALSE, sep="\t")