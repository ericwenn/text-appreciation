source("aggregation.R")
source("cleaning.R")
source("feature_extraction.R")
source("rating_normalization.R")


load_ratings <- function() {
  df <- read.csv("data/participant_ratings.csv")
}