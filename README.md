# LoL-R-Data-Visual


Use the Riot Games API to visualize League of Legends user's stats; An introduction to data visualization and R


## R Packages
Run ```init.R``` to install dependencies
* ggplot2
* odbc
* dplyr
* tidyr
* plotly


## Goals
- [ ] MSSQL database connection
- [ ] API call to Riot Games API to all data for each user
- [ ] Cache each users' data in MSSQL
- [ ] Load user data from MSSQL
- [ ] Wrangle and clean any bad formatted data
- [ ] Write cleaned data to Excel and CSV
- [ ] Data visualization
  - [ ] Heatmap over KDA, farm, gold, etc - 2D facet by day of week and user
  - [ ] Histogram of similar stats per user
  - [ ] Overall stat averages compared between users
  - [ ] TBD
- [ ] Export all graphs
- [ ] Rmarkdown of graphs with code
- [ ] Analyze data visualizations and write observations to Rmarkdown
- [ ] Port Rmarkdown to a Jupyter Notebook


## Constants
* Season 2019 = Season id 13
* Version 9.6.1


## Sources
* https://www.programmableweb.com/news/how-to-access-any-restful-api-using-r-language/how-to/2017/07/21
* https://db.rstudio.com/getting-started/connect-to-database/
* https://bookdown.org/yihui/rmarkdown/notebook.html
* League of Legends
  * https://developer.riotgames.com/api-methods/
  * https://developer.riotgames.com/
  * Items https://ddragon.leagueoflegends.com/cdn/9.6.1/data/en_US/item.json
  * Champions https://ddragon.leagueoflegends.com/cdn/9.6.1/data/en_US/champion.json