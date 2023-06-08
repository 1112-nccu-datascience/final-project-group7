args = commandArgs(trailingOnly=TRUE)

#print((args))
if (length(args)==0) {
  stop("USAGE: Rscript  smote_F1_score_with_not_target.R --input selection_data.csv --output F1_score_with_not_target.csv ", call.=FALSE)
}

# parse parameters
i<- 1 
while(i < length(args))
{
  if(args[i] == "--input"){
    input_f<-args[i+1]
    i<-i+1
  }else if(args[i] == "--output"){
    output_f<-args[i+1]
    i<-i+1
  }
  i<-i+1
}

print(paste("input file:", input_f))
print(paste("output file:", output_f))



# 导入数据
df1 <- read.csv(input_f)
# 固定隨機種子碼
set.seed(124)
# 檢查每個欄位的值是否相同
same_values <- sapply(df1, function(x) length(unique(x)) == 1)
# 移除相同值的欄位
df2<- df1[, !same_values]

#包含NOT target(由此切換)
###########                      
#data1<- df2[, -which(names(df1) %in% c("entry.no", "MS1scan.no", "MS1Isolation.mass","MS1monoIsomass","chargeState","in..H..","MS2.Scan.no"))]
########### 
library(dplyr)
df2<- df2[, -which(names(df1) %in% c("entry.no", "MS1scan.no", "MS1Isolation.mass","MS1monoIsomass","chargeState","in..H..","MS2.Scan.no"))]

#df3 <- subset(df2, !grepl("Not target", Structure))

#df3 <- df3 %>%
#  filter(!grepl("Not target", Structure))
###################################################
df4 <- subset(df2, !grepl("F2H7N4S1G1", Structure))

data1 <- df4 %>%
  filter(!grepl("F2H7N4S1G1", Structure))
summary(data1$Structure)
############################################################

# 将 "Structure" 列转换为因子类型
data1$Structure <- as.factor(data1$Structure)
# 获取原始因子级别的名称
factor_levels <- levels(data1$Structure)
# 将因子级别重新编码为 1 到 11(含not target有12筆)
levels(data1$Structure) <- 1:length(factor_levels)
# 创建一个对照表，将因子类型映射到原始类别
mapping_table <- data.frame(Structure_Type = 1:length(factor_levels), Original_Category = factor_levels)
# 打印对照表
print(mapping_table)
# 查看修改后的 "Structure" 列的摘要
summary(data1$Structure)

######################################
# Split the dataset into training and testing sets
train_indices <- sample(1:nrow(data1), 0.7 * nrow(data1))
train_data <- data1[train_indices, ]
test_data <- data1[-train_indices, ]
#str(train_data)
summary(train_data$Structure)

######################################
# 過採樣的train data
library(scutr)
dTrain.smote <- data.frame() 

for (i in 1:length(factor_levels)) {
  smote_cur <- oversample_smote(train_data, unique(train_data$Structure)[i],"Structure", 100)
  dTrain.smote <- rbind(dTrain.smote, smote_cur)
}
summary(dTrain.smote$Structure)
train_data <- dTrain.smote
###############################################################

formula <- Structure ~ .

#########################################################
library(rpart)
# Create the decision tree model
DT_model <- rpart(formula, data = train_data)

# Make predictions on the test set
predictions <- predict(DT_model, newdata = test_data)
# Convert predictions to class labels
predicted_classes <- apply(predictions, 1, which.max)
predicted_classes <- levels(factor(data1$Structure))[predicted_classes]
predicted_classes <- as.integer(predicted_classes)
predicted_classes <- factor(predicted_classes, levels = c(1:length(factor_levels)))
##############################################################
library(caret)
# Create a confusion matrix
confusion_matrix <- confusionMatrix(predicted_classes, test_data$Structure)

# Print the confusion matrix
print(confusion_matrix)
DTaccuracy <- confusion_matrix$overall["Accuracy"]
DTKappa <- confusion_matrix$overall["Kappa"]
DTf1 <- as.vector(confusion_matrix$byClass[, "F1"])


#########################################################
#randomforest
library(randomForest)
rf_model <- randomForest(formula, data = train_data, ntree = 100)

# Make predictions on the test set
rfpredictions <- predict(rf_model, newdata = test_data)

# Create a confusion matrix
confusion_matrix <- confusionMatrix(rfpredictions,test_data$Structure )

# Print the confusion matrix
print(confusion_matrix)
RFaccuracy <- confusion_matrix$overall["Accuracy"]
RFKappa <- confusion_matrix$overall["Kappa"]
RFf1 <- as.vector(confusion_matrix$byClass[, "F1"])

#########################################################
#knn
library(class)

k <- 5  # Number of neighbors
knnpredict <- knn(train = train_data[, -240], test = test_data[, -240], cl = train_data[, 240], k = k)

# Create a confusion matrix
confusion_matrix <- confusionMatrix(knnpredict,test_data$Structure )

# Print the confusion matrix
print(confusion_matrix)
knnaccuracy <- confusion_matrix$overall["Accuracy"]
knnKappa <- confusion_matrix$overall["Kappa"]
knnf1 <- as.vector(confusion_matrix$byClass[, "F1"])

#########################################################
library(e1071)
# Train the Naive Bayes model
nb_model <- naiveBayes(formula, data = train_data)

# Make predictions on the test set
nbpredictions <- predict(nb_model, newdata = test_data)

# Create a confusion matrix
confusion_matrix <- confusionMatrix(nbpredictions,test_data$Structure )

# Print the confusion matrix
print(confusion_matrix)
nbaccuracy <- confusion_matrix$overall["Accuracy"]
nbKappa <- confusion_matrix$overall["Kappa"]
nbf1 <- as.vector(confusion_matrix$byClass[, "F1"])

#as.vector(f1_score)
df<-rbind(DTf1,RFf1,knnf1,nbf1)
colnames(df) <- factor_levels
acc <- c(DTaccuracy,RFaccuracy,knnaccuracy,nbaccuracy)
Kappa <- c(DTKappa,RFKappa,knnKappa,nbKappa)
df<-cbind(df,acc,Kappa)
rownames(df) <- c("Decision_Tree","Random_Forest","KNN","Naive_Bayes")
write.csv(df, file=output_f, row.names = T, quote = F)
df
