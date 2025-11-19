# ===================================================================
# FUNCTIONS.R
# Contient toutes les fonctions de logique métier et de graphiques
# ===================================================================

library(ggplot2)
library(leaflet)

# Fonction pour créer la carte
# ------------------------------------------------
create_ufo_map <- function(data) {
  # 'data' est le jeu de données (déjà filtré ou non)
  
  leaflet(data) %>%
    addTiles() %>%
    addMarkers(
      lng = ~longitude, 
      lat = ~latitude,
      popup = ~paste("Forme:", shape, "<br>", "Date:", datetime),
      clusterOptions = markerClusterOptions() # Regroupement pro
    )
}

# Fonction pour l'analyse temporelle
# ------------------------------------------------
plot_temporal_analysis <- function(data, group_by_var) {
  # 'data' est le jeu de données
  # 'group_by_var' est un string (ex: "year", "month", "hour")
  
  # Utilisation de la métaprogrammation (!!sym()) pour Ggplot
  data_agg <- data %>%
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

# ... autres fonctions (ex: plot_shape_analysis) ...