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
    input$skip_to_page == "end" ~ "end",
    input$skip_to_page == "question_formatting" ~ "question_formatting"
  )

  # Server Settings
  sd_server(
    db = NULL,
    auto_scroll = TRUE,
    rate_survey = TRUE
  )

}

# Launch Survey
shiny::shinyApp(ui = sd_ui(), server = server)
