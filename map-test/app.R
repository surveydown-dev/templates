# remotes::install_github("surveydown-dev/surveydown", force = TRUE)
# library(surveydown)
devtools::load_all("../../surveydown")
library(shiny)
library(leaflet)
library(bslib)

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

server <- function(input, output, session) {

  # Define question
  # The leaflet type can ONLY be defined here in app.R due to reactivity.
  sd_question(
    type     = "leaflet",
    id       = "state_you_live",
    label    = "Click on the state you live in:",
    map      = maps::map("state", plot = FALSE, fill = TRUE),
    lng      = -98.5795,
    lat      = 39.8283,
    zoom     = 4,
    color    = "lightblue"
  )

  # Database designation and other settings
  sd_server(
    db = db
  )
}

# shinyApp() initiates your app - don't change it
shiny::shinyApp(ui = sd_ui(), server = server)
