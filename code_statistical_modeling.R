

knitr::opts_chunk$set(echo = TRUE)
library(data.table)



df<-fread("census_section_stats.csv", sep=";", dec=",", stringsAsFactors = F)
head(df, n = 10)



library(tidyverse)
library(dplyr)  
library(readr)
library(corrplot)
library(GGally) 
library(mctest)
library(ggplot2)
library(caret)
library(car)
library(magick)
library(glmnet)
library(MASS)
library(DataExplorer)
library(factoextra) 
library(readr)
library(DataExplorer)
library(janitor)



str(df)



plot_intro(df)



discrete_columns <- names(df)[sapply(df, function(col) {
  is.integer(col) || (is.numeric(col) && all(col == floor(col), na.rm = TRUE))
})]

print(discrete_columns)



# n_pharmacies
hist(df$n_pharmacies)
mean(df$n_pharmacies)
var(df$n_pharmacies)
success <- min(df$n_pharmacies):max(df$n_pharmacies)
plot(density(df$n_pharmacies),ylim=c(0,0.5), xlim = c(0,15))+
lines(success,dpois(success, lambda=mean(df$n_pharmacies)),col="red")



# n_schools
hist(df$n_schools)
mean(df$n_schools)
var(df$n_schools)
success <- min(df$n_schools):max(df$n_schools)
plot(density(df$n_schools),ylim=c(0,0.5), xlim = c(0,15))+
lines(success,dpois(success, lambda=mean(df$n_schools)),col="orange")



# n_transport_salespoints
hist(df$n_transport_salespoints)
mean(df$n_transport_salespoints)
var(df$n_transport_salespoints)
success <- min(df$n_transport_salespoints):max(df$n_transport_salespoints)
plot(density(df$n_transport_salespoints),ylim=c(0,0.5), xlim = c(0,15))+
lines(success,dpois(success, lambda=mean(df$n_transport_salespoints)),col="blue")



summary(df)



df_numeric <- df |> dplyr::select(where(is.numeric))
for (col in names(df_numeric)) {
  print(
    ggplot(df, aes_string(x = col)) +
      geom_histogram(bins = 30, fill = "pink", color = "black", na.rm = TRUE) +
      labs(title = paste("Histogram of", col), x = col, y = "Frequency") +
      theme_minimal()
  )
}



plot_boxplot(df, by = "n_pharmacies")



plot_boxplot(df, by = "n_schools")



plot_boxplot(df, by = "n_transport_salespoints")



plot_correlation(df)



correlations_schools <- cor(df_numeric$n_schools, df_numeric, use = "complete.obs")
print(correlations_schools)



correlations_pharmacies <- cor(df_numeric$n_pharmacies, df_numeric, use = "complete.obs")
print(correlations_pharmacies)



correlations_transport <- cor(df_numeric$n_transport_salespoints, df_numeric, use = "complete.obs")
print(correlations_transport)



model_n_schools <- lm(n_schools ~  census_district_code + city_code + province_code + area + population + family_income + income_per_capita + avg_age + spanish + foreigners + europeans + germans + bulgarian + french + italian + polish + portuguese + british + romanian + non_european + russian + african + algerian + moroccan + nigerian + senegalese + american + argentinian + bolivian + brazilian + colombian + cuban + chilean + ecuadorian + paraguayan + peruvian + uruguayan + venezuelan + asian + pakistani + oceanic + dominican + pcg_age_0_24 + pcg_age_25_39 + pcg_age_40_49 + pcg_age_50_59 + pcg_age_60_69 + pcg_age_70_y_mas + pcg_expense_home + ratio_expense_home + pcg_num_transaction_city + pcg_num_transaction_norm_city + altitude + city_population + population_density + n_pharmacies + n_transport_salespoints + pcg_foreigners, data = df_numeric)
alias(model_n_schools)$Complete


... (continued in next message due to length)


model_n_pharmacies <- lm(n_pharmacies ~  census_district_code + city_code + province_code + area + population + family_income + income_per_capita + avg_age + spanish + foreigners + europeans + germans + bulgarian + french + italian + polish + portuguese + british + romanian + non_european + russian + african + algerian + moroccan + nigerian + senegalese + american + argentinian + bolivian + brazilian + colombian + cuban + chilean + ecuadorian + paraguayan + peruvian + uruguayan + venezuelan + asian + p...
alias(model_n_pharmacies)$Complete



model_n_transport <- lm(n_transport_salespoints ~  census_district_code + city_code + province_code + area + population + family_income + income_per_capita + avg_age + spanish + foreigners + europeans + germans + bulgarian + french + italian + polish + portuguese + british + romanian + non_european + russian + african + algerian + moroccan + nigerian + senegalese + american + argentinian + bolivian + brazilian + colombian + cuban + chilean + ecuadorian + paraguayan + peruvian + uruguayan + venezuelan +...
alias(model_n_transport)$Complete



df_numeric$combined_foreigners <- df_numeric$foreigners * df_numeric$pcg_foreigners



# Updated models using combined_foreigners
model_n_schools <- lm(n_schools ~  census_district_code + city_code + area + population + family_income + income_per_capita + avg_age + spanish + europeans + germans + bulgarian + french + italian + polish + portuguese + british + romanian + non_european + russian + african + algerian + moroccan + nigerian + senegalese + american + argentinian + bolivian + brazilian + colombian + cuban + chilean + ecuadorian + paraguayan + peruvian + uruguayan + venezuelan + asian + pakistani + oceanic + dominican + ...
alias(model_n_schools)$Complete



vif_n_schools <- vif(model_n_schools)
print(vif_n_schools)



poisson_model <- glm(n_schools ~ ..., family = poisson, data = df_numeric)
summary(poisson_model)



dispersion <- sum(residuals(poisson_model, type = "pearson")^2) / poisson_model$df.residual
print(dispersion) 



neg_bin_model <- glm.nb(n_schools ~ ..., data = df_numeric)
summary(neg_bin_model)



AIC(poisson_model, neg_bin_model)



# Normalization and score creation
normalize <- function(x) {
  (x - min(x, na.rm = TRUE)) / (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))
}
df_selected$norm_schools <- normalize(df_selected$n_schools)
df_selected$norm_pharmacies <- normalize(df_selected$n_pharmacies)
df_selected$norm_transport_salespoints <- normalize(df_selected$n_transport_salespoints)
df_selected$facility_score <- rowMeans(df_selected[, c("norm_schools", "norm_pharmacies", "norm_transport_salespoints")], na.rm = TRUE)



# Correlations
correlations <- cor(df_selected$facility_score, df_selected, use = "complete.obs")
sorted_correlations <- sort(correlations, decreasing = TRUE)
print(sorted_correlations)



# Final regression model for score
score_model <- lm(facility_score ~ ..., data = df_selected)
summary(score_model)



# Identify underserved areas
low_facility_areas <- df_selected[df_selected$facility_score < quantile(df_selected$facility_score, 0.25), c("index", "facility_score")]
print(low_facility_areas)

