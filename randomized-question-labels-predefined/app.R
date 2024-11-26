# remotes::install_github("surveydown-dev/surveydown", force = TRUE)
library(surveydown)
library(here)
library(dplyr)

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

# Server setup
server <- function(input, output, session) {

  # Read in the design file
  design <- readr::read_csv(here("data", "design.csv"))

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

# shinyApp() initiates your app - don't change it
shiny::shinyApp(ui = sd_ui(), server = server)
