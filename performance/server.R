##############################################################
#  set
##############################################################
library(shiny)
library(xts)
library(PerformanceAnalytics)
library(quantmod)
source("return_analysis.R")

# load data
download.file(url = "https://github.com/MokuzenShingo/GANNTrader/raw/master/data/realtimeData2.RData",
              "./data/realtimeData2.RData")
load("./data/realtimeData2.RData")

download.file(url = "https://github.com/MokuzenShingo/GANNTrader/raw/master/data/USDJPYhour_ense_orderbook.rds",
              "./data/USDJPYhour_ense_orderbook.rds")
ens <- readRDS("./data/USDJPYhour_ense_orderbook.rds")

##############################################################
#  reactive
##############################################################
shinyServer(function(input, output) {
  dataInput <- reactive({
    test.data <- realtimeData2["2016::"]
    test.data <- na.omit(test.data)
    ens_sub <- ens[paste0(as.character(input$dateRange[1]), "::",as.character(input$dateRange[2]))]
    ens_sub$return_cumsum <- cumsum(ens_sub$return)
    ens2 <- cbind(test.data, ens_sub)
    ens2$return_cumsum <- na.locf(ens2$return_cumsum)
    ens2
  })
    
  output$chartPlot <- renderPlot({
    data <- dataInput()
    chart_Series(data[,1:4], subset = paste0(as.character(input$dateRange[1]), "::",as.character(input$dateRange[2])), name = "USD/JPY")
    add_TA(data$return_cumsum,  "cumulative return  : last", name = "cumulative returns")
    
    if(sum(grep(pattern = "entry", input$selectPlot)) > 0){
      add_TA(data[data$posi.flag == -1 , "close"], type ="p", on = 1, pch = 20, col = "darkblue", cex = 3)  # short entry
      add_TA(data[data$posi.flag ==  1 , "close"], type ="p", on = 1, pch = 20, col = "green4"  , cex = 3)  # long  entry
    }
    
    if(sum(grep(pattern = "exit", input$selectPlot)) > 0){
      add_TA(data[data$posi.temp == -1 , "close"], type ="p", on = 1, pch = 17, col = "green4"  , cex = 1.5)  # short exit
      add_TA(data[data$posi.temp ==  1 , "close"], type ="p", on = 1, pch = 17, col = "darkblue", cex = 1.5)  # long  exit
    }
    
    add_TA(data[data$posi.temp == -1 , "close"], type ="p", on = 1, cex = 0)  # dummy
    
  })
  
  output$summaryTable <- renderTable({
    data <- dataInput()
    data_sub <- data[data$exit.flag == 1, ]
    total       <- return.analysis(data_sub[,"return"])
    long_entry  <- return.analysis(data_sub[data_sub$posi.temp ==  1, "return"])
    short_entry <- return.analysis(data_sub[data_sub$posi.temp == -1, "return"])
    data.frame(total = total, long_entry = long_entry, short_entry = short_entry)
  }, rownames = TRUE)
  
  output$histPlot <- renderPlot({
    data <- dataInput()
    data_sub <- data[data$exit.flag == 1, ]
    hist(data_sub$return, breaks = input$bins, xlim = c(-input$histrange, input$histrange),
         main = "Histgram of returns", xlab = "")
  })
})