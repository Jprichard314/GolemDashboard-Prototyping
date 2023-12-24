# Shiny Server



server <- function(input, output)
{
  #_____________________________________________________________________________
  #### Generate Datasets
  #_____________________________________________________________________________
  
  # Overall Page Data,  these don't need to be reactive.
  data__overall_keyIndicators <- getDataForOverallPages(dataFromApiCall_postExtractValidation)
  
  #_____________________________________________________________________________
  #### Overall Page
  #_____________________________________________________________________________
  
  # visual: total closed, 12 months
  output$v__overall_twelveMonthsClosed <- renderText({
                  format(data__overall_keyIndicators$totalCalls, 
                         big.mark = ",",
                         scientific = FALSE
           )})
  
  
  
  
  
  
  
  
  
}