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

cars2 <- cars %>% 
  select(
    symboling, wheel_base, length, width, height, curb_weight,
    engine_size, bore, stroke, compression_ratio, horsepower, 
    peak_rpm, city_mpg, highway_mpg, price
  ) %>% 
  filter(
    stroke != "?",
    bore != "?",
    horsepower != "?",
    peak_rpm != "?",
    price != "?"
  ) %>% 
  mutate(
    stroke = as.numeric(stroke),
    bore = as.numeric(bore),
    horsepower = as.numeric(horsepower),
    peak_rpm = as.numeric(peak_rpm),
    price = as.numeric(price)
  )

featurePlot(cars2, cars2$price)
#positive engine size, horsepower
#negative city and highway mpg

ggplot(cars2, aes(price)) + geom_histogram()

# train-test split
train_indices <- createDataPartition(y = cars2[['price']],
                                     p = 0.7,
                                     list = FALSE)
train_data <- cars2[train_indices,]
test_data <- cars2[-train_indices,]

# cross-validation and hyperparameter optimization

train_control <- trainControl(method = 'cv', 
                              number = 5)

knn_grid <- expand.grid(k = 1:20)

# chosing a model

knn_model <- train(price ~ .,
                   data = train_data,
                   method = 'knn',
                   trControl = train_control,
                   preProcess = c('center', 'scale'),
                   tuneGrid = knn_grid)

#final model evaluation
predictions <- predict(knn_model, newdata = test_data)
postResample(pred = predictions, obs = test_data$price)

