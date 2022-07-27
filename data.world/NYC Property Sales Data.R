# July 8, 2021
# New York City Property Sales
# @ntran119

#### import dataframe with SQL ####
#install.packages("devtools")
library(devtools)
devtools::install_github("datadotworld/data.world-r", build_vignettes = TRUE)

saved_cfg <- data.world::save_config("eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJwcm9kLXVzZXItY2xpZW50Om50cmFuMTE5IiwiaXNzIjoiYWdlbnQ6bnRyYW4xMTk6OjAyODFmMjg2LWQwZTAtNGYzMC1hNDJkLTcwNDRhNjMxMWU1NCIsImlhdCI6MTY1MzUwODg4NSwicm9sZSI6WyJ1c2VyX2FwaV9yZWFkIiwidXNlcl9hcGlfd3JpdGUiXSwiZ2VuZXJhbC1wdXJwb3NlIjp0cnVlLCJzYW1sIjp7fX0.qCJIWBUN2jzFs9-N1iFvIrhUjSm58BeO2kZb0CfCanxqifpUO1kYP4-m-Xf7uh1afy4sbWIgVATas3xO2jFWBw")
data.world::set_config(saved_cfg)

vignette("quickstart", package = "data.world") # view vignette

nyc_df <- data.world::query(
  data.world::qry_sql('SELECT * FROM NYC_property_sales'),
  dataset = 'https://data.world/dataquest/nyc-property-sales-data')


#### explore data with graphs ####

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

multi_unit_sales <- nyc_condos3 %>%
  group_by(sale_price, sale_date) %>%
  filter(n() > 3) %>%
  arrange(desc(sale_price))

#remove multi unit sales
nyc_condos4 <- nyc_condos3 %>%
  anti_join(multi_unit_sales)

#### Linear Regression ####

nyc_condos_lm <- lm(sale_price ~ gross_square_feet, data = nyc_condos4)
nyc_condos_orignal <- lm(sale_price ~ gross_square_feet, data = nyc_condos)

summary(nyc_condos_lm)

summary(nyc_condos_orignal)

#confidence intervals
confint(nyc_condos_lm)
confint(nyc_condos_orignal)

#residual standard error
sigma(nyc_condos_lm)
sigma(nyc_condos_orignal)


ggplot(nyc_condos, aes(x=gross_square_feet, y=sale_price, colour=borough)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = 'lm', se = FALSE) +
  theme_minimal() +
  facet_wrap(facets = vars(borough), scales = 'free', ncol = 2) +
  scale_y_continuous(labels = scales::comma)

#### LM for each borough ####

library(broom)
library(purrr)

nested_boroughs <- nyc_condos4 %>%
  group_by(borough) %>%
  nest()

print(nested_boroughs)

head(nested_boroughs$data[[3]])

nyc_coeff <- nyc_condos4 %>%
  group_by(borough) %>%
  nest() %>%
  mutate(linear_model = map(.x = data,
                            .f = ~lm(sale_price ~ gross_square_feet, data = .)))

print(nyc_coeff)

summary(nyc_coeff$linear_model[[3]])

#R-squared = 0.63, 63% of the variability of sale_price is explained by gross_square_feet

# transform into tidy format

nyc_tidy <- nyc_condos4 %>%
  group_by(borough) %>%
  nest() %>%
  mutate(linear_model = map(.x = data,
                            .f = ~lm(sale_price ~ gross_square_feet, 
                                     data = .))) %>%
  mutate(tidy_coeff = map(.x = linear_model,
                          .f = tidy,
                          conf.int = TRUE))
nyc_tidy
nyc_tidy$tidy_coeff[[3]]

nyc_tidy_2 <- nyc_tidy %>%
  select(borough, tidy_coeff) %>%
  unnest(cols = tidy_coeff)

nyc_tidy_2

nyc_slope <- nyc_tidy_2 %>%
  filter(term == 'gross_square_feet') %>%
  arrange(estimate)

#### Regression Summary Statistics ####

nyc_sum <- nyc_condos4 %>%
  group_by(borough) %>%
  nest() %>%
  mutate(linear_model = map(.x = data,
                            .f = ~lm(sale_price ~ gross_square_feet, 
                                     data = .))) %>%
  mutate(tidy_coeff = map(.x = linear_model,
                          .f = tidy,
                          conf.int = TRUE)) %>%
  mutate(tidy_sum = map(.x = linear_model,
                        .f = glance))
nyc_sum

nyc_sum_tidy <- nyc_sum %>%
  select(borough, tidy_sum) %>%
  unnest(cols = tidy_sum) %>%
  arrange(r.squared)
