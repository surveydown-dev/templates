# Package setup ---------------------------------------------------------------

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


# Database setup --------------------------------------------------------------
#
# Details at: https://surveydown.org/manuals/storing-data
#
# surveydown stores data on any PostgreSQL database. We recommend
# https://supabase.com/ for a free and easy to use service.
#
# Once you have your database ready, run the following function to store your
# database configuration parameters in a local .env file:
#
# sd_db_config()
#
# Once your parameters are stored, you are ready to connect to your database.
# For this demo, we set ignore = TRUE in the following code, which will ignore
# the connection settings and won't attempt to connect to the database. This is
# helpful if you don't want to record testing data in the database table while
# doing local testing. Once you're ready to collect survey responses, set
# ignore = FALSE or just delete this argument.

db <- sd_db_connect(ignore = TRUE)


# Server setup ----------------------------------------------------------------

# Load state data from tigris - we do this outside of the server
# because we only need to do it once across all sessions
states <- tigris::states(cb = TRUE, resolution = "20m") |>
  dplyr::filter(STUSPS %in% state.abb) |>
  sf::st_transform(4326)

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

  # Other surveydown settings
  sd_server(
    db = db,
    use_cookies = FALSE,
    all_questions_required = TRUE
  )
}

# shinyApp() initiates your app - don't change it
shiny::shinyApp(ui = sd_ui(), server = server)
