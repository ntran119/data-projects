# July 8, 2021
# New York City Property Sales
# @ntran119

#install.packages("devtools")
library(devtools)
devtools::install_github("datadotworld/data.world-r", build_vignettes = TRUE)

saved_cfg <- data.world::save_config("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50Om50cmFuMTE5IiwiaXNzIjoiYWdlbnQ6bnRyYW4xMTk6OjAyODFmMjg2LWQwZTAtNGYzMC1hNDJkLTcwNDRhNjMxMWU1NCIsImlhdCI6MTY1MzUwODg4NSwicm9sZSI6WyJ1c2VyX2FwaV9yZWFkIiwidXNlcl9hcGlfd3JpdGUiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlLCJzYW1sIjp7fX0.qCJIWBUN2jzFs9-N1iFvIrhUjSm58BeO2kZb0CfCanxqifpUO1kYP4-m-Xf7uh1afy4sbWIgVATas3xO2jFWBw")
data.world::set_config(saved_cfg)

vignette("quickstart", package = "data.world") # view vignette

nyc_df <- data.world::query(
  data.world::qry_sql('SELECT * FROM NYC_property_sales'),
  dataset = 'https://data.world/dataquest/nyc-property-sales-data')


glimpse(nyc_df)

n_distinct(nyc_df$building_class_category)

unique(nyc_df$building_class_at_time_of_sale)

nyc_condos <- nyc_df %>%
  filter(building_class_at_time_of_sale == 'R4')

ggplot(nyc_condos, aes(x=gross_square_feet, y = sale_price, color = borough)) + 
  geom_point(alpha = 0.3) +
  scale_y_continuous(labels = scales::comma, limits = c(0, 7500000)) +
  xlim(0, 10000) +
  geom_smooth(method = 'lm', se = FALSE) +
  labs(title = 'NYC Condos Sale Price Increases with Size',
       y = 'Sale Price (USD)',
       x = 'Size (Gross Square Feet)') +
  theme_minimal()

#larger condos are associated with higher sale price, 
#data follows linear pattern, fair amount of spread

ggplot(nyc_condos, aes(x=gross_square_feet, y = sale_price, color = borough)) + 
  geom_point(alpha = 0.3) +
  scale_y_continuous(labels = scales::comma, limits = c(0, 20000000)) +
  xlim(0, 5000) +
  geom_smooth(method = 'lm', se = FALSE) +
  labs(title = 'NYC Condos Sale Price Increases with Size',
       y = 'Sale Price (USD)',
       x = 'Size (Gross Square Feet)')

ggplot(nyc_condos, aes(x=gross_square_feet, y = sale_price, color = borough)) + 
  geom_point(alpha = 0.3) +
  scale_y_continuous(labels = scales::comma) +
  geom_smooth(method = 'lm', se = FALSE) +
  labs(title = 'NYC Condos Sale Price Increases with Size',
       y = 'Sale Price (USD)',
       x = 'Size (Gross Square Feet)') +
  facet_wrap(facets = vars(borough), scales = 'free', ncol = 2)

#spread is hard to see with manhattan due to outliters
#most follow linear relationship except for queens

#### 4. Outliers and Data Integrity Issues ####

outlier1 <- nyc_condos %>%
  filter(str_detect(.$address, '165 East'))
#remove outlier 
nyc_condos2 <- nyc_condos %>%
  filter(!(address %in% outlier1$address))

#investigate brooklyn sale price $29,620,207
brooklyn_outlier <- nyc_condos2 %>%
  filter(borough == 'Brooklyn', sale_price == 29620207)

#they all have the same sale date, each price is the same, probably all purchased on same dday
#filter out in original dataframe

nyc_condos3 <- nyc_condos2 %>%
  anti_join(brooklyn_outlier)

#check to see if it was correctly removed
any(nyc_condos3$sale_price == 29620207)
