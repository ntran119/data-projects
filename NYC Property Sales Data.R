install.packages("devtools")
devtools::install_github("datadotworld/data.world-r", build_vignettes = TRUE)

saved_cfg <- data.world::save_config("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50Om50cmFuMTE5IiwiaXNzIjoiYWdlbnQ6bnRyYW4xMTk6OjAyODFmMjg2LWQwZTAtNGYzMC1hNDJkLTcwNDRhNjMxMWU1NCIsImlhdCI6MTY1MzUwODg4NSwicm9sZSI6WyJ1c2VyX2FwaV9yZWFkIiwidXNlcl9hcGlfd3JpdGUiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlLCJzYW1sIjp7fX0.qCJIWBUN2jzFs9-N1iFvIrhUjSm58BeO2kZb0CfCanxqifpUO1kYP4-m-Xf7uh1afy4sbWIgVATas3xO2jFWBw")
data.world::set_config(saved_cfg)

vignette("quickstart", package = "data.world")

nyc_df <- data.world::(
  data.world::qry_sql('SELECT * FROM NYC_property_sales.csv'),
  dataset = 'https://data.world/dataquest/nyc-property-sales-data'
)
