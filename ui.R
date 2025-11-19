# ===================================================================
# UI.R
# ===================================================================

# --- INITIALISATION ---
if (exists("ufo_data")) {
  # Données chargées
  min_year_ui <- min(ufo_data$year, na.rm = TRUE)
  max_year_ui <- max(ufo_data$year, na.rm = TRUE)
  shapes_ui   <- sort(unique(ufo_data$shape))
  states_ui   <- sort(unique(ufo_data$state))
} else {
  # Valeurs par défaut (sécurité)
  min_year_ui <- 1949
  max_year_ui <- 2023
  shapes_ui   <- c("circle", "light", "triangle")
  states_ui   <- c("CA", "NY", "TX")
}

page_sidebar(
  fillable = FALSE,
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  title = "Observations d'OVNIs",
  
  # --- SIDEBAR ---
  sidebar = sidebar(
    title = "Filtres",
    class = "bg-light",
    
    sliderInput("year_slider", 
                "Période d'analyse :",
                min = min_year_ui, 
                max = max_year_ui,
                value = c(min_year_ui, max_year_ui), 
                sep = ""),
    
    selectizeInput("shape_select", 
                   "Formes observées :",
                   choices = shapes_ui,
                   selected = NULL,
                   multiple = TRUE,
                   options = list(placeholder = "Toutes les formes...")),
    
    selectizeInput("state_select", 
                   "États (USA) :",
                   choices = c("Tous" = "all", states_ui),
                   selected = "all",
                   multiple = TRUE),
    
    hr(),
    
    div(style = "font-size: 0.8rem; color: #7f8c8d; margin-top: 10px;",
        "Données : National UFO Reporting Center")
  ),
  
  # --- MAIN LAYOUT ---
  
  
  # 1. Valeurs mesurable
  layout_columns(
    fill = FALSE,
    value_box(title = "Observations totales", value = textOutput("kpi_total"), showcase = icon("eye"), theme = "primary"),
    value_box(title = "Durée moyenne", value = textOutput("kpi_duration"), showcase = icon("stopwatch"), theme = "secondary"),
    value_box(title = "Forme la plus vue", value = textOutput("kpi_shape"), showcase = icon("shapes"), theme = "info")
  ),
  
  # 2. Dashboard
  navset_card_underline(
    title = "Tableau de Bord",
    
    # Carte
    nav_panel("Cartographie", icon = icon("map-location-dot"),
              card_body(
                leafletOutput("map_output", height = "600px") 
              )
    ),
    
    # Statistiques
    nav_panel("Analyses Statistiques", icon = icon("chart-line"),
              
              layout_columns(
                col_widths = c(6, 6),
                row_heights = "auto", 
                
                card(
                  full_screen = TRUE,
                  card_header("1. Tendance temporelle"),
                  plotlyOutput("plot_trend", height = "350px")
                ),
                card(
                  full_screen = TRUE,
                  card_header("2. Top 10 des formes"),
                  plotlyOutput("plot_shapes", height = "350px")
                ),
                card(
                  full_screen = TRUE,
                  card_header("3. Saisonnalité (Mois)"),
                  plotlyOutput("plot_seasonality", height = "350px")
                ),
                card(
                  full_screen = TRUE,
                  card_header("4. Heures de la journée"),
                  plotlyOutput("plot_hourly", height = "350px")
                ),
                card(
                  full_screen = TRUE,
                  card_header("5. Distribution des durées (Log)"),
                  plotlyOutput("plot_duration", height = "350px")
                )
              ),
              
              # Heatmap
              layout_columns(
                col_widths = 12,
                card(
                  full_screen = TRUE,
                  card_header("6. Heatmap : Jours vs Heures"),
                  plotlyOutput("plot_heatmap", height = "500px")
                )
              )
    ),
    
    # Data Table
    nav_panel("Explorateur de Données", icon = icon("table"),
              card_body(
                p("Tableau des données brutes correspondant aux filtres actuels."),
                DTOutput("table_output")
              )
    )
  )
)