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
df <- read_csv("data/output_name_nor_simple.csv")

I_train <- sample(1:nrow(df), size = 0.8*nrow(df), replace = TRUE)

df$Structure <- as.factor(df$Structure)

# caret::knn, k=5 ####
trControl <- trainControl(method = "repeatedcv",
                          number = 5,
                          repeats = 3)

eq <- formula(paste("Structure ~", paste0("`", colnames(df)[c(6,8:276)], "`", collapse = " + ")))

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

# F1 score, 0.72
cm1$byClass[,"F1"]

cm1$byClass[,"F1"] %>% mean(na.rm = TRUE)

# class::knn , k=1 ####

pred2 <- knn(df[I_train, 8:276], df[-I_train, 8:276], 
    cl = factor(df[I_train,]$Structure, levels = levels(pred1)), 
    k = 1)

table(pred2, df[-I_train,]$Structure)

cm2 <- confusionMatrix(pred2, factor(df[-I_train,]$Structure, levels = levels(pred2)),
                mode = "everything")

# F1 score, 0.88
cm2$byClass[,"F1"]

cm2$byClass[,"F1"] %>% mean(na.rm = TRUE)
