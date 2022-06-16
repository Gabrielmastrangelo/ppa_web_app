library(shiny)
library("readxl")
library(lubridate)

# Function that gets the table that is updated by the python file.
get_table <- function(input_) {
  #Ignore the index column
  raw_data <- read_excel("data.xlsx", range = cell_cols(c("B","AE")))
  
  #This gets the datetime from Vancouver
  datetime_now <- with_tz(Sys.time(), tzone = "America/Vancouver")
  #I was told that all data they need is between 48 hours
  datetime_threshold <- datetime_now + hours(48)
  
  return(raw_data[raw_data[['Order Time']] <= datetime_threshold, ])
}

variable_names <- c('Status', 'Job PO', 'Job #', 'Vessel Name', 'Order Time', 'From', 'To', 'Agency', 'Tug From', 'Tug To', 'Pilot #1', 'Pilot #2', 'Job On Time', 'ETD', 'ETA', 'IMO', 'Call Sign', 'Vessel Type/Dock', 'Vessel Flag', 'LOA', 'GRT', 'Actual Draft', 'S. Draft', 'Beam', 'Max. Beam', 'Speed', 'Hellicopter from', 'Hellicopter to', 'Job Notes', 'Vessel Notes')


ui <- fluidPage(
  
  titlePanel("PPA Web Application"),
  
  sidebarLayout(
    
    sidebarPanel(
      selectInput("category", "Choose a category", 
                  c('Saam Towage', 'Seaspan', 'Group Ocean', 'Monitored Vessels')),
      selectInput(
        "variables", "Choose the columns?", variable_names,
        multiple = TRUE,
        selected = c('Vessel Name', 'Order Time', 'From', 'To', 'Agency', 'Tug From', 'Tug To', 'Job On Time')
        #width = 4
        ),
      actionButton("update", "Update Table")
    ),
    
    mainPanel(
      dataTableOutput("dynamic")
    ),
  )
)


server <- function(input, output) {
  
  # The table reads the file again for any interaction with the buttons
  data <- reactive({
    input$category
    input$update
    input$variables
    get_table()
    })
  
  output$dynamic <- renderDataTable(data()[input$variables], options = list(pageLength = 20))

}

shinyApp(ui = ui, server = server)
