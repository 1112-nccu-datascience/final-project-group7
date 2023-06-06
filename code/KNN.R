# 导入数据
df1 <- read.csv("C:/Users/User/Documents/BIOHW/output_name_nor_simple2.csv")
# Install and load required package
str(df1)
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

df3 <- subset(df2, !grepl("Not target", Structure))

df3 <- df3 %>%
  filter(!grepl("Not target", Structure))
###################################################
df4 <- subset(df3, !grepl("F2H7N4S1G1", Structure))

data1 <- df4 %>%
  filter(!grepl("F2H7N4S1G1", Structure))
summary(data1$Structure)
############################################################

#str(data1)



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
set.seed(124)
train_indices <- sample(1:nrow(data1), 0.7 * nrow(data1))
train_data <- data1[train_indices, ]
test_data <- data1[-train_indices, ]
#str(train_data)
summary(train_data$Structure)
######################################
library(scutr)
dTrain.smote <- data.frame() # 過採樣的train data
res <- "Structure"

for (i in 1:10) {
  smote_cur <- oversample_smote(train_data, unique(train_data$Structure)[i],"Structure", 100)
  print(i)
  # 105為最多樣本數類別的樣本數，即Not target的樣本數
  dTrain.smote <- rbind(dTrain.smote, smote_cur)
}

summary(dTrain.smote$Structure)

train_data <- dTrain.smote
###############################################################
formula <- Structure ~ .

#########################################################

library(class)

k <- 5  # Number of neighbors
knn_model <- knn(train = train_data[, -240], test = test_data[, -240], cl = train_data[, 240], k = k)

predictions <- knn_model

# 打印结果
print(test_data$Structure)
# Evaluate the model
accuracy <- sum(predictions == test_data$Structure) / length(predictions)
cat("Accuracy:", accuracy)

library(caret)

# Create a confusion matrix
confusion_matrix <- confusionMatrix(test_data$Structure, predictions)

# Print the confusion matrix
print(confusion_matrix)


f1_score <- confusion_matrix$byClass[, "F1"]
print(f1_score)



