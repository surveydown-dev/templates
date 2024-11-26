# remotes::install_github("surveydown-dev/surveydown", force = TRUE)
library(surveydown)
library(tidyverse)

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

    # Reactive expression that generates a url for a normal ending
    url_normal <- reactive({
        params <- sd_get_url_pars()
        id_a <- params["id_a"]
        id_b <- params["id_b"]
        id_c <- params["id_c"]
        return(paste0("https://www.google.com?id_a=", id_a,
                      "id_b=", id_b,
                      "id_c=", id_c,
                      "&status=0")) # status of 0 indicates normal ending
    })

    # Reactive expression that generates a url for a screenout ending
    url_screenout <- reactive({
        params <- sd_get_url_pars()
        id_a <- params["id_a"]
        id_b <- params["id_b"]
        id_c <- params["id_c"]
        return(paste0("https://www.google.com?id_a=", id_a,
                      "id_b=", id_b,
                      "id_c=", id_c,
                      "&status=1")) # status of 1 indicates screenout
    })

    # Create the redirect buttons (normal and screenout)

    sd_redirect(
        id = "redirect_normal",
        url = url_normal(),
        button = TRUE,
        label = "Redirect with Normal Status"
    )

    sd_redirect(
        id = "redirect_screenout",
        url = url_screenout(),
        button = TRUE,
        label = "Redirect with Screenout Status"
    )

    # Define any conditional skip logic here (skip to page if a condition is true)
    sd_skip_if(
        input$screening_question == "normal_end_1" ~ "end_page_1",
        input$screening_question == "normal_end_2" ~ "end_page_2",
        input$screening_question == "screenout" ~ "screenout_page"
    )

    # Database designation and other settings
    sd_server(
        db = db,
        all_questions_required = TRUE
    )

}

# shinyApp() initiates your app - don't change it
shiny::shinyApp(ui = sd_ui(), server = server)
