library("ggplot2", lib.loc="/Library/Frameworks/R.framework/Versions/3.0/Resources/library")
library("DBI", lib.loc="/Library/Frameworks/R.framework/Versions/3.0/Resources/library")
library("RSQLite", lib.loc="/Library/Frameworks/R.framework/Versions/3.0/Resources/library")
library("zoo", lib.loc="/Library/Frameworks/R.framework/Versions/3.0/Resources/library")

#set up database connection and gather delay info by airport and month for 2012:
dbdriver = dbDriver("SQLite")
connect = dbConnect(dbdriver, dbname = "airline_delay_causes_major_airports.db")
delays_2012 = dbGetQuery(connect, "SELECT airport, SUM(arr_delay), year, month FROM delays WHERE year = 2012 GROUP BY airport, month")
delays_2012 = as.data.frame(delays_2012)
names(delays_2012)[names(delays_2012)=="SUM(arr_delay)"] <- "delay"
qplot(data = delays_2012, month, delay, group = airport, geom = "line", facets = ~airport) + ggtitle("Total delay time for major U.S. airports, 2012")

#generate data for ATL only:
delays_ATL = dbGetQuery(connect, "SELECT airport, SUM(arr_delay), year, month FROM delays WHERE airport = 'ATL' GROUP BY year, month")
names(delays_ATL)[names(delays_ATL)=="SUM(arr_delay)"] <- "delay"
acf(delays_ATL$delay, lag.max=48)

#generate data by airline for 2012:
connect = dbConnect(dbdriver, dbname = "airline_delay_causes.db")
delays_by_airline_2012 = dbGetQuery(connect, "SELECT carrier_name, SUM(arr_delay), year, month FROM delays WHERE year = 2012 GROUP BY carrier_name, month")
names(delays_by_airline_2012)[names(delays_by_airline_2012)=="SUM(arr_delay)"] <- "delay"
qplot(data = delays_by_airline_2012, month, delay, group = carrier_name, geom = "line", facets = ~carrier_name)

#generate operations data by airport for all years:
connect = dbConnect(dbdriver, dbname = "airline_delay_causes.db")
ops_delays = dbGetQuery(connect, "SELECT airport, SUM(arr_delay), SUM(arr_flights) FROM delays GROUP BY airport")
names(ops_delays)[names(ops_delays)=="SUM(arr_delay)"] <- "delay"
names(ops_delays)[names(ops_delays)=="SUM(arr_flights)"] <- "flights"
qplot(data = ops_delays, flights, delay, geom = "text", label=airport) + geom_smooth(method="lm") + ggtitle("Number of operations vs. total delay time")
cor(ops_delays[2:3], method=c("pearson"))

#generate operations data by airline for all years:
airline_delays = dbGetQuery(connect, "SELECT carrier, SUM(arr_delay), SUM(arr_flights) FROM delays GROUP BY carrier")
names(airline_delays)[names(airline_delays)=="SUM(arr_delay)"] <- "delay"
names(airline_delays)[names(airline_delays)=="SUM(arr_flights)"] <- "flights"
qplot(data = airline_delays, flights, delay, geom = "text", label=carrier) + geom_smooth(method="lm") + ggtitle("Number of airline operations vs. total delay time")
cor(airline_delays[2:3], method=c("pearson"))