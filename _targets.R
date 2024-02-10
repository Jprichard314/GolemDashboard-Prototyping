# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline


#____________________________________________________
#### Load Libraries ####
#____________________________________________________
source("data/0_libraries.R")


#____________________________________________________
#### Set Options ####
#____________________________________________________
# Set target options:
tar_option_set(
  packages = c(
                  "tidyverse"
                , "lubridate"
                , "janitor"
                , "glue"
                , "validate"
               ) 

)


options(clustermq.scheduler = "multiprocess")

#____________________________________________________
#### Source ####
#____________________________________________________
tar_source(
  c(
      "data/rUtils/dataCapture/apis.R"
    , "data/2_cleaning.R"
    , "data/1_importData.R"
    , "data/3_validators.R"
    , "data/4_transformations.R"
    , "data/rUtils/transformations/datetimes.R"
  )
)

#____________________________________________________
#### Create Targets ####
#____________________________________________________

list(
  
  #____________________________________________________
  #### Generate Raw Data and Clean ####
  #____________________________________________________
  tar_target(
      name = dataFromApiCall_raw
      # Capture 12 months of data from 311.
    , command = pipeline_extract_cartoDbMonthQuery("SELECT * FROM public_cases_fc WHERE CLOSED_DATETIME >= ")
      # Set this to always run.
    , cue = tarchetypes::tar_cue_age(
          name = dataFromApiCall_raw
        , age = as.difftime(7, units = "days")
    )
  ),
  
  tar_target(
      name = dataFromApiCall_columnsSet
    , command = clean_cartoDb_threeOneOne_data(dataFromApiCall_raw)
    # We're leaving this set to the default cue so it won't run if no
    # updates have been made to the data.
  ),
  
  # Step to run validation for unique IDs and complete request_date data.
  # Will drop rule breakers.
  tar_target(
      name    = dataFromApiCall_postExtractValidation
    , command = satisfying(
                    x = dataFromApiCall_columnsSet
                  , y = pipeline_validation_postExtract
    )
  ), 
  
  #____________________________________________________
  #### Additional Required Data Transformations ####
  #____________________________________________________
  
  # Add date, month, week fields for requested datetime and closed datetime
  tar_target(
    name    = dataFromApiCall_addRequestDateFields
    , command = createDatetimeFields(data = dataFromApiCall_postExtractValidation,
                                     field_datetime = 'requested_datetime')
  ), 
  
  tar_target(
    name    = dataFromApiCall_addClosedDateFields
    , command = createDatetimeFields(data = dataFromApiCall_addRequestDateFields,
                                     field_datetime = 'closed_datetime')
  ), 
  
  # Add Resolution Time Field
  tar_target(
    name    = dataFromApiCall_addTimeToResolve
    , command = pipeline_transformation__calculateResolutionTimeField(field_openDate = 'requested_datetime',
                                                                      field_closeDate = 'closed_datetime',
                                                                      data = dataFromApiCall_addClosedDateFields)
  ), 
  
  #____________________________________________________
  #### Run Repeat Calls Analysis ####
  #____________________________________________________
  
  
  ## Run Repeat Calls Analysis
  tar_target(
      name    = repeatCallsAnalysis_initialize
    , command = pipeline_transformation_generateRepeatCallGroupings(
          dataset        = dataFromApiCall_addTimeToResolve
        , field_orderBy  = "requested_datetime"
        , field_groupBy  = "address"
        , field_category = "subject"
    )
  )
  
  ##  Aggregate down to repeat call groups
  
  ##  join repeat call groups back to base data.
  
  #____________________________________________________
  #### Surface Datasets for BI ####
  #____________________________________________________
  , tar_target(
        name = dashboard__overallMetrics
      , command = pipeline_transformation__overallPageMetrics(
          dataset = dataFromApiCall_addTimeToResolve
      )
  )
  , tar_target(
        name = dashboard__weeklyAggregates
      , command = pipeline_transformation_generateWeeklyAggregates(
          dataset = dataFromApiCall_addTimeToResolve
      )
  )
  
  #____________________________________________________
  #### Build Run Doc. ####
  #____________________________________________________
  
  ## Generate Run Document
  , tar_render(
       name = renderQuartoRunDoc
     , path = "RunDoc.qmd"
  )
)
