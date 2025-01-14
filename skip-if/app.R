# Install required packages:
# install.packages("pak")
# pak::pak('surveydown-dev/surveydown') # Development version from github

# Load packages
library(surveydown)

# Database Setup
# sd_db_config
# db <- sd_db_connect()

# Server Setup
server <- function(input, output, session) {

  # Skip Logic
  sd_skip_if(
    input$vehicle_simple == "no" ~ "screenout",
    input$vehicle_complex == "no" &
      input$buy_vehicle == "no" ~ "screenout"

  )

  # Server Settings
  sd_server(
    db = db,
    all_questions_required = TRUE
  )

}

# Launch Survey
shiny::shinyApp(ui = sd_ui(), server = server)
