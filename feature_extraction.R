library(moments)
library(stringr)

extract_features <- function(fixations, saccades) {
  parameter.vector <- list()
  parameter.vector <- list(parameter.vector)
  
  RT <- reading_time(fixations)
  
  FD <- fixations$dur
  FD.mean <- mean(FD)
  FD.sd <- sd(FD)
  FD.skw <- skewness(FD)
  
  # change to a filter < 113000
  FDE <- fixations[fixations$dur > 113000,]$dur
  FDE.mean <- mean(FDE)
  FDE.sd <- sd(FDE)
  FDE.skw <- skewness(FDE)
  
  FS <- fixation_spacing(saccades)
  FS.mean <- mean(FS)
  FS.sd <- sd(FS)
  FS.skw <- skewness(FS)
  
  NF <- nrow(fixations)
  
  FPS <- fixations$pupil
  FPS.mean <- mean(FPS)
  FPS.sd <- sd(FPS)
  FPS.skw <- skewness(FPS)
  
  SD <- saccades$dur
  SD.mean <- mean(SD)
  SD.sd <- sd(SD)
  SD.skw <- skewness(SD)
  
  DR <- mean(fixations$dur) / mean(saccades$dur)
  
  RRS <- nrow(regressive_saccades(saccades)) / nrow(saccades)
  
  YDIST <- ydist_saccade(saccades) 
  
  data.frame(
    RT, 
    FD.mean, FD.sd, FD.skw, 
    FDE.mean, FDE.sd, FDE.skw,
    FS.mean, FS.sd, FS.skw,
    NF,
    DR,
    FPS.mean, FPS.sd, FPS.skw,
    SD.mean, SD.sd, SD.skw,
    RRS,
    YDIST
  )
}

# End time of last fixation - start time of first fixation
reading_time <- function(fixations) {
  return(fixations[nrow(fixations),"end"] - fixations[1,"start"])
}

fixation_spacing <- function(saccades) {
  spacing.y <- saccades$endy - saccades$starty
  spacing.x <- saccades$endx - saccades$startx
  filt <- (spacing.x) > 0 & abs(spacing.y) < 20
  
  filtered <- saccades[filt,]
  lengths <- sqrt((filtered$endy - filtered$starty) ** 2 + (filtered$endx - filtered$startx) ** 2)
  return(lengths)
}

regressive_saccades <- function(saccades) {
  spacing.y <- saccades$endy - saccades$starty
  spacing.x <- saccades$endx - saccades$startx
  filt <- spacing.y < -20 | (abs(spacing.y) < 10 & spacing.x < 0)
  
  filtered <- saccades[filt,]
  return(filtered)
  g <- ggplot(filtered, aes(x=startx, y=-starty, xend=endx, yend=-endy))
  g <- g + geom_segment(data = saccades)
  g <- g + geom_segment(color='red')
  print(g)
}

ydist_saccade <- function(saccades) {
  spacing.y <- saccades$endy - saccades$startx
  return(sum(abs(spacing.y)))
}


do_feature_extr <- function() {
  fixations <- dir('data/aggregated', pattern='fixations.*')
  saccades <- dir('data/aggregated', pattern='saccades.*')
  
  features <- data.frame()
  for(i in 1:length(fixations)) {
    fix <- read.csv(paste("data/aggregated/", fixations[i], sep='/'))
    sac <- read.csv(paste("data/aggregated/", saccades[i], sep='/'))
    feat <- extract_features(fix, sac)
    
    p <- str_match(fixations[i], "fixations.P([0-9]*)_([0-9]*)")
    pid <- p[[2]]
    tid <- p[[3]]
    print(paste(pid, tid))
    feat$pid <- as.numeric(pid)
    feat$tid <- as.numeric(tid)
    features <- rbind(features, feat)
  }
  write.csv(features, row.names = F, file = 'data/features.csv')
}
#fix <- read.csv("data/aggregated/fixations.P01_10879.txt")
#sac <- read.csv("data/aggregated/saccades.P10_2725_interpolated.txt")
#regressive_saccades(sac)
#res <- extract_features(fix, sac)
#View(res)