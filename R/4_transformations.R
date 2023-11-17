# Transformations

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
  
  
  print('placeheld')
  
  
  
}


pipeline_transformation_generateBusinessIntellDataframe_closedCalls <- function(
      dataset
    , monthsCollected
  )
{
  # Build dataset for visuals
  temp <- 
    dataset %>%
      filter(
          (status == "Closed")
        & (requested_datetime >= (lubridate::floor_date(Sys.Date(),'month') - months(monthsCollected)))
      )
  
  # Create Time Fields
  temp <- 
    temp %>%
    mutate(
        timeField__requested_month = lubridate::month(requested_datetime)
      , timeField__requested_monthDate = lubridate::floor_date(requested_datetime, "month") 
      , timeField__requested_year  = lubridate::year(requested_datetime)
      , timeField__requested_date  = lubridate::date(requested_datetime)
      , timeField__requested_weekDate  = lubridate::floor_date(requested_datetime, "week")
      , timefield__resolveTime     = bizdays::bizdays(
                                          requested_datetime
                                        , closed_datetime
                                        , cal = bizdays::create.calendar('my_calendar', weekdays = c('saturday','sunday'))
                                        )
    )
  
  # 
  
  return(temp)
  
}