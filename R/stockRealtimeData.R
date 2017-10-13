setwd("/home/ruser/GANNTrader/server/R/")
library(xts)
library(dplyr)

load("../data/histry.RData")

datList <- list(
  USDJPY = histry[histry$Symbol == "USD/JPY", 2:6],
  EURJPY = histry[histry$Symbol == "EUR/JPY", 2:6],
  GBPJPY = histry[histry$Symbol == "GBP/JPY", 2:6],
  EURUSD = histry[histry$Symbol == "EUR/USD", 2:6],
  GBPUSD = histry[histry$Symbol == "GBP/USD", 2:6],
  EURGBP = histry[histry$Symbol == "EUR/GBP", 2:6]
  )

datList <- lapply(datList, function(x){
  rownames(x) <- x$TimeStamp
  x$year <- substr(x$TimeStamp, 1, 4)
  x$month <- substr(x$TimeStamp, 6, 7)
  x$day <- substr(x$TimeStamp, 9, 10)
  x$hour <- substr(x$TimeStamp, 12, 13)
  x[,c("Ask.Price", "TimeStamp")] <- NULL
  x
})

datHour <- lapply(datList,function(x){
  temp <- group_by(.data = x, year, month, day, hour)

  tempHour <- summarise(.data = temp,
                        open = head(Bid.Price, 1),
                        high = max(Bid.Price),
                        low = min(Bid.Price),
                        close = tail(Bid.Price, 1)
                        )
  tempHour <- as.data.frame(tempHour)
  tempHour$time <- apply(tempHour, 1, function(y){
    paste0(y[1], "-", y[2], "-", y[3], " ", y[4], ":00:00")
    })
  tempHour <- tempHour[,5:9]
  tempHour <- xts(tempHour[,-5], as.POSIXct(tempHour$time))
})
names(datHour) <- paste0(names(datHour), "hour")

### 
is.not.market <- function(x){
  (weekdays(as.Date(x)) == "土曜日" & as.integer(substr(x, 12, 13)) > 5) |
  weekdays(as.Date(x)) == "日曜日" |
  (weekdays(as.Date(x)) == "月曜日" & as.integer(substr(x, 12, 13)) < 7)
}

if(is.not.market(tail(index(datHour[[1]]),1)) == FALSE){
  load("../data/realtimeData.RData")
  for(i in 1:6) realtimeData[[i]] <- rbind(realtimeData[[i]], datHour[[i]][nrow(datHour[[i]]),])
 save(realtimeData, file = "../data/realtimeData.RData")

}
