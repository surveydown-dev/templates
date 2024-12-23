# Install required packages:
# install.packages('surveydown')

# Load packages
library(surveydown)

# ---------------------------------------------------------------------
# Database setup - details at https://surveydown.org/database-config.html

# surveydown stores data in a PostgreSQL database. We recommend
# https://supabase.com/ for a free and easy to use service.
#
# Open the 'config.R' file to set up your database connection settings
# You only need to do this once.
#
# For testing, use ignore = TRUE to save data locally instead of to the database
db <- sd_db_connect(ignore = TRUE)

# When ready to store data in the database, use:
# db <- sd_db_connect()
#
# You can also connect to a different table in the database, e.g.:
# db <- sd_db_connect(table = "responses_test")
# ---------------------------------------------------------------------

# Server setup
server <- function(input, output, session) {

  # Define any conditional skip logic here (skip to page if a condition is true)
  sd_skip_if(
    input$vehicle_simple == "no" ~ "screenout",
    input$vehicle_complex == "no" &
      input$buy_vehicle == "no" ~ "screenout"

  )

  # Other settings
  sd_server(
    db = db,
    all_questions_required = TRUE
  )

}

# shinyApp() initiates your app - don't change it
shiny::shinyApp(ui = sd_ui(), server = server)
