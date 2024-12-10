# remotes::install_github("surveydown-dev/surveydown", force = TRUE)
library(surveydown)
library(shiny)
library(leaflet)
library(bslib)

# Database setup

# surveydown stores data on a database that you define at https://supabase.com/
# To connect to a database, update the sd_database() function with details
# from your supabase database. For this demo, we set ignore = TRUE, which will
# ignore the settings and won't attempt to connect to the database. This is
# helpful for local testing if you don't want to record testing data in the
# database table. See the documentation for details:
# https://surveydown.org/store-data

db <- sd_database(
  host   = "",
  dbname = "",
  port   = "",
  user   = "",
  table  = "",
  ignore = TRUE
)

server <- function(input, output, session) {

  # Reactive value of states
  states <- reactiveVal(maps::map("state", plot = FALSE, fill = TRUE))

  # Define question
  sd_question(
    type     = "leaflet",
    id       = "state_you_live",
    label    = "Click on the state you live in:",
    map_name = "usa",
    map_data = states
  )

  # Create map
  output$usa <- renderLeaflet({

    # Create the objects
    map <- leaflet() %>%
      addTiles() %>%
      setView(lng = -98.5795, lat = 39.8283, zoom = 4)
    area <- states()
    color <- rep("orange", length(area$names))

    # Define and call map_layout()
    map_layout <- session$userData$usa_layout
    map_layout(
      map   = map,
      area  = area,
      color = color
    )
  })

  # Database designation and other settings
  sd_server(
    db = db
  )
}

# shinyApp() initiates your app - don't change it
shiny::shinyApp(ui = sd_ui(), server = server)
