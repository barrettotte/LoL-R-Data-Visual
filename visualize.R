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

get_matches <- function(account.id, game.mode){
  print("Getting matches...")
  tryCatch(
    {
      summoner.matches <- (dbGetQuery(db.con, paste("
        SELECT DISTINCT 
          __gameId__, __champion__, __season__, __timestamp__, __role__, __lane__, __summoner__, 
          __accountId__, __gameMode__, __duration__, __stats__
        FROM ", config.data$`db-table`, 
          "WHERE __accountId__='\"", account.id, "\"' 
              AND __gameMode__='\"", game.mode, "\"'", sep='')
      ))
    }, 
    error = function(e){
      print(e)
    }
  )
  colnames(summoner.matches) <- c(
    "id", "champion", "season", "timestamp", "role", "lane", "summoner", 
    "accountId", "gameMode", "duration", "stats"
  )
  # Scrub data a little more...This is more ugly repeated code. Leave me alone though
  stats <- gsub("\r", "", gsub("\"\"", "\"", summoner.matches$`stats`))
  for(m in 1:length(stats)){
    summoner.matches$`gameId`[m] <- gsub("\"", "", summoner.matches$`gameId`[m])
    summoner.matches$`champion`[m] <- gsub("\"", "", summoner.matches$`champion`[m])
    summoner.matches$`season`[m] <- as.integer(gsub("\"", "", summoner.matches$`season`[m]))
    summoner.matches$`timestamp`[m] <- gsub("\"", "", summoner.matches$`timestamp`[m])
    summoner.matches$`role`[m] <- gsub("\"", "", summoner.matches$`role`[m])
    summoner.matches$`lane`[m] <- gsub("\"", "", summoner.matches$`lane`[m])
    summoner.matches$`summoner`[m] <- gsub("\"", "", summoner.matches$`summoner`[m])
    summoner.matches$`accountId`[m] <- gsub("\"", "", summoner.matches$`accountId`[m])
    summoner.matches$`gameMode`[m] <- gsub("\"", "", summoner.matches$`gameMode`[m])
    summoner.matches$`duration`[m] <- as.integer(gsub("\"", "", summoner.matches$`duration`[m]))
    summoner.matches$`stats`[m] <- substr(stats[m], 2, nchar(stats[m])-1)
  }
  return(summoner.matches)
}


get_stats <- function(matches){
  print("Getting stats...")
  cols <- c(
    "goldEarned", "kills", "deaths", "assists", "totalMinionsKilled", "win",
    "magicDamageDealtToChampions", "trueDamageDealtToChampions", 
    "physicalDamageDealtToChampions", "totalDamageDealtToChampions",
    "magicalDamageTaken", "trueDamageTaken", "physicalDamageTaken", "totalDamageTaken"
  )
  calcs <- c("kda", "kd", "dayOfWeek")
  stats.all <- matrix(NA, 0, length(cols) + length(colnames(matches)) - 1 + length(calcs))
  colnames(stats.all) <- c(colnames(matches[, which(!colnames(matches) == "stats")]), cols, calcs)
  
  for(i in 1:nrow(matches)){
    s <- fromJSON(matches[i, "stats"])$stats[, cols]
    if(s$deaths == 0){
      kda <- (as.numeric(s$kills) + as.numeric(s$assists)) / 1
      kd <- as.numeric(s$kills) / 1
    } else{
      kda <- (as.numeric(s$kills) + as.numeric(s$assists)) / as.numeric(s$deaths)
      kd <- as.numeric(s$kills) / as.numeric(s$deaths)
    }
    if(is.nan(kd)){
      kda <- 0
      kd <- 0
    }
    stats.all <- rbind(stats.all, c(
      as.matrix(matches[i, which(!colnames(matches) == "stats")]), as.matrix(s), kda, kd, 
      weekdays(as.POSIXct(as.numeric(as.character(matches[i, "timestamp"]))/1000, origin="1970-01-01"))
    ))
  }
  return(as.data.frame(stats.all))
}


graph_kda_gold <- function(username, stats, output){
  print("Generating graph_kda_gold...")
  gg <- ggplot(stats, 
    aes(x=as.double(kda), y=as.numeric(goldEarned), color=win)
  ) + 
  geom_point(size=4, alpha=0.35) +
  labs(title=paste(username, "KDA vs Gold -", nrow(stats), "Match(es)"), x="KDA", y="Gold") +
  scale_color_manual(values=c("red", "green"), name="Match Result", labels=c("Loss", "Win")) + 
  scale_x_continuous(labels = scales::number_format(scale=0.01, accuracy = 0.01))
  
  suppressWarnings((dir.create(paste(output, username, sep=''))))
  ggsave(
    filename=paste(output, username, "/graph_kda_gold", ".png", sep=""), 
    width=20, height=20, units="cm"
  )
}

graph_winrate_dayOfWeek <- function(username, stats, output){
  
}

#####   END FUNCTIONS   #####


config.data <- read_json(path=file.path(getwd(), "config.json")) 
suppressWarnings(dir.create(config.data$`graphs-output`))
db.con <- DBI::dbConnect(
  odbc::odbc(),
  Driver = "ODBC Driver 13 for SQL Server", 
  Server = config.data$`db-server`,
  Database = config.data$`db-name`,
  UID = config.data$`db-user`,
  PWD = rstudioapi::askForPassword(paste("Password for user[", config.data$`db-user`, "]")),
  Port = config.data$`db-port`
)

tryCatch({
    summoners <- (dbGetQuery(db.con, paste("
      SELECT DISTINCT __summoner__, __accountId__ FROM ", config.data$`db-table`, sep='')
    ))
}, error = function(e){ print(e) })
colnames(summoners) <- c("name", "accountId")

out <- config.data$`graphs-output`
##### Generate Graphs #####
for(i in 1:nrow(summoners)){
  name <- gsub("\"", "", summoners[i, "name"])
  print(paste("Generating graphs for", name, "..."))
  matches <- get_matches(gsub("\"", "", summoners[i, "accountId"]), "CLASSIC")
  stats <- get_stats(matches)
  
#  graph_kda_gold(name, stats, out)
#  avg_win <- mean(as.numeric(as.character(stats$win)), na.rm = TRUE)
#  print(paste("Average:",avg_win))
}

suppressWarnings(DBI::dbDisconnect(db.con))
