# LoL-R-Data-Visual


Use the Riot Games API to visualize League of Legends user's stats; An introduction to data visualization and R


## Process
* Create ```config.json``` to define Riot API key and specify summoners to gather data for
* Run ```wrangler.R``` to gather all data, output to ```./Matches.csv```, and populate ```[database].[dbo].[tablename]```
* Additional runs of either ```wrangler.R``` or ```append-matches.R``` will append data to ```[database].[dbo].[tablename]```


## Config
```JSON
{
  "db-server": "SERVER_NAME",
  "db-name": "DB_NAME",
  "db-port": 1433,
  "db-user": "user",
  "db-table": "[DB_NAME].[dbo].[Matches]",
  "api-key": "RIOT_API",
  "csv-data": "D:/some/where",
  "version": "9.6.1",
  "summoners": [
    {
      "username":"Some Summoner"
    },
    {
      "username": "Another Summoner"
    }
  ]
}
```

## wrangler.R Output
```
[1] "HTTP Status_Code 200 ; Summoner = some-summoner"
[1] "HTTP Status_Code 200 ; Matchlist   : "
[1] "HTTP Status_Code 200 ; Matchlist  100 : 125"
[1] "Found 838 match(es)"
[1] "HTTP Status_Code 200 ; Matchlist  0 : 100"
[1] "HTTP Status_Code 200 ; Matchlist  100 : 200"
[1] "HTTP Status_Code 200 ; Matchlist  200 : 300"
[1] "HTTP Status_Code 200 ; Matchlist  300 : 400"
[1] "HTTP Status_Code 200 ; Matchlist  400 : 500"
[1] "HTTP Status_Code 200 ; Matchlist  500 : 600"
[1] "HTTP Status_Code 200 ; Matchlist  600 : 700"
[1] "HTTP Status_Code 200 ; Matchlist  700 : 800"
[1] "HTTP Status_Code 200 ; Matchlist  800 : 838"
[1] "HTTP Status_Code 200 ; Match 1 - 2156013942"
[1] "HTTP Status_Code 200 ; Match 2 - 2155966676"
[1] "HTTP Status_Code 200 ; Match 3 - 2155295129"
[1] "HTTP Status_Code 200 ; Match 4 - 2155281121"
[1] "HTTP Status_Code 200 ; Match 5 - 2154585294"
```


## Example Cached Match Data
| platformId | gameId       | champion | queue | season | timestamp       | role   | lane  | summoner        | accountId    | duration | stats       | 
| ---------- | ------------ | -------- | ----- | ------ | --------------- | ------ | ----- | --------------- | ------------ | -------- | ----------- |
| "NA1"      | "2932305512" | "122"    | "400" | "12"   | "1544835952093" | "SOLO" | "TOP" | "some-summoner" | "1234567890" | "1615"   | JSON String |


## Goals
- [x] MSSQL database connection
- [x] API call to Riot Games API to all data for each user
- [x] Cache all match data for each user in MSSQL
- [x] Load and clean slightly dirty data from MSSQL
- [ ] Data visualization
  - [ ] Heatmap over KDA, farm, gold, etc - 2D facet by day of week and user
  - [ ] Histogram of similar stats per user
  - [ ] Overall stat averages compared between users
  - [ ] TBD
- [ ] Export all graphs
- [ ] Rmarkdown of graphs with code
- [ ] Analyze data visualizations and write observations to Rmarkdown
- [ ] Port Rmarkdown to a Jupyter Notebook


## Sources
* https://www.programmableweb.com/news/how-to-access-any-restful-api-using-r-language/how-to/2017/07/21
* https://db.rstudio.com/getting-started/connect-to-database/
* https://bookdown.org/yihui/rmarkdown/notebook.html
* League of Legends
  * https://developer.riotgames.com/api-methods/
  * https://developer.riotgames.com/
  * Items https://ddragon.leagueoflegends.com/cdn/9.6.1/data/en_US/item.json
  * Champions https://ddragon.leagueoflegends.com/cdn/9.6.1/data/en_US/champion.json