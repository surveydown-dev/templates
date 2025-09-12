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
  # Used for case 5
  # Custom function to check if pet number input is > 1
  more_than_one_pet <- function(input) {
    if (is.null(input$pet_number)) {
      return(FALSE)
    }
    num_pets <- as.numeric(input$pet_number)
    return(num_pets > 1)
  }

  # Define any conditional showing logic here (show a question if a condition is true)
  sd_show_if(
    # 1. Simple conditional showing
    input$penguins_simple == "other" ~ "penguins_simple_other",

    # 2. Complex conditional showing
    input$penguins_complex == "other" &
      input$show_other == "show" ~
      "penguins_complex_other",

    # 3. Conditional showing based on a numeric value
    as.numeric(input$car_number) > 1 ~ "ev_ownership",

    # 4. Conditional showing based on multiple inputs
    input$fav_fruits %in% c("apple", "banana") ~ "apple_or_banana",
    length(input$fav_fruits) > 3 ~ "fruit_number",

    # 5. Conditional showing based on a custom function
    more_than_one_pet(input) ~ "pet_type",

    # 6. Conditional page showing
    input$pet_preference == 'cat' ~ 'cat_page',
    input$pet_preference == 'dog' ~ 'dog_page'
  )

  # Run surveydown server and define database
  sd_server(db = db)
}

# Launch the app
shiny::shinyApp(ui = ui, server = server)
