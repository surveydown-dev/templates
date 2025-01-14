# Install required packages:
# install.packages("pak")
# pak::pak(c(
#   'surveydown-dev/surveydown', # <- Development version from github
#   'shiny',
#   'sf',
#   'tigris',
#   'leaflet',
#   'dplyr'
# ))

# Load packages
library(surveydown)
library(sf)
library(shiny)
library(tigris)
library(leaflet)
library(dplyr)

# Database Setup
# sd_db_config
# db <- sd_db_connect()

# Load state data from tigris - we do this outside of the server
# because we only need to do it once across all sessions
states <- tigris::states(cb = TRUE, resolution = "20m") |>
  dplyr::filter(STUSPS %in% state.abb) |>
  sf::st_transform(4326)

# Server Setup
server <- function(input, output, session) {

  # Helper function for modifying the leaflet map layout
  map_layout <- function(map, states, selected_state = NULL) {

    # Set the state fill colors
    color <- "lightblue"
    if (!is.null(selected_state)) {
      color <- ifelse(states$NAME == selected_state, "orange", "lightblue")
    }

    # Update the polygons
    addPolygons(
      map,
      data = states,
      fillColor = color,
      weight = 2,
      opacity = 1,
      color = "white",
      fillOpacity = 0.7,
      layerId = states$NAME,
      highlight = highlightOptions(
        weight = 3,
        color = "#666",
        fillOpacity = 0.7,
        bringToFront = TRUE
      ),
      label = ~NAME,
      labelOptions = labelOptions(
        style = list(
          padding = "3px 8px",
          "background-color" = "rgba(255,255,255,0.8)"
        ),
        textsize = "15px"
      )
    )
  }

  # Create the main leaflet map widget
  output$usa_map <- renderLeaflet({
    leaflet(options = leafletOptions(preferCanvas = TRUE)) |>
      addTiles() |>
      setView(lng = -98.5795, lat = 39.8283, zoom = 4) |>
      map_layout(states)
  })

  # Reactive value storing selected state
  selected_state <- reactiveVal(NULL)

  # Click observer - runs when you click on a state
  observeEvent(input$usa_map_shape_click, {
    click <- input$usa_map_shape_click
    if (!is.null(click)) {
      state_name <- click$id

      # Update reactive value with selected state
      selected_state(state_name)

      # Update the map widget
      leafletProxy("usa_map") |>
        map_layout(states, state_name)
    }
  })

  # Create question to store the selected state in resulting survey data
  sd_question_custom(
    id = "state_selection",
    label = "Click on the state you live in:",
    # The output is the output widget - here we use leafletOutput()
    output = leafletOutput("usa_map", height = "400px"),
    # The value is the reactive value that will be stored in the data
    value = selected_state
  )

  # Server Settings
  sd_server(
    db = NULL
  )
}

# Launch Survey
shiny::shinyApp(ui = sd_ui(), server = server)
