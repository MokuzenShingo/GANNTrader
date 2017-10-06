cd /home/ruser/GANNTrader/
Rscript -e "rmarkdown::render('./server/docs/Untitled.Rmd')"
cd /home/ruser/GANNTrader/server/
git add .
git commit -m "update report"
git push -u origin master
