# remotes::install_github("surveydown-dev/surveydown", force = TRUE)
library(surveydown)
library(sf)
library(shiny)
library(tigris)
library(leaflet)

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
  # States data from tigris
  states <- tigris::states(cb = TRUE, resolution = "20m") %>%
    dplyr::filter(STUSPS %in% state.abb) %>%
    sf::st_transform(4326)

  # Helper function for map layout
  map_layout <- function(map, states, selected_state = NULL) {
    addPolygons(
      map,
      data = states,
      fillColor = if (is.null(selected_state)) {
        "lightblue"
      } else {
        ifelse(states$NAME == selected_state, "orange", "lightblue")
      },
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
        style = list(padding = "3px 8px",
                     "background-color" = "rgba(255,255,255,0.8)"),
        textsize = "15px"
      )
    )
  }

  # Leaflet map widget
  output$usa_map <- renderLeaflet({
    leaflet(options = leafletOptions(preferCanvas = TRUE)) %>%
      addTiles() %>%
      setView(lng = -98.5795, lat = 39.8283, zoom = 4) %>%
      map_layout(states)
  })

  # Reactive value storing selected state
  selected_state <- reactiveVal(NULL)

  # Click observer
  observeEvent(input$usa_map_shape_click, {
    click <- input$usa_map_shape_click
    if (!is.null(click)) {
      state_name <- click$id
      selected_state(state_name)
      leafletProxy("usa_map") %>%
        map_layout(states, state_name)
    }
  })

  # Create question using sd_question_custom()
  sd_question_custom(
    id = "state_selection",
    label = "Click on the state you live in:",
    output = leafletOutput("usa_map", height = "400px"),
    value = selected_state
  )

  # Database designation and other settings
  sd_server(
    db = db,
    use_cookies = FALSE,
    all_questions_required = TRUE
  )
}

# shinyApp() initiates your app - don't change it
shiny::shinyApp(ui = sd_ui(), server = server)
