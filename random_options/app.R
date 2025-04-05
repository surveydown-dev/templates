# Package setup ---------------------------------------------------------------

# Install required packages:
# install.packages("pak")
# pak::pak("surveydown")

# Load packages
library(surveydown)

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

# UI setup --------------------------------------------------------------------

ui <- sd_ui()

# Server setup ----------------------------------------------------------------

server <- function(input, output, session) {

  # Create a vector of options
  q1_options <- c('option 1', 'option 2', 'option 3')

  # Randomly sample 3 values from 1 to 100
  q1_values <- sample(seq(100), 3)

  # The values are assigned to the names() of the options vector,
  # so the options will be shown to the user as these values.
  names(q1_options) <- q1_values

  # Store the values in the database
  sd_store_value(q1_values, id = "q1_values")

  # Create a reactive question
  sd_question(
    id     = "q1",
    type   = "mc",
    label  = "Which of these numbers is the largest?",
    option = q1_options
  )

  # Database designation and other settings
  sd_server(
    db = db,
    all_questions_required = TRUE
  )

}

# Launch the app
shiny::shinyApp(ui = ui, server = server)
