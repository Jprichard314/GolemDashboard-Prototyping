# Transformations

#' Generate groups of likely repeated calls
#'
#' @param dataset 311 calls to visualize
#' @param field_orderBy a field to order calls by, should be a date
#' @param field_groupBy a field to group calls by, we use address.
#' @param field_category a field to categorize calls by, we use subject.
#'
#' @return 311 dataset with a fields indicating
#'          1. Whether the call is a repeat call
#'          2. whether the call is part of a group of repeat calls.
#' @export
#'
#' @examples
pipeline_transformation_generateRepeatCallGroupings <-  function(
    dataset
    , field_orderBy
    , field_groupBy
    , field_category
)
{
  # Creating an aliased column.
  temp <- 
      dataset %>% 
      mutate(
          alias_field_category = .[[field_category]]
        , alias_field_orderBy  = .[[field_orderBy]]
      )
    
  
  # Order temp
  temp <-
    temp %>%
    group_by(.[[field_groupBy]]) %>%
    arrange(alias_field_orderBy)
  
  # Create Lag Column Names
  column_orderLag = paste("lag_",field_orderBy,sep='')
  column_categoryLag = paste("lag_",field_category,sep='')
    
  temp <-
    temp %>%
    # Create Lagged Columns
    mutate(
        !!column_orderLag := dplyr::lag(
          x = alias_field_orderBy
        , n = 1
        , default = NA
      )
      , !!column_categoryLag := dplyr::lag(
          x = alias_field_category
        , n = 1
        , default = NA
      )
    ) %>%
    ungroup() %>%
    
    # Calculate call between current and previous calls
    mutate(
      timeDiff = difftime(
          alias_field_orderBy
        , .[[column_orderLag]]
        , units = "hours"
      )
    ) %>%
    
    # Define repeat calls:
      # Repeat call when time difference is X hours (default, 72)
      # And call categories between lag and current remain the same
      # All within a group.
    mutate(
        isRepeat  = case_when(
          timeDiff <= 72 & (
            .[[!!column_categoryLag]] == alias_field_category
          ) ~ 1
          , .default = 0
      )
      , isRepeatCallGroup  = case_when(
          timeDiff <= 72 & (
            .[[!!column_categoryLag]] == alias_field_category
          ) ~ 0
          , .default = 1
      )
      , t1 = !!column_categoryLag
      , t2 = !!column_orderLag
    ) %>%
    group_by(.[[field_groupBy]]) %>%
    
    # Generate repeat call group number.
    mutate(
      repeatCallGroup = cumsum(isRepeatCallGroup)
    ) %>%
    ungroup() %>% 
    select(-c(
          '.[[field_groupBy]]'
         #, alias_field_category
         #, alias_field_orderBy
      )
    )
  
  return(temp)
  
}


pipeline_transformation_generateRepeatCallStatistics <- function(
      dataset
  
)
{
  
  
  
  
  
  
}




#' Generate weekly level aggregates for 311 call data
#'
#' @param dataset 311 call data to visualize
#'
#' @return a weekly level breakdown of calls by department and service_name
#' @export
#'
#' @examples
pipeline_transformation_generateWeeklyAggregates <- function(
    dataset
){
  
  temp <- 
    dataset %>%
      mutate(week_request = lubridate::floor_date(closed_datetime, unit = "1 week")) %>%
      group_by(week_request, agency_responsible, service_name) %>%
      summarize(CallCount = n())
  
  return(temp)
}


#' Generate metadata for 311 calls dataset
#'
#' @param dataset 311 call data to visualize.
#'
#' @return a list of metadata.
#'
#' @examples
#' pipeline_transformation__overallPageMetrics(raw311Calls)
pipeline_transformation__overallPageMetrics <- function(
  dataset
){

  
  output <- list(
    totalCalls = dataset %>% nrow(),
    minClosedDate = dataset %>% .$closed_datetime %>% min(),
    maxClosedDate = dataset %>% .$closed_datetime %>% max()
  )
  
  return(output)
}

pipeline_transformation__calculateResolutionTimeField <- function(
    field_openDate, field_closeDate, data){
  
  temp <- 
    data %>%
    mutate(ttr = lubridate::interval(data[[field_openDate]], data[[field_closeDate]])/ lubridate::hours(1))
  
  
  return(temp)
  
}