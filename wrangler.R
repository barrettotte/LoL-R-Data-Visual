# Data caching and wrangling
# Warning: Requests rate = 1.2 requests/second


##### Install and activate packages #####
packages <- c("dplyr", "DBI", "odbc", "jsonlite", "httr", "lubridate", "plyr", "data.table")
if (length(setdiff(packages, rownames(installed.packages()))) > 0) {
  install.packages(setdiff(packages, rownames(installed.packages())))
}
invisible(lapply(packages, function(p){
  suppressMessages(require(p, character.only=TRUE, quietly=TRUE, warn.conflicts=FALSE))
}))


#####   START FUNCTIONS   #####
get_matchlist <- function(url, path, headers, begin, end){
  resp <- GET(url=url, path=path, do.call(add_headers, headers), query=list(beginIndex=begin, endIndex=end))
  Sys.sleep(1.2)
  print(paste("HTTP Status_Code", resp$status_code, "; Matchlist ", begin, ":", end))
  return(resp)
}

get_match <- function(url, path, headers, id, iter){
  resp <- GET(url=base.url, path=paste(path, id, sep=''), do.call(add_headers, headers))
  print(paste("HTTP Status_Code", resp$status_code, "; Match", iter, "-", id))
  Sys.sleep(1.2)
  return(resp)
}

get_static_json <- function(x){
  write_json(
    fromJSON(rawToChar(
      GET(url="https://ddragon.leagueoflegends.com", 
          path=paste("cdn", config.data$`version`, "data/en_US", paste(x, ".json", sep=''), sep="/")
      )$`content`
    )), 
    paste("./", x, ".json", sep=''), 
    pretty=TRUE
  )
  return(NULL)
}

make_dbcon <- function(){
  db.con <- DBI::dbConnect(
    odbc::odbc(),
    # List Drivers    sort(unique(odbcListDrivers()[[1]])) 
    Driver = "ODBC Driver 13 for SQL Server", 
    Server = config.data$`db-server`,
    Database = config.data$`db-name`,
    UID = config.data$`db-user`,
    PWD = db.password,
    Port = config.data$`db-port`
  )
  return(db.con)
}
#####   END FUNCTIONS   #####


time.start <- Sys.time()
base.url <- "https://na1.api.riotgames.com"
endpoints <- matrix(c(
  "/lol/summoner/v4/summoners/by-name/", 
  "/lol/match/v4/matchlists/by-account/", 
  "/lol/match/v4/matches/"
))
colnames(endpoints) <- c("path")
rownames(endpoints) <- c("summoner", "matchlist", "match")

config.data <- read_json(path=file.path(getwd(), "config.json")) 
headers <- list(config.data$`api-key`)
db.password <- rstudioapi::askForPassword(paste("Password for user[", config.data$`db-user`, "]"))
names(headers) <- "X-Riot-Token"
summoners.usernames <- unlist(config.data$summoners, use.names=FALSE)
m.matchlist <- matrix(NA, 0, 0)


