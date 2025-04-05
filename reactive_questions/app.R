# Package setup ---------------------------------------------------------------

# Install required packages:
# install.packages("pak")
# pak::pak('surveydown-dev/surveydown') # Development version from github

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
  observe({
    pet_type <- input$pet_type

    # Make the question label and options
    label <-glue::glue("Are you a {pet_type} owner?")
    options <- c('yes', 'no')
    names(options)[1] <- glue::glue("Yes, am a {pet_type} owner")
    names(options)[2] <- glue::glue("No, I am not a {pet_type} owner")

    # Make the question
    sd_question(
      type   = "mc",
      id     = "pet_owner",
      label  = label,
      option = options
    )
  })

  # Only show the pet_owner question if pet_type is answered
  sd_show_if(
    !is.null(input$pet_type) ~ "pet_owner"
  )

  # Database designation and other settings
  sd_server(
    db = db,
    all_questions_required = TRUE
  )
}

# Launch the app
shiny::shinyApp(ui = ui, server = server)
