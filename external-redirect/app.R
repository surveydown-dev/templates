# Install required packages:
# install.packages("pak")
# pak::pak('surveydown-dev/surveydown') # Development version from github

# Load packages
library(surveydown)

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

    # Skip Logic
    sd_skip_if(
        input$screening_question == "normal_end_1" ~ "end_page_1",
        input$screening_question == "normal_end_2" ~ "end_page_2",
        input$screening_question == "screenout" ~ "screenout_page"
    )

    # Server Settings
    sd_server(
        db = db,
        all_questions_required = TRUE
    )

}

# Launch Survey
shiny::shinyApp(ui = sd_ui(), server = server)
