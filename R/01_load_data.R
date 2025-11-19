# ===================================================================
# 01_LOAD_DATA.R
# Charge les données brutes depuis /data
# ===================================================================

library(readr) # readr::read_csv est plus rapide que read.csv

# Chemin relatif vers le fichier de données
data_path <- "data/complete.csv"

# Charge les données dans un objet 'raw_data'
# On gère les problèmes de type ici si nécessaire
raw_data <- readr::read_csv(data_path, 
                            col_types = cols(.default = "c")) # Charger tout en 'character' d'abord est plus sûr

# Message pour la console (bon pour le debug)
message("Données brutes ('raw_data') chargées.")