##### Initialize Matches Table #####
db.con <- make_dbcon()
db.result <- tryCatch(
  { 
    dbSendQuery(db.con, paste("CREATE TABLE", config.data$`db-table`, "(
        __platformId__ NVARCHAR(50) NOT NULL,
        __gameId__ NVARCHAR(50) NOT NULL,
        __champion__ NVARCHAR(50) NOT NULL,
        __queue__ NVARCHAR(50) NOT NULL,
        __season__ NVARCHAR(50) NOT NULL,
        __timestamp__ NVARCHAR(50) NOT NULL,
        __role__ NVARCHAR(50) NOT NULL,
        __lane__ NVARCHAR(50) NOT NULL,
        __summoner__ NVARCHAR(50) NOT NULL,
        __accountId__ NVARCHAR(100) NOT NULL,
        __gameMode__ NVARCHAR(50) NOT NULL,
        __duration__ NVARCHAR(50) NOT NULL,
        __stats__ NVARCHAR(MAX) NOT NULL
    )"))
  }, 
  error = function(e){
    print(paste("Error creating", config.data$`db-table`, " - It may already exist."))
  }
)
print(db.result)
suppressWarnings(DBI::dbDisconnect(db.con))

##### Get static data #####
get_static_json("champion")
get_static_json("item")

##### Build account details matrix #####
for(i in 1:length(summoners.usernames)){
  data.matchlist <- matrix()
  s <- gsub(" ", "", summoners.usernames[i])
  resp <- GET(url=base.url, path=paste(endpoints["summoner",], s, sep=''), do.call(add_headers, headers))
  Sys.sleep(1.2)
  print(paste("HTTP Status_Code", resp$status_code, ";", "Summoner =", s))
  
  if(resp$status_code == 200){
    data.summoner <- t(do.call(rbind, content(resp)))
    data.accountId <- data.summoner[,"accountId"]
    matchlist.url <- paste(endpoints["matchlist",], data.accountId, sep='')
    matches.total <- head(content(get_matchlist(base.url, matchlist.url, headers, "", "")))$`totalGames`
        
    if(matches.total > 100){
      resp <- get_matchlist(base.url, matchlist.url, headers, 100, 125)
      matches.total <- head(content(resp))$`totalGames`
      print(paste("Found", matches.total, "match(es)"))
      
      for(j in 0:(((matches.total - matches.total %% 100)/100)-1)){
        resp <- get_matchlist(base.url, matchlist.url, headers, j*100, (j+1)*100)
        if(length(colnames(data.matchlist)) == 0){
          data.matchlist <- cbind(do.call(rbind, content(resp)$matches), data.summoner[,"name"])  
        } else{
          data.matchlist <- rbind(data.matchlist, cbind(do.call(rbind, content(resp)$matches), data.summoner[,"name"]))
        }
      }
      colnames(data.matchlist)[(length(colnames(data.matchlist)))] <- "summoner"
    } else{
      print(paste("Found", matches.total, "match(es)"))
      data.summoner <- cbind(data.summoner, matches.total)
      colnames(data.summoner)[(length(colnames(data.summoner)))] <- "matches"
    }
    resp <- get_matchlist(base.url, matchlist.url, headers, matches.total - matches.total %% 100, matches.total)
    if(length(colnames(data.matchlist)) == 0){
      data.matchlist <- cbind(do.call(rbind, content(resp)$matches), data.summoner[,"name"])  
    } else{
      data.matchlist <- rbind(data.matchlist, cbind(do.call(rbind, content(resp)$matches), data.summoner[,"name"]))
    }
    colnames(data.matchlist)[(length(colnames(data.matchlist)))] <- "summoner"
    
    for(m in 1:matches.total){
      resp <- get_match(base.url, endpoints["match",], headers, unlist(data.matchlist[,"gameId"][m], use.names=FALSE), m)
      if(resp$status_code == 503){
        m <- m-1
      } else{
        match <- fromJSON(rawToChar(resp$content))
        match.stats <- toJSON(subset(match$participants, participantId == rownames(
          subset(match$participantId$player, accountId == data.accountId)))
        )
        # This is ugly duplicated code...please look away. I am lazy
        if("accountId" %in% colnames(data.matchlist)){
          data.matchlist[m, "accountId"] <- data.accountId
        } else{
          data.matchlist <- cbind(data.matchlist, as.character(data.accountId))
          colnames(data.matchlist)[(length(colnames(data.matchlist)))] <- "accountId"
        }
        if("gameMode" %in% colnames(data.matchlist)){
          data.matchlist[m,"gameMode"] <- as.character(match$gameMode)
        } else{
          data.matchlist <- cbind(data.matchlist, as.character(match$gameMode))
          colnames(data.matchlist)[(length(colnames(data.matchlist)))] <- "gameMode"
        }
        if("duration" %in% colnames(data.matchlist)){
          data.matchlist[m,"duration"] <- as.character(match$gameDuration)
        } else{
          data.matchlist <- cbind(data.matchlist, as.character(match$gameDuration))
          colnames(data.matchlist)[(length(colnames(data.matchlist)))] <- "duration"
        }
        if("stats" %in% colnames(data.matchlist)){
          data.matchlist[m,"stats"] <- match.stats 
        } else{
          data.matchlist <- cbind(data.matchlist, match.stats)
          colnames(data.matchlist)[(length(colnames(data.matchlist)))]  <- "stats"
        } 
      }
    }
    if(length(colnames(m.matchlist)) == 0){
      m.matchlist <- data.matchlist
    } else {
      m.matchlist <- rbind(m.matchlist, data.matchlist)
    }
  }
  cat("\n")
}

m.matchlist <- as.data.frame(m.matchlist)
write.csv2(apply(m.matchlist, 2, as.character), file=as.character(config.data$`csv-data`), row.names=FALSE, eol="\n", na="NA")

db.con <- make_dbcon()
db.result <- tryCatch(
  {
    dbSendQuery(db.con, paste("BULK INSERT ", config.data$`db-table`, 
      " FROM '", config.data$`csv-data`, "' WITH (
          FIRSTROW=2,
          FIELDTERMINATOR=';',
          ROWTERMINATOR = '\n',
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

print("Execution Time:")
print(Sys.time() - time.start)
print("Data gathering completed")
#rm(list=ls(all=TRUE))
