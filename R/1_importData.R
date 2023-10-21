# Import Data from CartoDB
source("R/rUtils/dataCapture/apis.R")

pipeline_extract_cartoDbMonthQuery <- function(
    baseQuery
    , monthsOfData = 12
) 
{
  #'Purpose:
  #'  This function wraps a sql query written to Philadelphia's CartoDB Api because
  #'  url encoding doesn't seem to work well with Postgres's interval syntax.
  #'  
  #'  It takes today's date and captures back a number of months determined by the user.
  #'Input
  #'  baseQuery    -- Select and from statement for 
  #'  monthsOfData -- defaults to 12, but the number of months back we're capturing.
  #'Output
  #'  X months of 311 data.
  
  # calculate query date.
  start_date <- floor_date(
    Sys.Date()
    , unit = 'month'
  ) - months(monthsOfData)
  
  # Write query using glue.
  query <-  glue(
    "{baseQuery} '{start_date}'"
  )
  
  # get data
  temp <- getData_phlCartoApi( query )
  return(temp)
}