usdjpy <- getSymbols("USD/JPY", src = "oanda", auto.assign = FALSE)
eurkpw <- getSymbols("EUR/KPW", src = "oanda", auto.assign = FALSE)

data(citytemp, package = "highcharter")
data(worldgeojson, package = "highcharter")
data(sample_matrix, package = "xts")
data('GNI2014', package = "treemap")
data(diamonds, package = "ggplot2")

dscounts <- dplyr::count(diamonds, cut) %>% 
  setNames(c("name", "value")) %>% 
  list.parse3()

dsheatmap <- tbl_df(expand.grid(seq(12) - 1, seq(5) - 1)) %>% 
  mutate(value = abs(seq(nrow(.)) + 10 * rnorm(nrow(.))) + 10,
         value = round(value, 2)) %>% 
  list.parse2()

f <- exp

dshmstops <- data.frame(q = c(0, f(1:5)/f(5)), c = substring(viridis(5 + 1), 0, 7)) %>% 
  list.parse2()

  hcbase <- reactive({
    # hcbase <- function() highchart() 
    hc <- highchart() 
    

    if (input$credits)
      hc <- hc %>% hc_credits(enabled = TRUE, text = "Highcharter", href = "http://jkunst.com/highcharter/")
    
    if (input$exporting)
      hc <- hc %>% hc_exporting(enabled = TRUE)
    
    if (input$theme != FALSE) {
      theme <- switch(input$theme,
                      null = hc_theme_null(),
                      economist = hc_theme_economist(),
                      dotabuff = hc_theme_db(),
                      darkunica = hc_theme_darkunica(),
                      gridlight = hc_theme_gridlight(),
                      sandsignika = hc_theme_sandsignika(),
                      fivethirtyeight = hc_theme_538(),
                      chalk = hc_theme_chalk(),
                      handdrwran = hc_theme_handdrawn()
      )
      
      hc <- hc %>% hc_add_theme(theme)
    }
    
    hc
    
  })
  
  output$highchart <- renderHighchart({
    
    hcbase() %>% 
      hc_title(text = "Monthly Average Temperature") %>% 
      hc_subtitle(text = "Source: WorldClimate.com") %>% 
      hc_yAxis(title = list(text = "Temperature")) %>% 
      hc_xAxis(categories = citytemp$month) %>% 
      hc_add_series(name = "Tokyo", data = citytemp$tokyo) %>% 
      hc_add_series(name = "London", data = citytemp$london) %>% 
      hc_add_series(name = "Berlin", data = citytemp$berlin) 
    
  })
  
  output$highstock <- renderHighchart({
    
    hcbase() %>% 
      hc_add_series_xts(usdjpy, id = "usdjpy") %>% 
      hc_add_series_xts(eurkpw, id = "eurkpw")
    
  })
  
  output$highmap <- renderHighchart({
    
    hcbase() %>% 
      hc_add_series_map(worldgeojson, GNI2014, value = "GNI", joinBy = "iso3") %>% 
      hc_colorAxis(stops = dshmstops) 
    
  })
  
  output$highscatter <- renderHighchart({
    
    hcbase() %>% 
      hc_add_series_scatter(mtcars$wt, mtcars$mpg,
                            mtcars$drat, mtcars$hp,
                            rownames(mtcars),
                            dataLabels = list(
                              enabled = TRUE,
                              format = "{point.label}"
                            ))
    
  })
  
  output$highstreemap <- renderHighchart({
    
    hcbase() %>% 
      hc_add_series(data = dscounts, type = "treemap", colorByPoint = TRUE) 
    
  })
  
  output$highohlc <- renderHighchart({
    
    hcbase() %>% 
      hc_add_series_ohlc(as.xts(sample_matrix))
    
  })

  output$highheatmap <- renderHighchart({
    
    hcbase() %>% 
      hc_chart(type = "heatmap") %>% 
      hc_xAxis(categories = month.abb) %>% 
      hc_yAxis(categories = 2016 - length(dsheatmap)/12 + seq(length(dsheatmap)/12)) %>% 
      hc_add_series(name = "value", data = dsheatmap) %>% 
      hc_colorAxis(min = 0) 
    
  })
  
  ts <- reactive({
    
    get(input$ts)
    
  })
  
  output$tschart <- renderHighchart({hchart(ts())})
  
  output$tsacf <- renderHighchart({hchart(acf(ts(), plot = FALSE))})
  
  output$tspacf <- renderHighchart({hchart(pacf(ts(), plot = FALSE))})
  
  output$tsforecast <- renderHighchart({
    
    ts <- ts()
    # highcharter:::hchart.forecast
    object <- forecast(ts, level = 95)
    tmf <- datetime_to_timestamp(zoo::as.Date(time(object$mean)))
    nmf <- paste("level", object$level)
    
    dsf <- data_frame(tmf, object$mean) %>% 
      list.parse2()
    
    highchart() %>% 
      hc_add_series_ts(object$x, name = input$ts) %>% 
      hc_add_series(data = dsf, name = "AutoArima Forecast",
                    marker = list(enabled = FALSE),
                    enableMouseTracking = FALSE) %>% 
      hc_add_series(data = dsf, name = "Your Forecast",
                    cursor = "ns-resize", draggableY = TRUE) %>% 
      hc_plotOptions(
        series = list(
          point = list(
            events = list(
              drop = JS("function(){
                        console.log(this.series)
                        window.data = _.map(this.series.data, function(e) { return e.y })
                        Shiny.onInputChange('manualforecast', data);
                        }"))
              )))
    
  })
  
  output$dfforecast <- renderDataTable({
    
    ts <- ts()
    mf <- input$manualforecast #listening the drop event defined in output$tsforecast
    fc <- forecast(ts)$mean
    
    # if you change timeseries input$manualforecast dont change
    # so we update it
    if (is.null(mf) || length(mf) != length(fc))  
      mf <- fc
    
    data_frame(
      datetime = as.Date(time(forecast(ts)$mean)),
      forecast = fc,
      manualforecast = mf,
      diff = round((mf - fc)/fc, 2)
    )
    
  })
  
  output$pluginsfa <- renderHighchart({
    title <- tags$div(icon("quote-left"), "This is a h1 title with a awesome icon", icon("bar-chart"))
    title <- as.character(title)
    
    subtitle <- tags$div("This can be", icon("thumbs-o-up"), "wait for it... awesome")
    subtitle <- as.character(subtitle)
    
    # https://github.com/FortAwesome/Font-Awesome/blob/master/less/variables.less
    
    highchart() %>%
      hc_title(text = title, useHTML = TRUE) %>% 
      hc_subtitle(text = subtitle, useHTML = TRUE) %>% 
      hc_tooltip(
        useHTML = TRUE,
        pointFormat = '<span style="color:{series.color};">{series.options.icon}</span> {series.name}: <b>[{point.x}, {point.y}]</b><br/>'
      ) %>% 
      hc_add_series_scatter(mtcars$mpg[1:16], mtcars$disp[1:16],
                            marker = list(symbol = "text:\\\uf1b9"),
                            icon = as.character(shiny::icon("car")),
                            name = "cars", showInLegend = TRUE) %>% 
      hc_add_series_scatter(mtcars$mpg[17:32], mtcars$disp[17:32],
                            marker = list(symbol = "text:\\\uf1ba"),
                            icon = as.character(shiny::icon("taxi")),
                            name = "cabs", showInLegend = TRUE)  %>% 
      hc_add_theme(hc_theme_google()) %>% 
      hc_chart(zoomType = "xy")
    
  })
  
