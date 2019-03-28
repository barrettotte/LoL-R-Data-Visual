
# List SQL Server Drivers 
library(odbc)
sort(unique(odbcListDrivers()[[1]]))