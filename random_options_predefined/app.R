# Package setup ---------------------------------------------------------------

# Install required packages:
# install.packages("pak")
# pak::pak(c(
#   'surveydown-dev/surveydown', # Development version from GitHub
#   'readr',
#   'dplyr'
# ))

# Load packages
library(surveydown)
library(dplyr)
library(readr)

# Database setup --------------------------------------------------------------
#
# Details at: https://surveydown.org/docs/storing-data
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

  # Read in the design file (generated in the 'make-design.R' file)
  design <- read_csv("design.csv")

  # Randomly choose a row id
  q1_id <- sample(design$id, 1)

  # Store the chosen row id in the survey data (here q1_id will be the column name)
  sd_store_value(q1_id)

  # Filter the design to get the chosen row
  numbers <- design |>
    filter(id == q1_id) |>
    pull(numbers)

  # Create the options
  q1_options <- c('option 1', 'option 2', 'option 3')
  names(q1_options) <- numbers

  # Create the reactive question
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
