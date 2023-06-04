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
data1<- df2[, -which(names(df1) %in% c("entry.no", "MS1scan.no", "MS1Isolation.mass","MS1monoIsomass","chargeState","in..H..","MS2.Scan.no"))]
###########                      
#df2<- df2[, -which(names(df1) %in% c("entry.no", "MS1scan.no", "MS1Isolation.mass","MS1monoIsomass","chargeState","in..H..","MS2.Scan.no"))]

#df3 <- subset(df2, !grepl("Not target", Structure))
#library(dplyr)
#data1 <- df3 %>%
#  filter(!grepl("Not target", Structure))
###########
#str(data1)

# 将 "Structure" 列转换为因子类型
data1$Structure <- as.factor(data1$Structure)

# 将因子级别重新编码为 1 到 11(含not target有12筆)
levels(data1$Structure) <- 1:12


# 查看修改后的 "Structure" 列的摘要
summary(data1$Structure)





# Split the dataset into training and testing sets
set.seed(123)
train_indices <- sample(1:nrow(data1), 0.7 * nrow(data1))
train_data <- data1[train_indices, ]
test_data <- data1[-train_indices, ]


str(train_data)

formula <- Structure ~ .

#########################################################
library(neuralnet)
# Create and train the neural network model
nn <- neuralnet(formula, data = train_data, hidden = c(240, 120, 60, 30), threshold = 0.01,
                stepmax = 1e+05, rep = 1, startweights = NULL,
                learningrate.limit = NULL, learningrate.factor = list(minus = 0.01,plus = 1.2), learningrate = NULL, lifesign = "none",
                lifesign.step = 1000, algorithm = "rprop+", err.fct = "sse",
                act.fct ="logistic", linear.output = TRUE, exclude = NULL,
                constant.weights = NULL, likelihood = FALSE)

# Make predictions on the test data
predictions <- predict(nn, test_data[, 1:240])

# Convert predictions to class labels
predicted_classes <- apply(predictions, 1, which.max)
predicted_classes <- levels(factor(data1$Structure))[predicted_classes]
predicted_classes <- as.integer(predicted_classes)
predicted_classes <- factor(predicted_classes, levels = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12))

# 打印结果
print(test_data$Structure)
# Evaluate the model
accuracy <- sum(predicted_classes == test_data$Structure) / length(predicted_classes)
cat("Accuracy:", accuracy)
############################################################


library(caret)

# Create a confusion matrix
confusion_matrix <- confusionMatrix(test_data$Structure,predicted_classes)

# Print the confusion matrix
print(confusion_matrix)


f1_score <- confusion_matrix$byClass[, "F1"]
print(f1_score)