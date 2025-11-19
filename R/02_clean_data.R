# ===================================================================
# 02_CLEAN_DATA.R
#
# Objectif : Transformer 'raw_data' en 'ufo_data', un jeu de données
#            propre, enrichi et prêt pour l'analyse et Shiny.
#
# Packages requis (doivent être chargés dans app.R) :
# - dplyr
# - janitor
# - lubridate
# - stringr
# - forcats
# ===================================================================

# Message de début
message("Lancement de 02_clean_data.R : Nettoyage et transformation...")

# Supposons que 'raw_data' existe (chargé par 01_load_data.R)

ufo_data <- raw_data %>%

  # -----------------------------------------------------------------
  # ÉTAPE 1 : Nettoyage des noms de colonnes
  # -----------------------------------------------------------------
  # Pro-tip : 'janitor::clean_names()' standardise les noms.
  # "duration (seconds)" devient "duration_seconds"
  # "date posted" devient "date_posted"
  janitor::clean_names() %>%

  # -----------------------------------------------------------------
  # ÉTAPE 2 : Conversion des types et parsing
  # -----------------------------------------------------------------
  # C'est une source d'erreur majeure chez les débutants.
  # On force les types pour la latitude, longitude et durée.
  mutate(
    latitude = as.numeric(latitude),
    # On utilise readr::parse_number pour gérer les éventuels text_processing
    # mais as.numeric est souvent suffisant si le CSV est bien formé.
    longitude = as.numeric(longitude),
    duration_seconds = as.numeric(duration_seconds),

    # Parsing des dates : la variable la plus importante.
    # Le format est souvent MM/JJ/AAAA HH:MM. On utilise lubridate.
    datetime = lubridate::mdy_hm(datetime)
  ) %>%

  # -----------------------------------------------------------------
  # ÉTAPE 3 : Filtrage (L'étape de décision)
  # -----------------------------------------------------------------
  # Un pro ne fait JAMAIS 'na.omit()'. On filtre sur ce qui est
  # indispensable à notre analyse.
  filter(
    !is.na(datetime),         # Une observation sans date est inutile
    !is.na(latitude),         # Inutile pour la cartographie
    !is.na(longitude),
    !is.na(shape),            # Inutile pour l'analyse des formes
    !is.na(duration_seconds)
  ) %>%

  # Décision d'analyse : Se concentrer sur les données les plus riches.
  # Le dataset est à 90% américain. On se concentre sur les US
  # pour avoir des données 'state' cohérentes.
  filter(
    country == "us",
    # On filtre les dates. Les données avant 1990 sont très
    # sporadiques et polluent les graphiques de tendance.
    # C'est un choix d'analyse à justifier dans le rapport.
    lubridate::year(datetime) >= 1949
  ) %>%
  
  # Filtrer les outliers de durée (observations > 1 jour)
  filter(
    duration_seconds > 0,
    duration_seconds < (3600 * 24) # Garde les obs. < 24 heures
  ) %>%

  # -----------------------------------------------------------------
  # ÉTAPE 4 : Enrichissement (Feature Engineering)
  # -----------------------------------------------------------------
  # On crée des variables utiles pour les 'group_by' et les filtres.
  mutate(
    year = lubridate::year(datetime),
    month = lubridate::month(datetime, label = TRUE, abbr = FALSE),
    hour = lubridate::hour(datetime),
    weekday = lubridate::wday(datetime, label = TRUE, abbr = FALSE),

    # Catégoriser l'heure pour une analyse "Jour" vs "Nuit"
    time_of_day = case_when(
      hour >= 6 & hour < 12 ~ "Matin (06-12h)",
      hour >= 12 & hour < 18 ~ "Après-midi (12-18h)",
      hour >= 18 & hour < 22 ~ "Soirée (18-22h)",
      TRUE ~ "Nuit (22-06h)"
    )
  ) %>%

  # -----------------------------------------------------------------
  # ÉTAPE 5 : Standardisation des variables catégorielles
  # -----------------------------------------------------------------
  mutate(
    # Standardiser les noms d'états (ex: "tx" -> "TX")
    state = toupper(state),
    
    # Standardiser les formes (le plus gros travail)
    shape = tolower(shape),
    shape = case_when(
      # Regroupements sémantiques
      shape %in% c("round", "sphere") ~ "circle",
      shape %in% c("lights") ~ "light",
      shape %in% c("cigar-shaped") ~ "cigar",
      shape %in% c("fireball", "flare") ~ "fireball",
      
      # Garder les autres tels quels pour le 'lumping'
      TRUE ~ shape
    ),
    
    # Pro-tip : 'fct_lump_n' de forcats.
    # Garde les 10 formes les plus fréquentes et regroupe
    # toutes les autres dans "Other". Indispensable
    # pour des graphiques lisibles (Pie charts, bar plots).
    shape = forcats::fct_lump_n(shape, n = 10, other_level = "Other")
  ) %>%

  # -----------------------------------------------------------------
  # ÉTAPE 6 : Sélection finale
  # -----------------------------------------------------------------
  # On garde uniquement les colonnes utiles pour l'application.
  # Cela réduit l'utilisation de la mémoire.
  select(
    # Variables temporelles
    datetime, year, month, hour, weekday, time_of_day,
    
    # Variables géographiques
    city, state, latitude, longitude,
    
    # Variables de description
    shape, duration_seconds, comments
  )

# Message de fin
message(paste("Nettoyage terminé. 'ufo_data' créé avec", 
              nrow(ufo_data), "lignes et", 
              ncol(ufo_data), "colonnes."))