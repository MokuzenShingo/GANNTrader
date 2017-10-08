shinyUI(fluidPage(
  titlePanel("GANNTrader return analysis"),
  p("Data update every Saturday"),
  fluidRow(
    column(4,
           wellPanel(
             dateRangeInput("dateRange", "period : from 2016-01-04", start = Sys.Date() - 14, end = Sys.Date()),
             checkboxGroupInput("selectPlot", "plot trades  ( green : long, blue : short )", c("entry" = "entry", "exit" = "exit")),
             sliderInput("bins", "Number of bins", min = 5, max = 50, value = 30),
             sliderInput("histrange", "range", min = 1, max = 5, value = 2)
           )
    ),
    column(8,
           plotOutput("chartPlot"),
           p(" "),
           column(6, plotOutput("histPlot")),
           column(6, tableOutput("summaryTable"))
    )
  )
))