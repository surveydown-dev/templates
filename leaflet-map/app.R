# remotes::install_github("surveydown-dev/surveydown", ref = "resuming", force = TRUE)
# library(surveydown)
devtools::load_all("../../surveydown")
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
  # Interactive question with custom type
  sd_question(
    type   = "custom",
    id     = "map_usa",
    label  = "Click on the state you live in:",
    option = maps::map("state", plot = FALSE)$names
  )

  # Reactive value storing state selection
  selected_state <- reactiveVal("(choose a state)")

  # Create the map
  output$map_usa_map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      setView(lng = -98.5795, lat = 39.8283, zoom = 4) %>%
      addPolygons(
        data = maps::map("state", plot = FALSE, fill = TRUE),
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
        layerId = maps::map("state", plot = FALSE)$names
      )
  })

  # Click observer
  observeEvent(input$map_usa_map_shape_click, {
    state_name <- input$map_usa_map_shape_click$id
    if (!is.null(state_name)) {
      state_name <- stringr::str_to_title(state_name)
      state_name <- stringr::str_replace(state_name, ':main', '')
      selected_state(state_name)
      shiny::updateTextInput(session, "map_usa", value = state_name)
      shiny::updateTextInput(session, "map_usa_interacted", value = TRUE)
    }
  })

  # Database designation and other settings
  sd_server(
    db = db,
    use_cookies = FALSE
  )
}

# shinyApp() initiates your app - don't change it
shiny::shinyApp(ui = sd_ui(), server = server)
