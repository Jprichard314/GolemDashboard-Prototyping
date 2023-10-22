# Transformations
# 
# ## Generate Repeat Calls
# DEP___pipeline_transformation_generateRepeatCallGroupings <-  function(
    #     dataset
#     , field_orderBy
#     , field_groupBy
#     , fields_lagColumn
# )
# {
#   # Order temp
#   temp <-
#     dataset %>%
#     arrange(.[[field_orderBy]]) %>%
#     group_by(.[[field_groupBy]])
#
#   # Lag multiple columns
#   temp <-
#     temp %>%
#     mutate(
#         across(
#           fields_lagColumn
#         , function(x) lag(
#             x
#           , n = 1
#           , default = NA
#         )
#         , .names = "lag_{col}"
#       )
#     )
#
#   # Ungroup
#   temp <-
#     temp%>%
#     ungroup() %>%
#     select(-'.[[field_groupBy]]')
#
#
#
#   return(temp)
#
# }





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
    group_by(.[[field_groupBy]])
  
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
        , order_by = alias_field_orderBy
      )
      , !!column_categoryLag := dplyr::lag(
          x = alias_field_category
        , n = 1
        , default = NA
        , order_by = alias_field_orderBy
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
            !!column_categoryLag == alias_field_category
          ) ~ 1
          , .default = 0
      )
      , isRepeatCallGroup  = case_when(
          timeDiff <= 72 & (
            !!column_categoryLag == alias_field_category
          ) ~ 0
          , .default = 1
      )
    ) %>%
    group_by(.[[field_groupBy]]) %>%
    
    # Generate repeat call group number.
    mutate(
      repeatCallGroup = cumsum(isRepeatCallGroup)
    ) %>%
    ungroup() %>% 
    select(-c(
          '.[[field_groupBy]]'
         , alias_field_category
         , alias_field_orderBy
      )
    )
  
  return(temp)
  
}