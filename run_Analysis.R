#Load the needed libraries

library(dplyr)
library(tidyr)
library(reshape2)


#Read the test data into three data tables 
Xtest <- tbl_df(read.table("test/X_test.txt", row.names=NULL))
Ytest <- read.table("test/y_test.txt", row.names=NULL)
S_test <-read.table("test//subject_test.txt")
        
#Read the training data into three data tables 
Xtrain <- tbl_df(read.table("train//X_train.txt"))
S_train <- read.table("train//subject_train.txt")
Ytrain <- read.table("train//y_train.txt")
                
#Read the Activity Description to activity_labels
activity_lables <- read.table("activity_labels.txt")
        
#Read the features Description to features variable
features <- read.table("features.txt")
        
#Merge the different tables
mergedData <- rbind(Xtest,Xtrain)
mergedY <- rbind(Ytest, Ytrain)
mergedS <- rbind(S_test, S_train)
        
#Get the column names from features table - column2
colnames(mergedData) <- features[,2]

# Make appropriate lables for activity table
colnames(activity_lables) <- c("Activity.Type","Activity.Description")
        
#Now merge the activities and the subject data with the Test+Training data
#Make appropriate column lables for Activity Type and Subject
# Step1 is assignment is complete with mergedData
mergedData$Activity.Type <- as.numeric(mergedY$V1)
mergedData$Subject <- as.numeric(mergedS$V1)

# Step2
#Now extract only the mean and std columns from the merged data set also activity and Subject

mean_std <- mergedData[,grepl("(mean\\(\\)|std\\(\\)|Activity\\.Type|Subject)", colnames(mergedData))]


#Step3 and Step4, column lables are descriptive.

# Use temp varibale 'x' to merge the table with activity table
x<-merge(mean_std, activity_lables, by="Activity.Type")

#Rearrange the columns to more readble order
x <- x[,c(1,68,69,2:67)]

#More beautification to make column names more readable
colNames <- colnames(x)
colNames <- gsub("-mean()","Mean",colNames,fixed=TRUE)
colNames <- gsub("-std()","Std",colNames,fixed=TRUE)
colNames <- gsub("BodyBody","Body",colNames,fixed=TRUE)

#Re set the column names to beautified lables :-)
colnames(x) <- colNames


#Step5
# Now use melt() function to get the values for each of the activities
meltedData <- melt(x, id=c("Subject","Activity.Type","Activity.Description"))


# Now get tidy data set with the 
# average of each variable for each activity and each subject.
tidyData <- dcast(meltedData, 
                  formula = Subject+Activity.Type+Activity.Description ~ variable, mean)

#Create a txt file using write.table to be uploaded to the assignment page
write.table(tidyData, file="tidyData.txt", row.names=FALSE)