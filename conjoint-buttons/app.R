# Install required packages:
# install.packages("pak")
# pak::pak(c(
#   'surveydown-dev/surveydown', # <- Development version from github
#   'here',
#   'glue',
#   'readr',
#   'dplyr'
# ))

# Load packages
library(surveydown)
library(here)
library(dplyr)
library(glue)
library(readr)

# Database Setup

# Run sd_db_config() once to set up Supabase credentials.
# sd_db_config()

# Connect with Supabase and store instance into db
# Turn ignore to FALSE to connect to your Supabase
db <- sd_db_connect(
  ignore = TRUE
)

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
  df <- design |>
    filter(respID == respondentID) |>
    # Paste on the "images/" path (images are stored in the "images" folder)
    mutate(image = paste0("images/", image))

  # Function to create the question labels based on design values
  make_cbc_options <- function(df) {
    alt1 <- df |> filter(altID == 1)
    alt2 <- df |> filter(altID == 2)
    alt3 <- df |> filter(altID == 3)

    options <- c("option_1", "option_2", "option_3")

    names(options) <- c(
      glue("
      **Option 1**<br>
      <img src='{alt1$image}' width=100><br>
      **Type**: {alt1$type}<br>
      **Price**: $ {alt1$price} / lb<br>
      **Freshness**: {alt1$freshness}
    "),
      glue("
      **Option 2**<br>
      <img src='{alt2$image}' width=100><br>
      **Type**: {alt2$type}<br>
      **Price**: $ {alt2$price} / lb<br>
      **Freshness**: {alt2$freshness}
    "),
      glue("
      **Option 3**<br>
      <img src='{alt3$image}' width=100><br>
      **Type**: {alt3$type}<br>
      **Price**: $ {alt3$price} / lb<br>
      **Freshness**: {alt3$freshness}
    ")
    )
    return(options)
  }

  # Create the options for each choice question
  cbc1_options <- make_cbc_options(df |> filter(qID == 1))
  cbc2_options <- make_cbc_options(df |> filter(qID == 2))
  cbc3_options <- make_cbc_options(df |> filter(qID == 3))
  cbc4_options <- make_cbc_options(df |> filter(qID == 4))
  cbc5_options <- make_cbc_options(df |> filter(qID == 5))
  cbc6_options <- make_cbc_options(df |> filter(qID == 6))

  # Create each choice question - display these in your survey using sd_output()
  # Example: sd_output('cbc_q1', type = 'question')

  sd_question(
    type   = 'mc_buttons',
    id     = 'cbc_q1',
    label  = "(1 of 6) If these were your only options, which would you choose?",
    option = cbc1_options
  )

  sd_question(
    type   = 'mc_buttons',
    id     = 'cbc_q2',
    label  = "(2 of 6) If these were your only options, which would you choose?",
    option = cbc2_options
  )

  sd_question(
    type   = 'mc_buttons',
    id     = 'cbc_q3',
    label  = "(3 of 6) If these were your only options, which would you choose?",
    option = cbc3_options
  )

  sd_question(
    type   = 'mc_buttons',
    id     = 'cbc_q4',
    label  = "(4 of 6) If these were your only options, which would you choose?",
    option = cbc4_options
  )

  sd_question(
    type   = 'mc_buttons',
    id     = 'cbc_q5',
    label  = "(5 of 6) If these were your only options, which would you choose?",
    option = cbc5_options
  )

  sd_question(
    type   = 'mc_buttons',
    id     = 'cbc_q6',
    label  = "(6 of 6) If these were your only options, which would you choose?",
    option = cbc6_options
  )

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
    db = db,
    auto_scroll = TRUE,
    rate_survey = TRUE
  )

}

# Launch Survey
shiny::shinyApp(ui = sd_ui(), server = server)
