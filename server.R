# ===================================================================
# SERVER.R
# ===================================================================

function(input, output, session) {
  
  # --- TRAITEMENT DES DONNÉES ---
  filtered_data <- reactive({
    req(input$year_slider)
    
    df <- ufo_data |>
      filter(year >= input$year_slider[1], year <= input$year_slider[2])
    
    if (!is.null(input$shape_select) && length(input$shape_select) > 0) {
      df <- df |> filter(shape %in% input$shape_select)
    }
    if (!is.null(input$state_select) && !("all" %in% input$state_select)) {
      df <- df |> filter(state %in% input$state_select)
    }
    return(df)
  })
  
  # --- INDICATEURS ---
  output$kpi_total <- renderText({ format(nrow(filtered_data()), big.mark = " ") })
  
  output$kpi_duration <- renderText({
    df <- filtered_data()
    if (nrow(df) == 0) return("-")
    mean_sec <- mean(df$duration_seconds, na.rm = TRUE)
    if (mean_sec > 60) { paste(round(mean_sec / 60, 1), "min") } else { paste(round(mean_sec, 0), "sec") }
  })
  
  output$kpi_shape <- renderText({
    df <- filtered_data()
    if (nrow(df) == 0) return("-")
    top <- df |> count(shape, sort = TRUE) |> slice(1) |> pull(shape)
    str_to_title(top)
  })
  
  # --- CARTOGRAPHIE ---
  output$map_output <- renderLeaflet({
    leaflet() |>
      addProviderTiles(providers$CartoDB.Positron) |>
      setView(lng = -98.5, lat = 39.8, zoom = 4)
  })
  
  observe({
    df <- filtered_data()
    
    proxy <- leafletProxy("map_output", data = df) |> 
      clearMarkers() |> 
      clearMarkerClusters()
    
    if (nrow(df) > 0) {
      proxy |>
        addCircleMarkers(
          lng = ~longitude, lat = ~latitude, radius = 6, stroke = FALSE,
          fillColor = "#2c3e50", fillOpacity = 0.7,
          clusterOptions = markerClusterOptions(),
          popup = ~paste0("<b>Année:</b> ", year, "<br><b>Forme:</b> ", shape)
        )
    }
  })
  
  # --- VISUALISATIONS ---
  
  # 1. Tendance temporelle
  output$plot_trend <- renderPlotly({
    req(nrow(filtered_data()) > 0)
    p <- filtered_data() |>
      count(year) |>
      ggplot(aes(x = year, y = n)) +
      geom_line(color = "#18bc9c", linewidth = 1) +
      geom_area(fill = "#18bc9c", alpha = 0.2) +
      theme_minimal(base_size = 12) +
      labs(x = "Année", y = "Nombre d'observations")
    ggplotly(p) |> config(displayModeBar = FALSE)
  })
  
  # 2. Top Formes
  output$plot_shapes <- renderPlotly({
    req(nrow(filtered_data()) > 0)
    p <- filtered_data() |>
      count(shape, sort = TRUE) |>
      head(10) |>
      mutate(shape = fct_reorder(shape, n)) |>
      ggplot(aes(x = shape, y = n, text = paste("Total:", n))) +
      geom_col(fill = "#3498db") +
      coord_flip() +
      theme_minimal(base_size = 12) +
      labs(x = "", y = "")
    ggplotly(p, tooltip = "text") |> config(displayModeBar = FALSE)
  })
  
  # 3. Saisonnalité
  output$plot_seasonality <- renderPlotly({
    req(nrow(filtered_data()) > 0)
    p <- filtered_data() |>
      mutate(month_label = month(datetime, label = TRUE, abbr = TRUE, locale = "C")) |>
      count(month_label) |>
      ggplot(aes(x = month_label, y = n)) +
      geom_col(fill = "#f39c12") +
      theme_minimal(base_size = 12) +
      labs(x = "Mois", y = "Nombre d'observations")
    ggplotly(p) |> config(displayModeBar = FALSE)
  })
  

  # 4. Fréquence horaire
  output$plot_hourly <- renderPlotly({
    req(nrow(filtered_data()) > 0)
    p <- filtered_data() |>
      mutate(hour_val = hour(datetime)) |>
      count(hour_val) |>
      ggplot(aes(x = hour_val, y = n)) +
      geom_line(color = "#8e44ad", size = 1) +
      theme_minimal(base_size = 12) +
      scale_x_continuous(breaks = seq(0, 23, 4)) +
      labs(x = "Heure", y = "Nombre d'observations")
    ggplotly(p) |> config(displayModeBar = FALSE)
  })
  
  # 5. Distribution des durées
  output$plot_duration <- renderPlotly({
    req(nrow(filtered_data()) > 0)
    p <- filtered_data() |>
      filter(duration_seconds > 0) |>
      ggplot(aes(x = duration_seconds)) +
      geom_histogram(fill = "#95a5a6", bins = 30, color="white") +
      scale_x_log10(labels = scales::comma) +
      theme_minimal(base_size = 12) +
      labs(x = "Durée (secondes, échelle log)", y = "Nombre d'observations")
    ggplotly(p) |> config(displayModeBar = FALSE)
  })
  
  # 6. Heatmap Jours/Heures
  output$plot_heatmap <- renderPlotly({
    req(nrow(filtered_data()) > 0)
    heatmap_data <- filtered_data() |>
      mutate(wday_label = wday(datetime, label = TRUE, abbr = TRUE, week_start = 1),
             hour_val = hour(datetime)) |>
      count(wday_label, hour_val)
    
    p <- ggplot(heatmap_data, aes(x = hour_val, y = wday_label, fill = n)) +
      geom_tile(color = "white") +
      scale_fill_viridis_c(option = "plasma") +
      theme_minimal(base_size = 12) +
      labs(x = "Heure (00h-23h)", y = "Jour", fill = "Nombre d'observations") +
      scale_x_continuous(breaks = seq(0, 23, 2))
    
    ggplotly(p) |> config(displayModeBar = FALSE)
  })
  
  # --- TABLEAU ---
  output$table_output <- renderDT({
    datatable(
      filtered_data() |> 
        select(Date = datetime, État = state, Ville = city, Forme = shape, Durée_s = duration_seconds, Commentaires = comments),
      style = "bootstrap", rownames = FALSE,
      options = list(pageLength = 10, scrollX = TRUE, language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/French.json'))
    )
  })
}