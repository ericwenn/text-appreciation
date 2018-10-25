library(emov)
sample_size <- function(df) {
  return(6)
}
dispersion <- function(df) {
  return(100)
}
aggregate <- function(df) {
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

# fixations
# start end duration x y pupil

# saccade
# start end duration startx starty endx endy