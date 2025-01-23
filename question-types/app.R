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

  # Skip Logic
  sd_skip_if(
    input$skip_to_page == "end" ~ "end",
    input$skip_to_page == "question_formatting" ~ "question_formatting"
  )

  # Server Settings
  sd_server(
    db = db,
    auto_scroll = TRUE,
    rate_survey = TRUE
  )

}

# Launch Survey
shiny::shinyApp(ui = sd_ui(), server = server)
