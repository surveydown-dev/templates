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

  # Conditional Display
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

  # Server Settings
  sd_server(
    db = db,
    all_questions_required = TRUE
  )
}

# Launch Survey
shiny::shinyApp(ui = sd_ui(), server = server)
