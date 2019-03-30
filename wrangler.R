# Data caching, exporting, wrangling, and cleaning


packages <- c("dplyr", "odbc", "jsonlite", "httr", "lubridate")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}
invisible(lapply(packages, function(p){
  suppressMessages(require(p, character.only=TRUE, quietly=TRUE, warn.conflicts=FALSE))
}))

time.start <- Sys.time()
base.url <- "https://na1.api.riotgames.com"
config.path <- file.path(getwd(), "config.json")

# TODO Turn endpoints into single row matrix                    #
endpoint.summoner <- "/lol/summoner/v4/summoners/by-name/"
endpoint.matchlist <- "/lol/match/v4/matchlists/by-account/"
endpoint.match <- "/lol/match/v4/matches/"
# ------------------------------------------------------------- #

config.data <- tryCatch(
  { 
    read_json(path=config.path) 
  }, 
  error = function(e){ 
    print(paste("Error opening", config.path)) 
  }
)

headers <- list(config.data$`api-key`)
names(headers) <- "X-Riot-Token"

summoners.usernames <- unlist(config.data$summoners, use.names=FALSE)
summoners.matrix <- matrix(0, nrow=length(summoners.usernames), ncol=0)


##### Initialize database connection and setup table #####
db.con <- DBI::dbConnect(
  odbc::odbc(),
  Driver = "ODBC Driver 13 for SQL Server", # sort(unique(odbcListDrivers()[[1]])) # List Drivers
  Server = config.data$`db-server`,
  Database = config.data$`db-name`,
  UID = config.data$`db-user`,
  PWD = rstudioapi::askForPassword(paste("Password for user[", config.data$`db-user`, "]")),
  Port = config.data$`db-port`
)

db.result <- tryCatch(
  { 
    dbSendQuery(db.con, paste("CREATE TABLE", config.data$`db-table`, "(
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        lane VARCHAR(30) NOT NULL,
        champion INT NOT NULL,
        platform_id VARCHAR(30) NOT NULL,
        timestamp BIGINT NOT NULL,
        queue int NOT NULL,
        role VARCHAR(30) NOT NULL,
        season int NOT NULL,
        match_details NVARCHAR(MAX)
    )"))
  }, 
  error = function(e){
    print(paste("Error creating", config.data$`db-table`, " - It may already exist."))
  }
)


##### Build account details matrix #####
for(i in 1:length(summoners.usernames)){
  s <- summoners.usernames[i]
  resp <- GET(url=base.url, path=paste(endpoint.summoner, s, sep=''), do.call(add_headers, headers))
  print(paste("HTTP Status_Code", resp$status_code, "-", s))
  
  if(resp$status_code == 200){
    data <- t(do.call(rbind, content(resp)))
    summoners.matrix <- if(length(colnames(summoners.matrix)) == 0) data else rbind(summoners.matrix, as.vector(data))
  }
  Sys.sleep(1.3)
}


print(summoners.matrix)


time.end <- Sys.time()
print(paste("Execution Time:", round(time.end - time.start, 3), "second(s)"))


