# Install required packages:
# install.packages("pak")
# pak::pak('surveydown-dev/surveydown') # Development version from github

# Load packages
library(surveydown)

# Database Setup

# Run sd_db_config() once to set up Supabase credentials.
# sd_db_config()

# Connect with Supabase and store instance into db
# Turn ignore to FALSE to connect to your Supabase
db <- sd_db_connect(
  ignore = TRUE
)

# Server Setup
server <- function(input, output, session) {

  # Create a vector of options
  q1_options <- c('option 1', 'option 2', 'option 3')

  # Randomly sample 3 labels from 1 to 100
  q1_labels <- sample(seq(100), 3)

  # Assign the labels to the options
  names(q1_options) <- q1_labels

  # Store the labels in the database
  sd_store_value(q1_labels, id = "q1_labels")

  # Create a reactive question
  sd_question(
    id     = "q1",
    type   = "mc",
    label  = "Which of these numbers is the largest?",
    option = q1_options
  )

  # Server Settings
  sd_server(
    db = db,
    all_questions_required = TRUE
  )

}

# Launch Survey
shiny::shinyApp(ui = sd_ui(), server = server)
