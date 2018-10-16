to_normalize <- c("interest", "complexity", "comprehension")

normalize_ratings <- function(df) {
  personIDs <- levels(df$personID)
  normalized <- data.frame()
  for(pid in personIDs) {
    person_ratings <- df[df$personID == pid,]
    for(n in to_normalize) {
      person_ratings[,n] = as.vector(scale(person_ratings[,n]))
    }
    normalized <- rbind(normalized, person_ratings)
  }
  return(normalized)
}
