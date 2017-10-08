# GANNTrader

### crontab
*/5 * * * * Rscript /server/R/getRealtimeData.R --vanilla  
57 */1 * * * Rscript /server/R/stockRealtimeData.R --vanilla  
00 */1 * * * /server/pushGithubhour.sh  
30 7 * * sat /server/performance/getOrderBook.sh 
