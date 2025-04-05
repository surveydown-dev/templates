# Package setup ---------------------------------------------------------------

# Install required packages:
# install.packages("pak")
# pak::pak(c(
#   'surveydown',
#   'tidyverse'
# ))

# Load packages
library(surveydown)
library(tidyverse)

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

# Set up car options data frame

cars <- mpg |>
  distinct(make = manufacturer, model) |>
  mutate(
    make = str_to_title(make),
    model = str_to_title(model)
  )

# UI setup --------------------------------------------------------------------

ui <- sd_ui()

# Server setup ----------------------------------------------------------------

server <- function(input, output, session) {

  makes <- unique(cars$make)
  names(makes) <- makes

  sd_question(
    type   = "select",
    id     = "make",
    label  = "Make:",
    option = makes
  )

  observe({
    make_selected_df <- cars[which(input$make == cars$make),]
    models <- make_selected_df$model
    names(models) <- models

    sd_question(
      type   = "select",
      id     = "model",
      label  = "Model:",
      option = models
    )
  })

  # Database designation and other settings
  sd_server(
    db = db,
    all_questions_required = TRUE
  )
}

# Launch the app
shiny::shinyApp(ui = ui, server = server)
