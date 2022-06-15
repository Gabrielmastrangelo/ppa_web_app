library(shiny)
library("readxl")
library(lubridate)

#Ignore the index column
raw_data <- read.csv("data.csv")

#Printing in the log
cat(file=stderr(), paste0("Raw Data:", "\n", head(raw_data), "\n"))

#This gets the datetime from Vancouver
datetime_now <- with_tz(Sys.time(), tzone = "America/Vancouver")
#I was told that all data they need is between 48 hours
datetime_threshold <- datetime_now + hours(48)

#Printing in the log
cat(file=stderr(), paste0("Datetime Threshold", datetime_threshold, "\n"))

data<- raw_data[raw_data[['Order Time']] <= datetime_threshold, ]

#Printing in the log
cat(file=stderr(), paste0("Data:", "\n", head(data), "\n"))

ui <- fluidPage(
  
  titlePanel("PPA Web Application"),
  
  sidebarLayout(
    
    sidebarPanel(
      selectInput("category", "Choose a category", 
                  c('Saam Towage', 'Seaspan', 'Group Ocean', 'Monitored Vessels')),
      selectInput(
        "variables", "Choose the columns?", names(data),
        multiple = TRUE,
        selected = c('Vessel Name', 'Order Time', 'From', 'To', 'Agency', 'Tug From', 'Tug To', 'Job On Time')
        #width = 4
        )
      
    ),
    
    mainPanel(
      dataTableOutput("dynamic"),
      textOutput("text")
    )
    
  )
)



server <- function(input, output) {
  output$dynamic <- renderDataTable(data[input$variables], options = list(pageLength = 20))
  
}

shinyApp(ui = ui, server = server)



