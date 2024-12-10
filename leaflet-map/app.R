# remotes::install_github("surveydown-dev/surveydown", force = TRUE)
library(surveydown)
library(shiny)
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

# Obtain the map data (state names and shape data)
states <- maps::map("state", plot = FALSE, fill = TRUE)

# Set the highlight options
highlightOptions <- highlightOptions(
  weight = 3,
  color = "#666",
  fillOpacity = 0.7,
  bringToFront = TRUE
)

server <- function(input, output, session) {

    # Create leaflet map widget
    output$usa_map <- renderLeaflet({
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
                highlightOptions = highlightOptions,
                layerId = states$names
            )
    })

    # Create a reactive value for storing the selected state
    selected_state <- reactiveVal(NULL)

    # Observer that runs whenever you click on the map
    observeEvent(input$usa_map_shape_click, {
        click <- input$usa_map_shape_click
        if (!is.null(click)) {
            # Get the state name from the click
            state_name <- stringr::str_to_title(click$id)
            state_name <- stringr::str_replace(state_name, ':main', '')

            # Update the reactive value with the chosen on state name
            selected_state(state_name)

            # Update map colors
            leafletProxy("usa_map") %>%
                addPolygons(
                    data = states,
                    fillColor = ifelse(states$names == click$id, "orange", "lightblue"),
                    weight = 2,
                    opacity = 1,
                    color = "white",
                    fillOpacity = 0.7,
                    highlightOptions = highlightOptions,
                    layerId = states$names
                )
        }
    })

    # Create the custom question to display the leaflet widget and store the
    # selected state name in the data
    sd_question_custom(
        id = "state_selection",
        label = "Click on the state you live in:",
        output = leafletOutput("usa_map", height = "400px"),
        value = selected_state
    )

    sd_server(db = db, use_cookies = FALSE, all_questions_required = T)
}

# shinyApp() initiates your app - don't change it
shiny::shinyApp(ui = sd_ui(), server = server)
