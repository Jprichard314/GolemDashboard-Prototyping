# ui script

uiConfigs <- config::get(file = "R/2_1_uiElements.yml")

ui <- (
  bslib::page_navbar(
    title = "Philadelphia 311 Calls",
    bg = uiConfigs$colors$darkbenFranklinBlue$hex,
    bslib::layout_columns(
      col_widths = c(
        6,6,
        12,
        2, 4, 2, 4
      ),
      row_heights = c(1,3,1),
      bslib::card(
        bslib::card_body(tags$h1("Calls over the Past 6 Months"))
      ),
      bslib::card(bslib::card_body(tags$h1("This Month vs Last"))),
      bslib::card(bslib::card_body(tags$h1("Trending"))),
      bslib::card(bslib::card_body(tags$h1("Most Common Servicer"))),
      bslib::card(bslib::card_body(tags$h1("Bar Chart"))),
      bslib::card(bslib::card_body(tags$h1("Most Common Service"))),
      bslib::card(bslib::card_body(tags$h1("Bar Chart")))
      
    )
  )
)