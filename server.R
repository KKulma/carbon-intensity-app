server <- function(input, output, session) {
  region_data <- reactive({
    req(input$region, cancelOutput = TRUE)
    df_data <- daily_ci %>%
      filter(shortname == input$region)
  }) %>%
    bindCache(input$region)
  
  
  output$carbon_plot <- renderUI({
    if (input$heatmap == TRUE) {
      plotlyOutput(outputId = 'heatplot')
    } else {
      dygraphOutput(outputId = "dyplot")
    }
  })
  
  output$dyplot <- renderDygraph({
    req(region_data())
    xts_data <-  xts(x = region_data()$renewable_perc,
                     order.by = region_data()$from_dt)
    dygraph(xts_data) %>%
      dyRangeSelector() %>%
      dyAxis("x", drawGrid = FALSE) %>%
      dyAxis("y",
             axisLabelFormatter = "function(v){return (v).toFixed(0)+ '%'}") %>%      
      dySeries(label = "% renewable") %>% 
      dyOptions(fillGraph = TRUE, fillAlpha = 0.4, colors = viridis(1))
  }) %>%
    bindCache(input$region)
  
  output$heatplot <- renderPlotly({
    req(region_data())
    
    granular_df <- region_data() %>%
      mutate(
        day = day(from_dt),
        month = month(from_dt, label = TRUE, abbr = TRUE),
        year = year(from_dt)
      )
    
    print(
      ggplotly(
        ggplot(granular_df, aes(month, day, fill = renewable_perc)) +
          geom_tile(color = "white", size = 0.1) +
          scale_fill_viridis(name = "% Renewable", option = "C") +
          facet_grid( ~ year) +
          theme_minimal(base_size = 8) +
          labs(
            title = paste("Daily Carbon Intensity in", input$region),
            y = "Day",
            x = ""
          ) +
          theme(text = element_text(size=12),
                axis.text.x = element_text(angle=90, hjust=1),
                legend.position="bottom")
      )
    )
  }) %>%
    bindCache(input$region)
}
