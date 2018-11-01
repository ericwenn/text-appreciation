library(emov)
sample_size <- function(df) {
  return(6)
}
dispersion <- function(df) {
  return(100)
}

smooth <- function(df, window_size) {
  df$x <- filter(df$x, filter=rep(1/window_size, window_size))
  df$y <- filter(df$y, filter=rep(1/window_size, window_size))
  return(df)
}
aggregate <- function(df) {
  df <- smooth(df, 5)
  fixations <- emov.idt(df$time, df$x, df$y, dispersion(df), sample_size(df))
  pupils <- c()
  for (i in 1:(nrow(fixations))) {
    fixation <- fixations[i,]
    samples <- df[df$time <= fixation$end & df$time >= fixation$start,]
    pupils <- c(pupils, mean(samples$pupil))
  }
  fixations$pupil <- pupils
  
  
  start <- c()
  end <- c()
  duration <- c()
  startx <- c()
  starty <- c()
  endx <- c()
  endy <- c()
  for(i in 1:(nrow(fixations) - 1)) {
    f1 <- fixations[i,]
    f2 <- fixations[(i+1),]
    
    start <- c(start, f1$end)
    end <- c(end, f2$start)
    duration <- c(duration, f2$start - f1$end)
    startx <- c(startx, f1$x)
    starty <- c(starty, f1$y)
    endx <- c(endx, f2$x)
    endy <- c(endy, f2$y)
  }
  saccades <- data.frame(start, end, duration, startx, starty, endx, endy)
  return(list(
    fixations=fixations,
    saccades=saccades
  ))
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