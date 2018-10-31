library(ggplot2)
library(randomForest)

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
#features.train <- features[train.index,]
#features.test <- features[-train.index,]

#ratings.train <- ratings[train.index,]
#ratings.test <- ratings[-train.index,]
oob <- double(10)
test.err <- double(10)

for(mtry in 1:10) {
  model <- randomForest(
    rating ~ .,
    data = combined,
    subset = train.index,
    ntree=500,
    mtry=mtry,
    nodesize=1
  )
  
  oob[mtry] <- model$mse[500]
  
  predicted <- predict(model, combined[-train.index, ])
  test.err[mtry]= with(combined[-train.index,], mean( (rating - predicted)^2)) #Mean Squared Test Error
  
}
# Train regressive random forest model


print(model)

