# Database Configuration
#
# Details at https://surveydown.org/database-config.html
#
# This file only needs to be used once when initially setting up your database.
#
# Run this function in your console to setup your database connection settings:
sd_db_config()

# When finished, a .env file storing your config settings will be created.
#
# You can modify any setting using the same interactive approach, or by
# providing a parameter to sd_db_config(), e.g.:
#
# sd_db_config(
#   host = "aws-0-us-west-1.pooler.supabase.com",
#   dbname = "postgres"
# )
#
# View your current configuration with:
sd_db_show()

