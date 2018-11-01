source("aggregation.R")
source("feature_extraction.R")
source("rating_normalization.R")


load_ratings <- function() {
  df <- read.csv("data/participant_ratings.csv")
  df$personID <- as.factor(df$personID)
  return(df)
}

do_aggregation <- function() {
   aggregate_files(
     "cleaning_mr_project/eye-tracking_data_interpolated",
    "data/aggregated2",
    headerMap = list(
      time="Time", 
      x="L.POR.X..px.",
      y="L.POR.Y..px.",
      pupilx="L.Dia.X..px.",
      pupily="L.Dia.Y..px."
    )
  )
 }