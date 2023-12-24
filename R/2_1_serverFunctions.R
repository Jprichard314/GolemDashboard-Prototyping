getDataForOverallPages <- function(data){
  
  output <- list(
    totalCalls = data %>% nrow(),
    minClosedDate = data %>% .$closed_datetime %>% min(),
    maxClosedDate = data %>% .$closed_datetime %>% max()
  )
  
  return(output)
  
}