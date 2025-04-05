# Package setup ---------------------------------------------------------------

# Install required packages:
# install.packages("pak")
# pak::pak("surveydown")

# Load packages
library(surveydown)

# Database setup --------------------------------------------------------------
#
# Details at: https://surveydown.org/manuals/storing-data
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

    # Reactive expression that generates a url for a normal ending
    url_normal <- reactive({
        params <- sd_get_url_pars()
        id_a <- params["id_a"]
        id_b <- params["id_b"]
        id_c <- params["id_c"]
        return(paste0(
            "https://www.google.com?id_a=", id_a,
            "id_b=", id_b,
            "id_c=", id_c,
            "&status=0" # status of 0 indicates normal endin
        ))
    })

    # Reactive expression that generates a url for a screenout ending
    url_screenout <- reactive({
        params <- sd_get_url_pars()
        id_a <- params["id_a"]
        id_b <- params["id_b"]
        id_c <- params["id_c"]
        return(paste0(
            "https://www.google.com?id_a=", id_a,
            "id_b=", id_b,
            "id_c=", id_c,
            "&status=1" # status of 1 indicates screenout
        ))
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

# Launch the app
shiny::shinyApp(ui = ui, server = server)
