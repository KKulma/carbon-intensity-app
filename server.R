server <- function(input, output, session) {
  # # If the URL contains a region on load, use that region instead of the default of ann arbor
  bookmarked_region <- parse_url_hash(isolate(getUrlHash()))
  current_region <-
    reactiveVal(if (bookmarked_region %in% unique_regions)
      bookmarked_region
      else
        "London")
  updateSelectizeInput(inputId = "region", selected = isolate(current_region()))
  
  # A book-keeping reactive so we can have a previous region button
  previous_region <- reactiveVal(NULL)
  
  observe({
    req(input$region)
    # Set the previous region to the non-updated current region. If app is just
    # starting we want to populate the previous region button with a random region,
    # not the current region
    selected_region <- isolate(current_region())
    just_starting <- selected_region == input$region
    previous_region(if (just_starting)
      previous_region(selected_region)
      else
        selected_region)
    
    # Current region now can be updated to the newly selected region
    current_region(input$region)
    
    # Update the query string so the app will know what to do.
    updateQueryString(make_url_hash(current_region()), mode = "push")
  })
  
  observe({
    updateSelectizeInput(inputId = "region",
                         selected = isolate(previous_region()))
  }) %>% bindEvent(input$prev_region)
  
  
  region_data <- reactive({
    req(input$region, cancelOutput = TRUE)
    df_data <- daily_ci %>%
      filter(shortname == input$region)
    
    
    # Our results will always be the same for a given region, so cache on that key
    
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
      dyRangeSelector()
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
            y = "Day"
          ) +
          theme(legend.position = "bottom")
      )
    )
  }) %>%
    bindCache(input$region)
  
  
  
}
