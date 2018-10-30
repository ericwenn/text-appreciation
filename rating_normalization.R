
# Normalizes participant ratings 
# Sn = a * Sp + b
# a = (max - min) / (maxp - minp)
# b = max - a * maxp
normalize_ratings <- function(df) {
  # Only normalize these columns
  to_normalize <- c("interest", "complexity", "comprehension")
  
  personIDs <- levels(df$personID)
  global.max <- 7
  global.min <- 1
  
  normalized <- data.frame()
  
  for(pid in personIDs) {
    # Extract this persons ratings
    person_ratings <- df[df$personID == pid,]
    
    # Calculate min and max for the persons ratings for all columns
    
    for(column in to_normalize) {
      person.max <- max(person_ratings[, column])
      person.min <- min(person_ratings[, column])
      a <- (global.max - global.min) / (person.max - person.min)
      b <- global.max - a*person.max
      
      person_ratings[,column] <- a * person_ratings[,column] + b
    }
    normalized <- rbind(normalized, person_ratings)
  }
  return(normalized)
}
