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
  
  SV <- saccade_velocity(saccades)
  SV.mean <- mean(SV)
  SV.sd <- sd(SV)
  SV.skw <- skewness(SV)
  
  DR <- mean(fixations$dur) / mean(saccades$dur)
  
  RRS <- nrow(regressive_saccades(saccades)) / nrow(saccades)
  
  YDIST <- ydist_saccade(saccades)
  
  RT.YDIST <- RT / YDIST
  FD.SD <- mean(FD) / mean(SD)
  RT.NF <- RT / NF
  
  data.frame(
    RT, 
    FD.mean, FD.sd, FD.skw, 
    FDE.mean, FDE.sd, FDE.skw,
    FS.mean, FS.sd, FS.skw,
    NF,
    DR,
    FPS.mean, FPS.sd, FPS.skw,
    SD.mean, SD.sd, SD.skw,
    SV.mean, SV.sd, SV.skw,
    RRS,
    YDIST,
    RT.YDIST,
    FD.SD,
    RT.NF
  )
}

# End time of last fixation - start time of first fixation
reading_time <- function(fixations) {
  return(fixations[nrow(fixations),"end"] - fixations[1,"start"])
}

fixation_spacing <- function(saccades) { #here..more or less i didnt undr the reasoning...not that is incorrect
  spacing.y <- saccades$endy - saccades$starty
  spacing.x <- saccades$endx - saccades$startx
  filt <- (spacing.x) > 0 & abs(spacing.y) < 20
  
  filtered <- saccades[filt,]
  lengths <- sqrt((filtered$endy - filtered$starty) ** 2 + (filtered$endx - filtered$startx) ** 2)
  return(lengths)
}

regressive_saccades <- function(saccades) {#here why -20? isnt the axis origin of the screen at left bottom ?
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
  spacing.y <- saccades$endy - saccades$starty
  return(sum(abs(spacing.y)))
}

saccade_velocity <- function(saccades) {
  velo <- c()
  for(i in 1:nrow(saccades)) {
    s <- saccades[i,]
    dist <- sqrt((s$startx - s$endx) ** 2 + (s$starty - s$endy) ** 2)
    v <- dist / s$dur
    velo <- c(velo, v)
  }
  return(velo)
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

do_feature_extr2 <- function() {
  fixations <- dir('data/aggregated', pattern='fixations.*')
  saccades <- dir('data/aggregated', pattern='saccades.*')
  
  events <- c()
  tids <- c()
  pids <- c()
  for(i in 1:length(fixations)) {
    fix <- read.csv(paste("data/aggregated/", fixations[i], sep='/'))
    events <- c(events, classify(fix))
    
    p <- str_match(fixations[i], "fixations.P([0-9]*)_([0-9]*)")
    pids <- c(pids, p[[2]])
    tids <- c(tids, p[[3]])
  }
  featurematr <- as.data.frame(dfm(events, ngrams=1:3))
  featurematr$pids <- pids
  featurematr$tids <- tids
  
  write.csv(featurematr, row.names = F, file = 'data/features.tm.csv')
  
  return(featurematr)
}


classify <- function(fixations) {
  events <- c()
  dists <- c()
  fixation_classes <- list(
    list(label="150", min=0, max=150),
    list(label="300", min=150, max=300),
    list(label="450", min=300, max=450),
    list(label="600", min=450, max=600),
    list(label="M", min=600, max=Inf)
  )
  saccade_classes <- list(
    list(label="35", min=0, max=35),
    list(label="70", min=35, max=70),
    list(label="105", min=70, max=105),
    list(label="140", min=105, max=140),
    list(label="M", min=140, max=Inf)
  )
  
  for(i in 1:nrow(fixations)) {
    fixation <- fixations[i,]
    labelf <- NULL
    for(j in 1:length(fixation_classes)) {
      cl <- fixation_classes[[j]]
      if (fixation$dur > cl$min*1000 && fixation$dur <= cl$max*1000) {
        labelf <- cl$label
        break
      }
    }
    events <- c(events, paste("FIX", labelf, sep = ""))
    
    if (i < nrow(fixations)) {
      fixation2 <- fixations[(i+1), ]
      lenx <- fixation2$x - fixation$x
      leny <- fixation2$y - fixation$y
      distance <- sqrt(lenx**2 + leny**2)
      labels <- NULL
      dists <- c(dists, distance)
      for(j in 1:length(saccade_classes)) {
        cl <- saccade_classes[[j]]
        if (distance > cl$min && distance <= cl$max) {
          labels <- cl$label
          break
        }
      }
      events <- c(events, paste("SAC", labels, sep = ""))

    }
  }
  return(paste(events, collapse = ' '))
}
#fix <- read.csv("data/aggregated/fixations.P01_10879_interpolated.txt")
#sac <- read.csv("data/aggregated/saccades.P01_10879_interpolated.txt")
#regressive_saccades(sac)
#res <- extract_features(fix, sac)
#View(res)