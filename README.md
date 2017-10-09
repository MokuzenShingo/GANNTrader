# GANNTrader

### crontab
*/5 * * * * Rscript /home/ruser/GANNTrader/server/R/getRealtimeData.R --vanilla  
57 */1 * * * Rscript /home/ruser/GANNTrader/server/R/stockRealtimeData.R --vanilla  
00 */1 * * * /home/ruser/GANNTrader/server/pushGithubhour.sh  
30 7 * * sat /home/ruser/GANNTrader/server/performance/getOrderBook.sh 
