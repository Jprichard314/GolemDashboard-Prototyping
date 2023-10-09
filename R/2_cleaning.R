# Clean the Data

clean_cartoDb_threeOneOne_data <- function(df)
{
  # This cleaning function takes the raw import from
  # the carto db and:
    # rewrites it from a matrix to a dataframe
    # Rewrites CARTODB "NULL"s to NAs
    # Writes Date Columns to dates.
  # Consider pushing back datetype and numeric conversions.
  
  df_clean <- 
    df %>%
    # Convert from matrix to data.frame
    as.data.frame %>%
    # Coerce all data to characters from lists
    mutate_all(as.character) %>%
    # Rewrite nulls to NA
    mutate_all(na_if,"NULL") %>%
    # Write Datetypes and Numerics
    mutate(
      requested_datetime = janitor::convert_to_datetime(requested_datetime)
      , updated_datetime   = janitor::convert_to_datetime(updated_datetime)
      , expected_datetime  = janitor::convert_to_datetime(expected_datetime)
      , lat                = as.numeric(lat)
      , lon                = as.numeric(lon)
    )
  
  
  return(df_clean)
  

}