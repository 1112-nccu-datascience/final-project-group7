
library(data.table)
library(caret)
library(e1071)
library(randomForest)
library(ROSE)
library(scutr)
library(dplyr)
library(ggplot2)

set.seed(124)
input <- read.csv("output_name_nor_simple.csv") # input為277筆篩選過後的檔案
input <- as.data.table(input)

# structures:
# F1H5N4S2
# F1H6N4S2
# F2H7N4S2
# F1H5N4S1
# F1H6N4S1
# F2H6N4S1
# F1H7N4S2
# F2H4N5
# F2H7N4S1G1 # 已省略
# F2H7N4G2
# F1H3N5

## 處理train data
dTrain.raw <- input[,-(1:7)] # 去掉前7行
str <- factor(dTrain.raw$Structure, levels = unique(dTrain.raw$Structure))
dTrain.all <- dTrain.raw[, colSums(dTrain.raw > 2.72) > 0, with = FALSE][, Structure := str]
# 刪掉所有rows為0的columns, 刪完應會剩下240行 # factor應變項

dTrain.raw <- dTrain.raw[, Structure := str] # factor應變項
train.index <- createDataPartition(dTrain.raw$Structure, p = 0.6, list = FALSE)
dTest.raw <- dTrain.raw[-train.index]
dTrain.raw <- dTrain.raw[train.index]

cols <- colnames(dTrain.all)[-length(dTrain.all)]
dTrain.all <- dTrain.all[, (cols) := lapply(.SD, scale, center = TRUE, scale = FALSE), .SDcols = cols] 
  # centering所有自變項

## 依類別比例切割建立test set
train.index <- createDataPartition(dTrain.all$Structure, p = 0.6, list = FALSE)
dTrain.processed <- dTrain.all[train.index]
dTest.processed <- dTrain.all[-train.index]

dTrain.smote <- data.table() # 過採樣的train data
res <- "Structure"

for (i in 1:11) {
  smote_cur <- oversample_smote(dTrain.processed, unique(dTrain.processed$Structure)[i], res, 90)
    # 105為最多樣本數類別的樣本數，即Not target的樣本數
  dTrain.smote <- rbind(dTrain.smote, smote_cur)
}

##
# dTrain.raw: 處理前的train data
# dTrain.processed: 處理後的train data
# dTrain.smote: 過採樣且處理後的train data

##
# dTest.raw: 處理前的test data, 要和dTrain.raw一起配
# dTest.processed: 處理後的test data, 要和dTrain.processed或dTrain.smote一起配

train_control <- trainControl(method = "cv", number = 10)

model.rf.raw <- train(Structure ~ ., data = dTrain.raw, method = "rf", trControl = train_control,
                      tuneLength = 10, metric = "Kappa", maximize = TRUE) # use raw
model.rf.processed <- train(Structure ~ ., data = dTrain.processed, method = "rf", trControl = train_control,
                            tuneLength = 10, metric = "Kappa", maximize = TRUE) # use processed
model.rf.smote <- train(Structure ~ ., data = dTrain.smote, method = "rf", trControl = train_control,
                        tuneLength = 10, metric = "Kappa", maximize = TRUE) # use smote

pred.raw <- predict(model.rf.raw, newdata = dTest.raw)
confus.raw <- confusionMatrix(pred.raw, as.factor(dTest.raw$Structure))
outcome.raw <- confus.raw$byClass

pred.processed <- predict(model.rf.processed, newdata = dTest.processed)
confus.processed <- confusionMatrix(pred.processed, dTest.processed$Structure)
outcome.processed <- confus.processed$byClass

pred.smote <- predict(model.rf.smote, newdata = dTest.processed)
confus.smote <- confusionMatrix(pred.smote, as.factor(dTest.processed$Structure))
outcome.smote <- confus.smote$byClass

#
# plot(model.rf.raw, metric = "Kappa")
# whichTwoPct <- tolerance(model.rf.raw$results, metric = "Kappa", 
#                          tol = 2, maximize = TRUE) 
# model.rf.raw$results[whichTwoPct, 1:5]

## svm family
model.svmRadial.raw <- train(Structure ~ ., data = dTrain.raw, method = "svmRadial", trControl = train_control,
                             tuneLength = 20, metric = "Kappa", maximize = TRUE) # use raw
model.svmRadial.processed <- train(Structure ~ ., data = dTrain.processed, method = "svmRadial", trControl = train_control,
                             tuneLength = 20, metric = "Kappa", maximize = TRUE) # use processed
model.svmRadial.smote <- train(Structure ~ ., data = dTrain.smote, method = "svmRadial", trControl = train_control,
                             tuneLength = 20, metric = "Kappa", maximize = TRUE) # use smote

pred.svmR.raw <- predict(model.svmRadial.raw, newdata = dTest.raw)
confus.svmR.raw <- confusionMatrix(pred.svmR.raw, as.factor(dTest.raw$Structure))
outcome.svmR.raw <- confus.svmR.raw$byClass

pred.svmR.processed <- predict(model.svmRadial.processed, newdata = dTest.processed)
confus.svmR.processed <- confusionMatrix(pred.svmR.processed, as.factor(dTest.processed$Structure))
outcome.svmR.processed <- confus.svmR.processed$byClass
outcome.svmR.processed <- round(outcome.svmR.processed, 2)[, c(1,2,5,6,7,11)]

# compare models
resamps <- resamples(list(RawRF = model.rf.raw,
                          ProcessedRF = model.rf.processed,
                          RawSVMR = model.svmRadial.raw,
                          ProcessedSVMR = model.svmRadial.processed))
summary(resamps)

# important variables
svmImp.raw <- varImp(model.svmRadial.raw, scale = FALSE)
svmImp.processed <- varImp(model.svmRadial.processed, scale = TRUE)
svmImp.all <- svmImp.processed$importance
plot(svmImp.processed, top = 10)

# X1607.8275 X450.2334 X1348.6856 X804.4174 X697.3753 X1144.5858 X1727.8698 X654.3331 X1112.5645 
# X843.4276 X452.249 X1030.0383 X1146.5776 X842.438 X793.3966 X189.1121 X1799.9273 X344.1704
# X1726.8745 X464.249      

impVars <- c("X1607.8275", "X450.2334", "X1348.6856", "X804.4174", "X697.3753", "X1144.5858",
             "X1727.8698", "X654.3331", "X1112.5645", "X843.4276", "X452.249", "X1030.0383",
             "X1146.5776", "X842.438", "X793.3966", "X189.1121", "X1799.9273", "X344.1704",
             "X1726.8745", "X464.249")
impMeasure <- svmImp.processed$importance
impMeasure$rowName <- rownames(impMeasure)
impVars <- impMeasure[impMeasure$rowName %in% impVars,]

singVarImp <- ggplot(data = impVars, aes(x = impVars$F1H6N4S1, y = impVars$rowName)) +
  geom_col() + labs(x = "contribution to F1H6N4S1", y = "top 20 important vars")

write.csv(impVars, "svmImportantVars.csv")
write.csv(as.data.frame(outcome.svmR.processed), "svmStatsOutcomes.csv")

# 交叉比對rf和svm取重要變項的異同
rfImpVars <- read.csv("importance.csv")
impNames.rf <- rfImpVars$X
impNames.svm <- impVars$rowName
varDiff <- setdiff(impNames.rf, impNames.svm)
varIntersect <- intersect(impNames.rf, impNames.svm)















