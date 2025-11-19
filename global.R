# ===================================================================
# GLOBAL.R
# ===================================================================

# 1. CHARGEMENT DES LIBRAIRIES
library(shiny)
library(bslib)
library(dplyr)
library(ggplot2)
library(lubridate)
library(leaflet)
library(DT)
library(forcats)
library(stringr)
library(plotly)
library(janitor)

# 2. CHARGEMENT DES DONNÉES
# On garde ta structure existante qui va chercher les scripts dans le dossier R/
message("global.R: Chargement des scripts...")

# Charge les données brutes (crée 'raw_data')
if(file.exists("R/01_load_data.R")) source("R/01_load_data.R")

# Nettoie les données (crée 'ufo_data')
if(file.exists("R/02_clean_data.R")) source("R/02_clean_data.R")

# Charge les fonctions
if(file.exists("R/functions.R")) source("R/functions.R")

# Sécurités pour l'UI si les données ne chargent pas (valeurs par défaut)
if (!exists("ufo_data")) {
  ufo_data <- data.frame(year = 2000:2023, shape = "circle", state = "TX")
}

# Pré-calcul des variables pour les inputs de l'UI
min_year_ui <- min(ufo_data$year, na.rm = TRUE)
max_year_ui <- max(ufo_data$year, na.rm = TRUE)
shapes_ui   <- sort(unique(na.omit(ufo_data$shape)))
states_ui   <- sort(unique(na.omit(ufo_data$state)))

message("global.R: Chargement terminé.")