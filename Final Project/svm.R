##### SVM for Penguins #####
library(dplyr)
library(e1071)
attach(penguins)
table(penguins$species)

penguins_df <- na.omit(penguins)

penguins2 <- penguins %>%
    select(species, bill_len, bill_dep) %>%
    na.omit()

svm_radial <- svm(species ~ bill_len + bill_dep,
                  data = penguins2,
                  kernel = "radial",
                  gamma = 1,
                  cost = 1,
                  scale = TRUE)


x_range <- seq(min(penguins2$bill_len) - 1,
               max(penguins2$bill_len) + 1,
               length.out = 200)

y_range <- seq(min(penguins2$bill_dep) - 1,
               max(penguins2$bill_dep) + 1,
               length.out = 200)

grid <- expand.grid(bill_len = x_range, bill_dep = y_range)


grid$species_pred <- predict(svm_radial, newdata = grid)
