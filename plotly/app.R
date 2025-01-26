# remotes::install_github("surveydown-dev/surveydown", force = TRUE)
library(surveydown)
library(shiny)
library(plotly)

# Database Setup

# Run sd_db_config() once to set up Supabase credentials.
# sd_db_config()

# Connect with Supabase and store instance into db
# Turn ignore to FALSE to connect to your Supabase
db <- sd_db_connect(
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

  # Server Settings
  sd_server(
    db = db
  )
}

# Launch Survey
shiny::shinyApp(ui = sd_ui(), server = server)
