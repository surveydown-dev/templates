# Install required packages:
# install.packages("pak")
# pak::pak(c(
#   'surveydown-dev/surveydown', # <- Development version from github
#   'ggplot2',
#   'dplyr'
# ))

# Load packages
library(surveydown)
library(dplyr)
library(ggplot2)

# Database setup

# surveydown stores data on any PostgreSQL database. We recommend
# https://supabase.com/ for a free and easy to use service.
# For this demo, you need to create a database and connect to it using
# the sd_database() function. Without a connected database, this demo
# won't function properly as the plot generated in the server uses data
# from a connected database. See the documentation for details:
# https://surveydown.org/store-data

db <- sd_database(
    host   = "",
    dbname = "",
    port   = "",
    user   = "",
    table  = ""
)

# Server setup
server <- function(input, output, session) {

    # Refresh data every 5 seconds
    data <- sd_get_data(db, refresh_interval = 5)

    # Render the plot
    output$penguin_plot <- renderPlot({
        data() |> # Note the () here, as this is a reactive expression
            count(penguins) |>
            mutate(penguins = ifelse(penguins == '', 'No response', penguins)) |>
            ggplot() +
            geom_col(aes(x = n, y = reorder(penguins, n)), width = 0.7) +
            theme_minimal() +
            labs(x = "Count", y = "Penguin Type", title = "Penguin Count")
    })

    # Database designation and other settings
    sd_server(
        db = db,
        all_questions_required = TRUE,
        use_cookies = FALSE
    )

}

# shinyApp() initiates your app - don't change it
shiny::shinyApp(ui = sd_ui(), server = server)
