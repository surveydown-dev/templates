# Package setup ---------------------------------------------------------------

# Install required packages:
# install.packages("pak")
# pak::pak(c(
#   'surveydown-dev/surveydown', # Development version from GitHub
#   'ggplot2',
#   'dplyr'
# ))

# Load packages
library(surveydown)
library(dplyr)
library(ggplot2)

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
    # Refresh data every 5 seconds
    data <- sd_get_data(db, refresh_interval = 5)

    # Render the plot
    output$penguin_plot <- renderPlot({
        data() |> # Note the () here, as this is a reactive expression
            count(penguins) |>
            mutate(
                penguins = ifelse(penguins == '', 'No response', penguins)
            ) |>
            ggplot() +
            geom_col(aes(x = n, y = reorder(penguins, n)), width = 0.7) +
            theme_minimal() +
            labs(x = "Count", y = "Penguin Type", title = "Penguin Count")
    })

    # Run surveydown server and define database
    sd_server(db = db)
}

# Launch the app
shiny::shinyApp(ui = ui, server = server)
