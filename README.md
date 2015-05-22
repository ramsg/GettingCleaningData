# Readme file for Getting and Cleaning Data Course Project

## Description

The requirements are:

 #1 Merges the training and the test sets to create one data set.
 
 #2 Extracts only the measurements on the mean and standard deviation for each measurement
 
 #3 Uses descriptive activity names to name the activities in the data set
 
 #4 Appropriately labels the data set with descriptive activity names. 
 
 #5 Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
 

### Step1
#### Read Data from the dir 

 Load the needed libraries *dplyr, reshape2 and tidyr*
 
 Read the test data into three data tables, do the same for training data. Here the assumption is that we are in the Samsung Dat dir "UCI HAR Dataset"
 
 Read activities and features description to its own tables, these will be used later for descriptive names in Step#3 for activities and descriptive column names in **Step#4**
 
```r 
Xtest <- tbl_df(read.table("test/X_test.txt", row.names=NULL))
Ytest <- read.table("test/y_test.txt", row.names=NULL)
S_test <-read.table("test//subject_test.txt")
        
Xtrain <- tbl_df(read.table("train//X_train.txt"))
S_train <- read.table("train//subject_train.txt")
Ytrain <- read.table("train//y_train.txt")
                
activity_lables <- read.table("activity_labels.txt")
        
features <- read.table("features.txt")
```
 
#### Merge the data to single table
 Next, use function rbind to merge the test and training data.
 
 Add the lables to the merged data from column2 of the features tables.
 Add two new columns Activity.Type and Subject to the mergedData and fill in the data from the previously created tables. 
 
 Now the data from both test and training data sets are menrged to one single table **mergedData**
```r
mergedData <- rbind(Xtest,Xtrain)
mergedY <- rbind(Ytest, Ytrain)
mergedS <- rbind(S_test, S_train)
        
colnames(mergedData) <- features[,2]
colnames(activity_lables) <- c("Activity.Type","Activity.Description")
        
mergedData$Activity.Type <- as.numeric(mergedY$V1)
mergedData$Subject <- as.numeric(mergedS$V1)
```


###Step2

#### Extract the mean and standard deviation measurements

Use grepl function to search for mean(), std(), activity.type and subject 
in the column lables and use only those columns and create a new dataset 
called **mean_std**

Don't forget to Add in the two colums from mergedData
```r
mean_std <- mergedData[,grepl("(mean\\(\\)|std\\(\\)|Activity\\.Type|Subject)", colnames(mergedData))]

```

### Step3 and Step4 

Create a new temprary variable **x** to merge the activities and column names

```r
x<-merge(mean_std, activity_lables, by="Activity.Type")
x <- x[,c(1,68,69,2:67)]
colNames <- colnames(x)
colNames <- gsub("-mean()","Mean",colNames,fixed=TRUE)
colNames <- gsub("-std()","Std",colNames,fixed=TRUE)
colNames <- gsub("BodyBody","Body",colNames,fixed=TRUE)
colnames(x) <- colNames
```


#### Melt the data and cast it to the nice tidy table with mean for every subject and for each activity in a separate row.

Perform the melt on Subject, activity.type and description, this will create for each subject and each activity a separate row for each measurement.

Cast it back to a table and apply mean for each of the activity type. For each subject we have mean measurements for each of the 6 activites . For 30 Subjects and 6 Activities we have 180 rows of observation


Finally write the data to a tidy file so we can read it back later.

```r
meltedData <- melt(x, id=c("Subject","Activity.Type","Activity.Description"))

tidyData <- dcast(meltedData, 
                  formula = Subject+Activity.Type+Activity.Description 
                  ~ variable, mean)

write.table(tidyData, file="tidyData.txt", row.names=FALSE)
```
