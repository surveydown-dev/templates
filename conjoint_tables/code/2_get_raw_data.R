library(tidyverse)
library(surveydown)

# Change dplyr settings so I can view all columns
options(dplyr.widtkh = Inf)

# If there's no .env file, run this to set up your database configuration:
# sd_db_config()

# Connect to database
db <- sd_db_connect()

# Pull in the data
df <- sd_get_data(db)

write_csv(df, here::here('data', 'data_raw.csv'))
