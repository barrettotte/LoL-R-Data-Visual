# Load cached data, clean json string a bit, and visualize some data

##### Install and activate packages #####
packages <- c("dplyr", "DBI", "odbc", "jsonlite", "plyr", "data.table", 
  "ggplot2", "hexbin"
)
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}
invisible(lapply(packages, function(p){
  suppressMessages(require(p, character.only=TRUE, quietly=TRUE, warn.conflicts=FALSE))
}))


#####   START FUNCTIONS   #####
get_matches <- function(summoner.name){
  tryCatch(
    {
      summoner.matches <- (dbGetQuery(db.con, paste("
        SELECT DISTINCT 
          __gameId__, __champion__, __season__, __timestamp__, __role__, 
          __lane__, __summoner__, __accountId__, __duration__, __stats__
        FROM ", config.data$`db-table`, "WHERE __summoner__='\"", summoner.name, "\"'", sep='')
      ))
    }, 
    error = function(e){
      print(e)
    }
  )
  colnames(summoner.matches) <- c(
    "id", "champion", "season", "timestamp", "role", "lane", "summoner", "duration", "stats"
  )
  stats <- gsub("\r", "", gsub("\"\"", "\"", summoner.matches$`stats`))
  for(m in 1:length(stats)){
    summoner.matches$`gameId`[m] <- as.integer(gsub("\"", "", summoner.matches$`gameId`[m]))
    summoner.matches$`champion`[m] <- gsub("\"", "", summoner.matches$`champion`[m])
    summoner.matches$`season`[m] <- as.integer(gsub("\"", "", summoner.matches$`season`[m]))
    summoner.matches$`timestamp`[m] <- as.integer(gsub("\"", "", summoner.matches$`timestamp`[m]))
    summoner.matches$`role`[m] <- gsub("\"", "", summoner.matches$`role`[m])
    summoner.matches$`lane`[m] <- gsub("\"", "", summoner.matches$`lane`[m])
    summoner.matches$`summoner`[m] <- gsub("\"", "", summoner.matches$`summoner`[m])
    summoner.matches$`duration`[m] <- as.integer(gsub("\"", "", summoner.matches$`duration`[m]))
    summoner.matches$`stats`[m] <- substr(stats[m], 2, nchar(stats[m])-1)
  }
  return(summoner.matches)
}
#####   END FUNCTIONS   #####


config.data <- read_json(path=file.path(getwd(), "config.json")) 

db.con <- DBI::dbConnect(
  odbc::odbc(),
  Driver = "ODBC Driver 13 for SQL Server", 
  Server = config.data$`db-server`,
  Database = config.data$`db-name`,
  UID = config.data$`db-user`,
  #PWD = rstudioapi::askForPassword(paste("Password for user[", config.data$`db-user`, "]")),
  PWD = "password",
  Port = config.data$`db-port`
)

summoners.usernames <- unlist(config.data$`summoners`, use.names=FALSE)
m.matchlist <- matrix(NA, 0, 0)


m.matchlist <- get_matches(summoners.usernames[1])

#head(m.matchlist,1)
#is.data.frame(fromJSON(head(m.matchlist$stats,1)))
#fromJSON(head(m.matchlist$stats,1))$stats$win



ggplot(m.matchlist, aes(x=lane)) +
  geom_bar(aes(fill=role)) +
  xlab("Lane") + ylab("Matches Played") +
  ggtitle(paste(summoners.usernames[1], " (", nrow(m.matchlist), " Matches Total)", sep=''))
  
  

suppressWarnings(DBI::dbDisconnect(db.con))