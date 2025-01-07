# remotes::install_github("surveydown-dev/surveydown", force = TRUE)
library(surveydown)
library(shiny)
library(plotly)

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

# Example with plotly
server <- function(input, output, session) {

  # Create plotly output
  output$scatter_plot <- renderPlotly({
    plot_ly(mtcars, x = ~wt, y = ~mpg,
            type = "scatter",
            mode = "markers",
            source = "scatter_plot") %>%  # Add source identifier
      layout(dragmode = "select")         # Enable point selection
  })

  # Reactive value for selected point
  selected_point <- reactiveVal(NULL)

  # Click observer - update selected_point with the chosen point
  observeEvent(event_data("plotly_click", source = "scatter_plot"), {
    click <- event_data("plotly_click", source = "scatter_plot")
    if (!is.null(click)) {
      selected_point(sprintf("Weight: %0.1f, MPG: %0.1f", click$x, click$y))
    }
  })

  # Create the widget question
  sd_question_custom(
    id = "point_selection",
    label = "Click on a point in the scatter plot:",
    output = plotlyOutput("scatter_plot", height = "400px"),
    value = selected_point
  )

  sd_server(db = db, use_cookies = FALSE)
}

# shinyApp() initiates your app - don't change it
shiny::shinyApp(ui = sd_ui(), server = server)
