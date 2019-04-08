# LoL-R-Data-Visual


Use the Riot Games API to visualize League of Legends user's stats; An introduction to data visualization and R.

I also added an additional constraint to this side project, try to do the bulk of everything in R (wrangling, cleaning, filtering)


## KDA vs Gold Graph (A friend's account)
[![graph_kda_gold](https://raw.githubusercontent.com/barrettotte/LoL-R-Data-Visual/master/graphs/Digital/graph_kda_gold.png)](https://raw.githubusercontent.com/barrettotte/LoL-R-Data-Visual/master/graphs/Digital/graph_kda_gold.png)


## Win Rate on Day of Week (A friend's account)
[![graph_winrate_dow](https://raw.githubusercontent.com/barrettotte/LoL-R-Data-Visual/master/graphs/Mivaro/graph_winrate_dow.png)](https://raw.githubusercontent.com/barrettotte/LoL-R-Data-Visual/master/graphs/Mivaro/graph_winrate_dow.png)


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
  "graphs-output": "D:/graphs",
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


## Process
* Create ```config.json``` to define Riot API key and specify summoners to gather data for
* Run ```wrangler.R``` to gather all data, output to ```./Matches.csv```, and populate ```[database].[dbo].[tablename]```
* Additional runs of either ```wrangler.R``` or ```append-matches.R``` will append data to ```[database].[dbo].[tablename]```
* Generate visualizations with ```visualize.R```


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
| gameId       | champion | season | timestamp       | role   | lane  | summoner        | accountId    | gameMode  | duration | stats       | 
| ------------ | -------- | ------ | --------------- | ------ | ----- | --------------- | ------------ | --------- | -------- | ----------- |
| "2932305512" | "122"    | "12"   | "1544835952093" | "SOLO" | "TOP" | "some-summoner" | "1234567890" | "CLASSIC" | "1615"   | JSON String |


## Sources
* https://www.programmableweb.com/news/how-to-access-any-restful-api-using-r-language/how-to/2017/07/21
* https://db.rstudio.com/getting-started/connect-to-database/
* https://bookdown.org/yihui/rmarkdown/notebook.html
* League of Legends
  * https://developer.riotgames.com/api-methods/
  * https://developer.riotgames.com/
  * Items https://ddragon.leagueoflegends.com/cdn/9.6.1/data/en_US/item.json
  * Champions https://ddragon.leagueoflegends.com/cdn/9.6.1/data/en_US/champion.json

