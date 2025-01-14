# Install required packages:
# install.packages("pak")
# pak::pak(c(
#   'surveydown-dev/surveydown', # <- Development version from github
#   'here',
#   'glue',
#   'readr',
#   'dplyr',
#   'kableExtra'
# ))

# Load packages
library(surveydown)
library(dplyr)
library(readr)
library(glue)
library(here)
library(kableExtra)

# Database Setup
# sd_db_config
# db <- sd_db_connect()

# Server Setup
server <- function(input, output, session) {

  # Make a 10-digit random number completion code
  completion_code <- sd_completion_code(10)

  # Store the completion code in the survey data
  sd_store_value(completion_code)

  # Read in the full survey design file
  design <- read_csv(here("data", "choice_questions.csv"))

  # Sample a random respondentID and store it in your data
  respondentID <- sample(design$respID, 1)
  sd_store_value(respondentID, "respID")

  # Filter for the rows for the chosen respondentID
  df <- design %>%
    filter(respID == respondentID) %>%
    # Paste on the "images/" path (images are stored in the "images" folder)
    mutate(image = paste0("images/", image))

  # Function to create the options table for a given choice question
  make_cbc_table <- function(df) {
    alts <- df %>%
      mutate(
        price = paste(scales::dollar(price), "/ lb"),
        image = paste0('<img src="', image, '" width=100>')) %>%
      # Make nicer attribute labels
      select(
        `Option:` = altID,
        ` ` = image,
        `Price:` = price,
        `Type:` = type,
        `Freshness:` = freshness)
    row.names(alts) <- NULL # Drop row names

    table <- kbl(t(alts), escape = FALSE) %>%
      kable_styling(
        bootstrap_options = c("striped", "hover", "condensed"),
        full_width = FALSE,
        position = "center"
      )
    function() { table }
  }

  # Create the options for each choice question
  output$cbc1_table <- make_cbc_table(df |> filter(qID == 1))
  output$cbc2_table <- make_cbc_table(df |> filter(qID == 2))
  output$cbc3_table <- make_cbc_table(df |> filter(qID == 3))
  output$cbc4_table <- make_cbc_table(df |> filter(qID == 4))
  output$cbc5_table <- make_cbc_table(df |> filter(qID == 5))
  output$cbc6_table <- make_cbc_table(df |> filter(qID == 6))

  # Skip Logic
  sd_skip_if(
    input$screenout == "blue" ~ "end_screenout",
    input$consent_age == "no" ~ "end_consent",
    input$consent_understand == "no" ~ "end_consent"
  )

  # Conditional Display
  sd_show_if(
    input$like_fruit %in% c("yes", "kind_of") ~ "fav_fruit"
  )

  # Server Settings
  sd_server(
    db = NULL,
    auto_scroll = TRUE,
    rate_survey = TRUE
  )

}

# shinyApp() initiates your app - don't change it
shiny::shinyApp(ui = sd_ui(), server = server)
