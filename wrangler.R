# Data caching, exporting, wrangling, and cleaning


library(odbc)

db.con <- DBI::dbConnect(
  odbc::odbc(),
  Driver = "ODBC Driver 13 for SQL Server",
  Server = "BARRETT-MAIN\\BARRETTSQL",
  Database = "RIOT_API",
  UID = rstudioapi::askForPassword("Database user"),
  PWD = rstudioapi::askForPassword("Database password"),
  Port = 1433
)


