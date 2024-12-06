devtools::load_all('../surveydown')
library(shiny)
library(leaflet)
library(bslib)

server <- function(input, output, session) {

  # Create the map container
  output$map_container <- renderUI({
    leafletOutput("map", height = "400px")
  })

  # Create the map
  output$map <- renderLeaflet({
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

  # Store the selected state as a reactive value
  selected_state <- reactiveVal("(choose a state)")

  # Update and store state whenever a state is clicked
  observeEvent(input$map_shape_click, {
    state_name <- input$map_shape_click$id
    if (!is.null(state_name)) {
      state_name <- stringr::str_to_title(state_name)
      state_name <- stringr::str_replace(state_name, ':main', '')

      # Update the selected state reactive value
      selected_state(state_name)

      # Store the state value
      sd_store_value(selected_state(), 'state')
    }
  })

  # Database designation and other settings
  sd_server(use_cookies = FALSE)
}

# shinyApp() initiates your app
shinyApp(ui = sd_ui(), server = server)
