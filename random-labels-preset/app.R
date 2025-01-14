# Install required packages:
# install.packages("pak")
# pak::pak(c(
#   'surveydown-dev/surveydown', # <- Development version from github
#   'readr',
#   'dplyr'
# ))

# Load packages
library(surveydown)
library(dplyr)
library(readr)

# Database Setup
# sd_db_config
# db <- sd_db_connect()

# Server Setup
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

  # Server Settings
  sd_server(
    db = NULL,
    all_questions_required = TRUE
  )

}

# Launch Survey
shiny::shinyApp(ui = sd_ui(), server = server)
