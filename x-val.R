k_fold <- function(features, labels, fn.train, fn.predict, fn.metric, k = 10) {
  metrics <- c()
  
  # Randomly rearrange the features and labels
  ordering <- sample(seq(1, nrow(features)))
  features <- features[ordering,]
  labels <- labels[ordering]
  
  fold.size <- floor(nrow(features) / k)
  for(fold.index in 1:k-1) {
    start <- 1 + fold.index*fold.size
    fold <- seq(start, start + fold.size - 1)
    
    features.training <- features[-fold,]
    features.validation <- features[fold,]
    
    labels.training <- labels[-fold]
    labels.validation <- labels[fold]
    
    model <- fn.train(features.training, labels.training)
    labels.validation.predicted <- fn.predict(model, features.validation)
    
    metric <- fn.metric(labels.validation, labels.validation.predicted)
    metrics <- c(metrics, metric)
  }
  
  return(metrics)
}

find_hyperparameters <- function(features, labels, fn.train, fn.predict, fn.metric, parameters.list) {
  variations <- do.call(expand.grid, parameters.list)
  variations$metric <- 0
  print(paste("Finding hyperparameters from", nrow(variations), "variations"))
  for(i in 1:nrow(variations)) {
    print(i)
    # avoid converting list to a numeric value if only one parameter
    parameters <- variations[i,, drop=F]
    train <- function(ft, lbls) {
      fn.train(ft, lbls, parameters)
    }
    predict <- function(model, ft) {
      fn.predict(model, ft, parameters)
    }
    metrics <- k_fold(features, labels, train, predict, fn.metric)
    metrics.average <- mean(metrics)
    variations[i,"metric"] <- metrics.average
  }
  return(variations)
}