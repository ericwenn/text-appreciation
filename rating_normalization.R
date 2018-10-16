
# Normalizes participant ratings 
# Sn = a * Sp + b
# a = (max - min) / (maxp - minp)
# b = max - a * maxp

normalize_ratings <- function(df) {
  
  to_normalize <- c("interest", "complexity", "comprehension")
  personIDs <- levels(df$personID)
  global.max <- 7
  global.min <- 1
  
  normalized <- data.frame()
  for(pid in personIDs) {
    person_ratings <- df[df$personID == pid,]
    person.max <- max(person_ratings[, to_normalize])
    person.min <- min(person_ratings[, to_normalize])
    for(column in to_normalize) {
      
      a <- (global.max - global.min) / (person.max - person.min)
      b <- global.max - a*person.max
      
      person_ratings[,column] <- a * person_ratings[,column] + b
    }
    normalized <- rbind(normalized, person_ratings)
  }
  return(normalized)
}
