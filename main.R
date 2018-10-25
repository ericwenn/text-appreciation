source("aggregation.R")
source("cleaning.R")
source("feature_extraction.R")
source("rating_normalization.R")


load_ratings <- function() {
  df <- read.csv("data/participant_ratings.csv")
  df$personID <- as.factor(df$personID)
  return(df)
}

read_formatted_file <- function(path, headerMap) {
  columns <- c(headerMap$time, headerMap$x, headerMap$y, headerMap$pupilx,headerMap$pupily)
  df <- apply(read.csv(path), 1, function(s) {
    data.frame(
      time=as.numeric(s[headerMap$time]),
      x=as.numeric(s[headerMap$x]), 
      y=as.numeric(s[headerMap$y]),
      pupil=as.numeric(s[headerMap$pupilx])*as.numeric(s[headerMap$pupily])
    )
  })
  df <- as.data.frame(do.call(rbind, df))
  return(df)
}
 aggregate_files <- function(rawDir, aggregatedDir, pattern = NULL, headerMap) {
   files <- dir(rawDir, pattern)
   for(file in files) {
     path <- paste(rawDir, file, sep = '/')
     df <- read_formatted_file(path, headerMap)
     d <- aggregate(df)
     fixations <- d$fixations
     saccades <- d$saccades
     
     path.fixation <- paste(aggregatedDir, paste("fixations", file, sep="."), sep="/")
     path.saccade <- paste(aggregatedDir, paste("saccades", file, sep="."), sep="/")
     
     write.csv(fixations, path.fixation, row.names=F)
     write.csv(saccades, path.saccade, row.names=F)
     print(file)
   }
 }
 
 aggregate_files(
  "data/raw",
  "data/aggregated",
  headerMap = list(
    time="Time", 
    x="L.POR.X..px.", 
    y="L.POR.Y..px.",
    pupilx="L.Dia.X..px.",
    pupily="L.Dia.Y..px."
  )
)