# Shiny Server



server <- function(input, output)
{
  #_____________________________________________________________________________
  #### Generate Datasets ####
  #_____________________________________________________________________________
  
  # Overall Page Data,  these don't need to be reactive.
  data__overall_keyIndicators <- getDataForOverallPages(dataFromApiCall_postExtractValidation)
  
  #_____________________________________________________________________________
  #### Overall Page ####
  #_____________________________________________________________________________
  
  
  #### Visual: Total Closed. ####
  
  # visual: total clsoed, text output
  output$overall_twelveMonthClose$text <- renderText({
                  format(data__overall_keyIndicators$totalCalls, 
                         big.mark = ",",
                         scientific = FALSE
           )})
  
  
  # visual: Total Closed, 12 months, background plot 
  output$overall_twelveMonthClose$backgroundplot <- renderPlot({
    plotly::plot_ly(x = )
  })
}