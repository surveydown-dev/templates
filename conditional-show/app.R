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


# Server setup ----------------------------------------------------------------

server <- function(input, output, session) {

  # Define any conditional display logic here (show a question if a condition is true)
  sd_show_if(

    # Simple Conditional Display
    input$penguins_simple == "other" ~ "penguins_simple_other",

    # Complex Conditional Display
    input$penguins_complex == "other" &
      input$show_other == "show" ~ "penguins_complex_other",

    # Conditional display based on a numeric value
    as.numeric(input$car_number) > 1 ~ "ev_ownership",

    # Conditional display based on multiple inputs
    input$fav_fruits %in% c("apple", "banana") ~ "apple_or_banana",
    length(input$fav_fruits) > 3 ~ "fruit_number"
  )

  # Database designation and other settings
  sd_server(
    db = db,
    all_questions_required = TRUE
  )
}

# shinyApp() initiates your app - don't change it
shiny::shinyApp(ui = sd_ui(), server = server)
