# remotes::install_github("surveydown-dev/surveydown", force = TRUE)
library(surveydown)

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

# Server setup
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
