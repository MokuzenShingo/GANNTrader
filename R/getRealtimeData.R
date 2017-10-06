setwd("/home/ruser/GANNTrader/server/R/")
library(TFX)
load("../data/histry.RData")

hist <- QueryTrueFX()
hist$TimeStamp <- Sys.time()

histry <- rbind(histry, hist)
save(histry, file = "../data/histry.RData")
