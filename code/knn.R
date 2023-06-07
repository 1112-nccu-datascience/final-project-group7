# 1112 Data Science Final Project ####

# KNN Classifier ####

# packages ####
library(readr)
library(caret)
library(pROC)
library(mlbench)
library(class)
library(magrittr)

# import data ####
df <- read_csv("../data/output_name_nor_simple.csv")

df$Structure <- as.factor(df$Structure)

df <- df[, -(1:7)]

set.seed(666)
I_train <- sample(1:nrow(df), size = 0.8*nrow(df), replace = TRUE)

# caret::knn, k=5 ####
trControl <- trainControl(method = "repeatedcv",
                          number = 5,
                          repeats = 3)

eq <- formula(paste("Structure ~", paste0("`", colnames(df)[-length(df)], "`", collapse = " + ")))

fit <- train(eq,
             data = df,
             subset = I_train,
             method = "knn", 
             tuneLength = 20,
             trControl = trControl,
             preProc = c("center", "scale"))

# performance ####

plot(fit)
#varImp(fit)

pred1 <- predict(fit, newdata = df[-I_train, ])

cm1 <- confusionMatrix(pred1, factor(df[-I_train,]$Structure, levels = levels(pred1)),
                mode = "everything")

# F1 score, 0.73
cm1$byClass[,"F1"]
cm1$byClass[,"F1"] %>% mean(na.rm = TRUE)

# class::knn , k=1 ####
pred2 <- knn(df[I_train, -length(df)], df[-I_train, -length(df)], 
    cl = df[I_train,]$Structure, 
    k = 1)

table(pred2, df[-I_train,]$Structure)

cm2 <- confusionMatrix(pred2, factor(df[-I_train,]$Structure, levels = levels(pred2)),
                mode = "everything")

rownames(cm2$byClass) <- gsub("Class: ", "", rownames(cm2$byClass))

# F1 score, 0.81
cm2$byClass[,"F1"] %>% 
  round(4) %>% 
  write.table(quote = FALSE)

cm2$byClass[,"F1"] %>% 
  mean(na.rm = TRUE)

# # raw ####
# 
# s.level <- unique(dTrain.raw$Structure)
# 
# dTrain.raw$Structure %<>% factor(levels = s.level)
# dTrain.smote$Structure %<>% factor(levels = s.level)
# dTest.raw$Structure %<>% factor(levels = s.level)
# dTest.processed$Structure %<>% factor(levels = s.level)
# 
# set.seed(123)
# pred.raw <- knn(dTrain.raw[,-"Structure"], dTest.raw[,-"Structure"],
#              cl = dTrain.raw$Structure, 
#              k=1)
# 
# table(pred.raw, dTest.raw$Structure)
# 
# cm.raw <- confusionMatrix(pred.raw, dTest.raw$Structure,
#                           mode = "everything")
# 
# cm.raw$byClass[,"F1"]
# cm.raw$byClass[,"F1"] %>% mean(na.rm = TRUE)
# 
# # processed ####
# set.seed(123)
# pred.processed <- knn(dTrain.processed[,-"Structure"], dTest.processed[,-"Structure"],
#                 cl = dTrain.processed$Structure, 
#                 k=1)
# 
# table(pred.processed, dTest.processed$Structure)
# 
# cm.processed <- confusionMatrix(pred.processed, dTest.processed$Structure,
#                           mode = "everything")
# 
# cm.processed$byClass[,"F1"]
# cm.processed$byClass[,"F1"] %>% mean(na.rm = TRUE)
