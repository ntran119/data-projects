# Aug 4, 2022
# Predicting Car Prices
# @ntran119

#### import dataframe with SQL ####
library(tidyverse)
library(devtools)

devtools::install_github("datadotworld/data.world-r", build_vignettes = TRUE)

saved_cfg <- data.world::save_config("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50Om50cmFuMTE5IiwiaXNzIjoiYWdlbnQ6bnRyYW4xMTk6OjAyODFmMjg2LWQwZTAtNGYzMC1hNDJkLTcwNDRhNjMxMWU1NCIsImlhdCI6MTY1MzUwODg4NSwicm9sZSI6WyJ1c2VyX2FwaV9yZWFkIiwidXNlcl9hcGlfd3JpdGUiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlLCJzYW1sIjp7fX0.qCJIWBUN2jzFs9-N1iFvIrhUjSm58BeO2kZb0CfCanxqifpUO1kYP4-m-Xf7uh1afy4sbWIgVATas3xO2jFWBw")
data.world::set_config(saved_cfg)

ds <- "https://data.world/uci/automobile"

cars_df <- data.world::query(
  data.world::qry_sql('SELECT * FROM imports_85_data'),
  dataset = ds
  )

#### 1 ####
#fix column names
colnames(cars_df) <- c(
  "symboling",
  "normalized_losses",
  "make",
  "fuel_type",
  "aspiration",
  "num_doors",
  "body_style",
  "drive_wheels",
  "engine_location",
  "wheel_base",
  "length",
  "width",
  "height",
  "curb_weight",
  "engine_type",
  "num_cylinders",
  "engine_size",
  "fuel_system",
  "bore",
  "stroke",
  "compression_ratio",
  "horsepower",
  "peak_rpm",
  "city_mpg",
  "highway_mpg",
  "price"
)


