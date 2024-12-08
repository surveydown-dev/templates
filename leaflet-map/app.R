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

  # LEAFLET MAP

  # Interactive question with custom type
  sd_question(
    type   = "custom",
    id     = "map_of_usa",
    label  = "Click on the state you live in:",
    option = leafletOutput("usa_map", height = "400px")
  )

  # Reactive value storing state selection
  selected_state <- reactiveVal("(choose a state)")

  # Create the map
  output$usa_map <- renderLeaflet({
    states <- maps::map("state", plot = FALSE, fill = TRUE)
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

  # Click observer
  observeEvent(input$usa_map_shape_click, {
    state_name <- input$usa_map_shape_click$id
    if (!is.null(state_name)) {
      state_name <- stringr::str_to_title(state_name)
      state_name <- stringr::str_replace(state_name, ':main', '')
      selected_state(state_name)
      shiny::updateTextInput(session, "map_of_usa", value = state_name)
      shiny::updateTextInput(session, "map_of_usa_interacted", value = TRUE)

      # Update map colors
      states <- maps::map("state", plot = FALSE, fill = TRUE)
      leafletProxy("usa_map") %>%
        addPolygons(
          data = states,
          fillColor = ifelse(
            states$names == input$usa_map_shape_click$id,
            "orange",
            "lightblue"
          ),
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
          layerId = states$names
        )
    }
  })

  # GENERALIZED CUSTOM QUESTION

  sd_question(
    type    = "custom",
    id      = "custom_input",
    label   = "Some custom input:",
    option  = tags$div(
      class = "my-custom-input",
      "Custom content here"
    )
  )

  # Database designation and other settings
  sd_server(
    db = db,
    use_cookies = FALSE
  )
}

# shinyApp() initiates your app - don't change it
shiny::shinyApp(ui = sd_ui(), server = server)
