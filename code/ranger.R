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
df2<- df2[, -which(names(df1) %in% c("entry.no", "MS1scan.no", "MS1Isolation.mass","MS1monoIsomass","chargeState","in..H..","MS2.Scan.no"))]

df3 <- subset(df2, !grepl("Not target", Structure))
library(dplyr)
data1 <- df3 %>%
  filter(!grepl("Not target", Structure))
###########
#str(data1)

# 将 "Structure" 列转换为因子类型
data1$Structure <- as.factor(data1$Structure)

# 将因子级别重新编码为 1 到 11(含not target有12筆)
levels(data1$Structure) <- 1:11


# 查看修改后的 "Structure" 列的摘要
summary(data1$Structure)





# Split the dataset into training and testing sets
set.seed(123)
train_indices <- sample(1:nrow(data1), 0.7 * nrow(data1))
train_data <- data1[train_indices, ]
test_data <- data1[-train_indices, ]


summary(train_data$Structure)
summary(test_data$Structure)
##################################################
formula <- Structure ~ .

#########################################################
library(e1071)
# Train the Naive Bayes model
nb_model <- naiveBayes(formula, data = train_data)


# Make predictions on the test set
predictions <- predict(nb_model, newdata = test_data)


# 打印结果
#print(test_data$Structure)
# Evaluate the model
accuracy <- sum(predictions == test_data$Structure) / length(predictions)
cat("Accuracy:", accuracy)

library(caret)
library(ggplot2)
library(lattice)
# Create a confusion matrix
confusion_matrix <- confusionMatrix(test_data$Structure, predictions)

# Print the confusion matrix
print(confusion_matrix)


f1_score <- confusion_matrix$byClass[, "F1"]
print(f1_score)