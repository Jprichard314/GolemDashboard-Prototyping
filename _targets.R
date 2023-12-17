# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline


#____________________________________________________
#### Load Libraries ####
#____________________________________________________
source("R/0_libraries.R")


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
      "R/rUtils/dataCapture/apis.R"
    , "R/2_cleaning.R"
    , "R/1_importData.R"
    , "R/3_validators.R"
    , "R/4_transformations.R"
  )
)

#____________________________________________________
#### Create Targets ####
#____________________________________________________

list(
  tar_target(
      name = dataFromApiCall_raw
      # Capture 12 months of data from 311.
    , command = pipeline_extract_cartoDbMonthQuery("SELECT * FROM public_cases_fc WHERE CLOSED_DATETIME >= ")
      # Set this to always run.
    , cue = tar_cue(mode = 'always')
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
  
  ## Run Repeat Calls Analysis
  tar_target(
      name    = repeatCallsAnalysis_initialize
    , command = pipeline_transformation_generateRepeatCallGroupings(
          dataset        = dataFromApiCall_postExtractValidation
        , field_orderBy  = "requested_datetime"
        , field_groupBy  = "address"
        , field_category = "subject"
    )
  )
  
  ##  Aggregate down to repeat call groups
  
  ##  join repeat call groups back to base data.
  
  ## Generate Run Document
  , tar_render(
       name = renderQuartoRunDoc
     , path = "RunDoc.qmd"
  )
)
