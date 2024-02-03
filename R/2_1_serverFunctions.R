#### helper functions ####
filter__ <- function(
    data
){
  temp <- 
    data %>%
    mutate(rowNumber = row_number())
}


#### Server Functions ####

