library(reshape2)



## Downloading Data

filename<-"project_dataset.zip"

if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename)
}  
# I am using windows, so I could noy use the curl method

if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Reading files

activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels[,2] <- as.character(activity_labels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])


# Extracting mean and standard deviation

features_mean_std <- grep(".*mean.*|.*std.*", features[,2])
features_mean_std.names <- features[features_mean_std,2]
features_mean_std.names = gsub('-mean', 'Mean', features_mean_std.names)
features_mean_std.names = gsub('-std', 'Std', features_mean_std.names)
features_mean_std.names <- gsub('[-()]', '', features_mean_std.names)


# Loading train and test
train_x <- read.table("UCI HAR Dataset/train/X_train.txt")[features_mean_std]
train_y <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_subject <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(train_subject, train_y, train_x)

test_x <- read.table("UCI HAR Dataset/test/X_test.txt")[features_mean_std]
test_y <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_subject <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_subject, test_y, test_x)


# merge datas
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", features_mean_std.names)


# Tidy
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)

