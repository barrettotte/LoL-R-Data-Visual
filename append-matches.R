# Append more match data to Matches table using Matches.csv

packages <- c("DBI", "odbc")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}
invisible(lapply(packages, function(p){
  suppressMessages(require(p, character.only=TRUE, quietly=TRUE, warn.conflicts=FALSE))
}))

config.data <- read_json(path=file.path(getwd(), "config.json")) 

db.con <- DBI::dbConnect(
  odbc::odbc(),
  Driver = "ODBC Driver 13 for SQL Server", 
  Server = config.data$`db-server`,
  Database = config.data$`db-name`,
  UID = config.data$`db-user`,
  PWD = rstudioapi::askForPassword(paste("Password for user[", config.data$`db-user`, "]")),
  Port = config.data$`db-port`
)

db.result <- tryCatch(
  {
    dbSendQuery(db.con, paste("BULK INSERT ", config.data$`db-table`, 
      " FROM '", config.data$`csv-data`, "' WITH (
          FIRSTROW=2,
          FIELDTERMINATOR=';',
          ROWTERMINATOR = '\\n',
          TABLOCK
      )", sep=''
    ))
  }, 
  error = function(e){
    print(paste("Error adding data to", 
      config.data$`db-table`, " - Try manually importing Matches.csv to MSSQL")
    )
  }
)
suppressWarnings(DBI::dbDisconnect(db.con))
