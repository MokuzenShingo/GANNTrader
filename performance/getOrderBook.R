################################################################
# set  　　　　　　　　　　　　　　　　　　　　　　　
#################################################################
source("./helper.R")
symbol.name <- "USDJPYhour"
test.period <- c(paste0("2016-01-01::", Sys.Date())) # set test period

### Neural Network model (evalute market condition)
hidden.size <- 6
nn.model <- data.frame(RSI = rep(0, 3), diffADX = rep(0, 3), uniDMI = rep(0, 3),  # input  layer
                       Signal = c("-1", "0", "1")                                 # output layer
)                                
wts.size <- ncol(nn.model) * hidden.size + (hidden.size + 1) * 3  # number of connection

#################################################################
# apply test data
#################################################################
# set the agent
validResult <- readRDS(paste0("../data/", symbol.name, "_bestGeneration.rds"))

# set test data
download.file(url= "https://github.com/MokuzenShingo/GANNTrader/raw/master/data/realtimeData.RData",
              "../data/realtimeData.RData")

load("../data/realtimeData.RData")
symbol <- realtimeData[[symbol.name]]["2016::"]
temp <- unique(index(symbol))
data <- sapply(temp, function(x) symbol[x][1])
realtimeData2 <- xts(t(data), order.by = temp)

save(realtimeData2, file = "../data/realtimeData2.RData")
test.data <- na.omit(realtimeData2[test.period])    # extract data of test period

# calclate technical indicators
indicators <- get_indicators(test.data)                          

# initialize classifers
gtype <- gtype.ini(validResult)                                  # gtype
signal.table <- signal.table.ini(validResult, data = test.data)  # signal.table
position.table <- position.table.ini(data = test.data)           # position.table

# apply test data: combine the output of agents
for(step in 1:(nrow(test.data) - 1)){
  # generates the trading action each agent
  step.sig <- apply(gtype, 1, function(x){
    ID <- x[length(x)]
    x <- as.numeric(x[-length(x)])
    ind.sig(gtype = x,
            curr.price  = test.data[step,],
            curr.vola   = indicators[[4]][step, 1],
            signal      = signal.table[step, ID],
            posi.price  = position.table[step, c("open", "high", "low", "close")],
            posi.flag   = position.table[step,"posi.flag"]
    )  
  })
  
  # combine the output of agents
  ense.sig <- as.integer(mode(step.sig))
  
  # update the position
  position.table[step + 1,] <- updata.position(ense.sig,
                                               posi.price = position.table[step, c("open", "high", "low", "close")],
                                               posi.flag  = position.table[step,"posi.flag"],
                                               next.price = test.data[step +1,]
  )
  
  print(paste(step, " / " , nrow(test.data) - 1))
}

##############################################################
#  generates the orderbook
##############################################################
orderbook <- cbind(test.data, position.table)
orderbook$trade.flag <- abs(diff(orderbook$posi.flag))
orderbook$exit.flag  <- ifelse(orderbook$trade.flag == 1 & orderbook$posi.flag  == 0, 1, 0)
orderbook$entry.flag <- ifelse(orderbook$trade.flag == 1 & orderbook$exit.flag  == 0, 1, 0)

orderbook.temp <- orderbook[orderbook$trade.flag == 1,]
orderbook.temp$tradeID <- cumsum(orderbook.temp$entry.flag)

#orderbook.temp <- is.exit(orderbook.temp)
orderbook.temp$diff.price <- diff(orderbook.temp$close)
orderbook.temp$posi.temp  <- c(0, orderbook.temp$posi.flag[-length(orderbook.temp$posi.flag)])
orderbook.temp$return <- orderbook.temp$diff.price * orderbook.temp$posi.temp

orderbook.temp <- na.omit(orderbook.temp)
orderbook.temp$return_cumsum <- cumsum(orderbook.temp$return)

saveRDS(orderbook.temp, file = "../data/USDJPYhour_ense_orderbook.rds")
