library(ggplot2)
library(randomForest)
source('x-val.R')

set.seed(1)
# load feature and ratings
features <- read.csv('data/features.csv')
ratings <- read.csv('data/ratings.csv') # normalized ratings 1-7

# Retuns the ratings (interest, complexity and compreh.) in the same order as the features
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

# Remove pid and tid features as they should not be used for prediction
feat_drop <- c("pid","tid")
features <- features[ , !(names(features) %in% feat_drop)]

# Combine features and ONE rating into a single dataframe
combined <- data.frame(features, rating = ratings$interest)

# Split the data into training and test set
train.index <- sample(1:nrow(combined), 300)
features.train <- features[train.index,]
features.test <- features[-train.index,]

ratings.train <- ratings[train.index,]
ratings.test <- ratings[-train.index,]


train.rf <- function(features, labels, parameters) {
  model <- randomForest(rating ~ ., data = data.frame(features, rating = labels), mtry=parameters$mtry, nodesize=parameters$nodesize, ntree = 500)
  return(model)
}
predict.rf <- function(model, features, parameters) {
  predict(model, data.frame(features))
}

tune.rf <- function(parameters) {
  find_hyperparameters(
    features.train, ratings.train$comprehension, 
    train.rf, predict.rf, adjusted_r2,
    parameters
  )
}

r2 <- function(actual, predicted) {
  # implementation from https://en.wikipedia.org/wiki/Coefficient_of_determination
  yhat <- mean(actual)
  ss.tot <- sum((actual - yhat) ** 2)
  ss.res <- sum((actual - predicted) ** 2)
  return(1 - (ss.res / ss.tot))
}

adjusted_r2 <- function(actual, predicted, p=ncol(features), n = length(train.index)) {
  r <- r2(actual, predicted)
  return(1 - (1 - r)*(n-1)/(n-p-1))
}

mse <- function(actual, predicted) {
  return(mean((actual - predicted)**2))
}

# interest 9/6
# complexity 9/2
# comprehension 12/4

model <- randomForest(
  rating ~ ., 
  data = data.frame(features.train, rating = ratings.train$interest), 
  mtry=12, nodesize=4, ntree = 500
)
predicted <- predict(model, data.frame(features.test))
