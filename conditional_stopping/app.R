# Package setup ---------------------------------------------------------------

# Install required packages:
# install.packages("pak")
# pak::pak("surveydown-dev/surveydown") # Development version from GitHub

# Load packages
library(surveydown)

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
  # The conditional stopping logic stops the navigation if a condition is true,
  # and displays a message.
  sd_stop_if(
    # Here we have 3 conditions to check. The first 2 are on page1, and the last
    # is on page2. There is no need to specify which page the conditions are at.
    # If the conditions are on the same page, the messages will be shown together.

    # The zip question only accepts a 5-digit response
    nchar(input$zip) != 5 ~ "Zip code must be 5 digits.",

    # The year of birth question only accepts a year after 1900
    as.numeric(input$yob) <= 1900 ~ "Year of birth must be after 1900.",

    # The phone number question only accepts a 10-digit response
    nchar(input$phone) != 10 ~ "Phone number must be 10 digits."
  )

  # Run surveydown server and define database
  sd_server(db = db)
}

# Launch the app
shiny::shinyApp(ui = ui, server = server)
