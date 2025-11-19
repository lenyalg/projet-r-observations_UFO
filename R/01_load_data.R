# ===================================================================
# 01_LOAD_DATA.R
# ===================================================================

library(readr) 
data_path <- "data/complete.csv"
raw_data <- readr::read_csv(data_path, 
                            col_types = cols(.default = "c")) 
message("Données brutes ('raw_data') chargées.")
