# ===================================================================
# 02_CLEAN_DATA.R
# ===================================================================


message("Lancement de 02_clean_data.R : Nettoyage et transformation...")
ufo_data <- raw_data |>
  janitor::clean_names() |>
  mutate(
    latitude = as.numeric(latitude),
    longitude = as.numeric(longitude),
    duration_seconds = as.numeric(duration_seconds),
    datetime = lubridate::mdy_hm(datetime)
  ) |>

  filter(
    !is.na(datetime),         
    !is.na(latitude),        
    !is.na(longitude),
    !is.na(shape),            
    !is.na(duration_seconds)
  ) |>

  filter(
    country == "us",
    lubridate::year(datetime) >= 1949
  ) |>


  filter(
    duration_seconds > 0,
    duration_seconds < (3600 * 24) 
  ) |>


  mutate(
    year = lubridate::year(datetime),
    month = lubridate::month(datetime, label = TRUE, abbr = FALSE),
    hour = lubridate::hour(datetime),
    weekday = lubridate::wday(datetime, label = TRUE, abbr = FALSE),

    time_of_day = case_when(
      hour >= 6 & hour < 12 ~ "Matin (06-12h)",
      hour >= 12 & hour < 18 ~ "Après-midi (12-18h)",
      hour >= 18 & hour < 22 ~ "Soirée (18-22h)",
      TRUE ~ "Nuit (22-06h)"
    )
  ) |>


  mutate(
    state = toupper(state),
    shape = tolower(shape),
    shape = case_when(
      shape %in% c("round", "sphere") ~ "circle",
      shape %in% c("lights") ~ "light",
      shape %in% c("cigar-shaped") ~ "cigar",
      shape %in% c("fireball", "flare") ~ "fireball",
      TRUE ~ shape
    ),
    shape = forcats::fct_lump_n(shape, n = 10, other_level = "Other")
  ) |>

  select(
    datetime, year, month, hour, weekday, time_of_day,
    city, state, latitude, longitude,
    shape, duration_seconds, comments
  )

message(paste("Nettoyage terminé. 'ufo_data' créé avec", 
              nrow(ufo_data), "lignes et", 
              ncol(ufo_data), "colonnes."))
