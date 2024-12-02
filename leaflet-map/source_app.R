library(shiny)
library(leaflet)
library(bslib)

ui <- page_fluid(
  card(
    card_header("Where do you live?"),
    leafletOutput("map"),
    textOutput("selected_state")
  )
)

server <- function(input, output, session) {
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

  # Store the selected state
  selected_state <- reactiveVal("Choose the state you live in")

  # Update text when a state is clicked
  observeEvent(input$map_shape_click, {
    clicked_state <- input$map_shape_click$id
    if (!is.null(clicked_state)) {
      # Capitalize first letter of each word
      state_name <- gsub("\\b(\\w)", "\\U\\1", clicked_state, perl = TRUE)
      selected_state(paste("You live in", state_name))
    }
  })

  # Display the text
  output$selected_state <- renderText({
    selected_state()
  })
}

shinyApp(ui, server)