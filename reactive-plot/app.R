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

# Database Setup
# sd_db_config
# db <- sd_db_connect()

# Server Setup
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

    # Server Settings
    sd_server(
        db = NULL,
        all_questions_required = TRUE
    )

}

# Launch Survey
shiny::shinyApp(ui = sd_ui(), server = server)
