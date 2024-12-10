# remotes::install_github("surveydown-dev/surveydown", force = TRUE)
devtools::load_all("../../surveydown")
# library(surveydown)
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

  # Reactive value of states_data
  states_data <- reactiveVal(maps::map("state", plot = FALSE, fill = TRUE))

  # Define question
  sd_question(
    type     = "leaflet",
    id       = "where_do_you_live",
    label    = "Click on the state you live in:",
    map_name = "usa_map",
    map_data = states_data
  )

  # Create the map
  output$usa_map <- renderLeaflet({
    states <- states_data()
    leaflet() %>%
      addTiles() %>%
      setView(lng = -98.5795, lat = 39.8283, zoom = 4) %>%
      addPolygons(
        data = states,
        fillColor = "lightblue",
        weight = 2,
        opacity = 1,
        color = "white",
        fillOpacity = 0.7,
        highlightOptions = highlightOptions(
          weight = 3,
          color = "#666",
          fillOpacity = 0.7,
          bringToFront = TRUE
        ),
        group = "states",
        layerId = states$names
      )
  })

  # Database designation and other settings
  sd_server(
    db = db
  )
}

# shinyApp() initiates your app - don't change it
shiny::shinyApp(ui = sd_ui(), server = server)
