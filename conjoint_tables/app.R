# Package setup ---------------------------------------------------------------

# Install required packages:
# install.packages("pak")
# pak::pak(c(
#   'surveydown-dev/surveydown', # Development version from GitHub
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
  # Make a 10-digit random number completion code
  completion_code <- sd_completion_code(10)
  sd_store_value(completion_code)

  # Read in the full survey design file
  design <- read_csv(here("data", "choice_questions.csv"))

  # Sample a random respondentID and store it in your data
  respondentID <- sample(design$respID, 1)
  sd_store_value(respondentID, "respID")

  # Filter for the rows for the chosen respondentID
  df <- design |>
    filter(respID == respondentID) |>
    # Paste on the "images/" path (images are stored in the "images" folder)
    mutate(image = paste0("images/", image))

  # Function to create the options table for a given choice question
  make_cbc_table <- function(df) {
    alts <- df |>
      mutate(
        price = paste(scales::dollar(price), "/ lb"),
        image = paste0('<img src="', image, '" width=100>')
      ) |>
      # Make nicer attribute labels
      select(
        `Option:` = altID,
        ` ` = image,
        `Price:` = price,
        `Type:` = type,
        `Freshness:` = freshness
      )
    row.names(alts) <- NULL # Drop row names

    table <- kbl(t(alts), escape = FALSE) |>
      kable_styling(
        bootstrap_options = c("striped", "hover", "condensed"),
        full_width = FALSE,
        position = "center"
      )
    function() {
      table
    }
  }

  # Create the options for each choice question
  output$cbc1_table <- make_cbc_table(df |> filter(qID == 1))
  output$cbc2_table <- make_cbc_table(df |> filter(qID == 2))
  output$cbc3_table <- make_cbc_table(df |> filter(qID == 3))
  output$cbc4_table <- make_cbc_table(df |> filter(qID == 4))
  output$cbc5_table <- make_cbc_table(df |> filter(qID == 5))
  output$cbc6_table <- make_cbc_table(df |> filter(qID == 6))

  # Define conditional skip logic (skip to page if a condition is true)
  sd_skip_if(
    input$screenout == "blue" ~ "end_screenout",
    input$consent_age == "no" ~ "end_consent",
    input$consent_understand == "no" ~ "end_consent"
  )

  # Define conditional display logic (show a question if a condition is true)
  sd_show_if(
    input$like_fruit %in% c("yes", "kind_of") ~ "fav_fruit"
  )

  # Run surveydown server and define database
  sd_server(db = db)
}

# Launch the app
shiny::shinyApp(ui = ui, server = server)
