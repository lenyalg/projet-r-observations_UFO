# ===================================================================
# FUNCTIONS.R
# ===================================================================

library(ggplot2)
library(leaflet)

create_ufo_map <- function(data) {
  leaflet(data) |>
    addTiles() |>
    addMarkers(
      lng = ~longitude, 
      lat = ~latitude,
      popup = ~paste("Forme:", shape, "<br>", "Date:", datetime),
      clusterOptions = markerClusterOptions() 
    )
}

plot_temporal_analysis <- function(data, group_by_var) {
  data_agg <- data |>
    count(!!sym(group_by_var))
  
  ggplot(data_agg, aes(x = !!sym(group_by_var), y = n)) +
    geom_col(fill = "cyan") +
    labs(
      title = paste("Nombre d'observations par", group_by_var),
      x = group_by_var,
      y = "Nombre d'observations"
    ) +
    theme_minimal()
}

