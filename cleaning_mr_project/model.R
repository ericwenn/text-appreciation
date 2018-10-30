library(ggplot2)
library(randomForest)

# set.seed(1)

features <- read.csv('data/features.csv')
ratings <- read.csv('data/ratings.individual.csv')
link.ratings <- function(ratings, features) {
  linked <- data.frame()
  for(i in 1:nrow(features)) {
    f <- features[i,]
    r <- ratings[ratings$textID == f$tid & ratings$personID == f$pid, c("interest", "complexity", "comprehension")]
    linked <- rbind(linked, r)
  }
  return(linked)
}
ratings <- link.ratings(ratings, features)
feat_drop <- c("pid","tid")
features <- features[ , !(names(features) %in% feat_drop)]

interest <- (ratings$interest - mean(ratings$interest)) / sd(ratings$interest)
combined <- data.frame(features, interest = interest)
train.index <- sample(seq(1, nrow(combined)), 300)
combined.train <- combined[train.index, ]
combined.test <- combined[-train.index, ]

model <- randomForest(interest ~ ., data = combined.train, ntree = 500)
predicted <- predict(model, combined.test)
actual <- combined.test$interest
err <- abs(predicted - actual)


print(model)

