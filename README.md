# Statistical Modelling of Service Distribution

**Author**: Marco Boso  
**Date**: February 2025  
**Course**: Statistics and data science II

---

## Overview

This project explores how essential public services—schools, pharmacies, and transport sales points—are distributed across urban census sections. Using count-based regression models, we investigate which socio-demographic and economic factors influence facility availability and generate a composite facility score to identify underserved areas.

---

## Objectives

- Perform exploratory data analysis (EDA) on census-level variables  
- Select and engineer features for predictive modelling  
- Apply regression models: Poisson, Negative Binomial, and Zero-Inflated Poisson (ZIP)  
- Develop a facility accessibility score based on normalized targets  
- Identify the variables most correlated with service inequality  
- Highlight geographic areas that lack critical services

---

## Dataset

- **File**: `census_section_stats.csv`  
- **Observations**: Each row represents a census section  
- **Key target variables**:
  - `n_schools` — number of schools  
  - `n_pharmacies` — number of pharmacies  
  - `n_transport_salespoints` — number of transport ticket points

- **Key explanatory variables**:
  - Socioeconomic data: income, expenses  
  - Demographic breakdowns by age and nationality  
  - Geographic info: population density, area, altitude

---

## Libraries Used

- `tidyverse`, `dplyr`, `ggplot2`, `readr`  
- `DataExplorer`, `caret`, `corrplot`, `janitor`  
- `MASS`, `pscl`, `glmnet`, `car`  
- `ggally`, `magick`, `factoextra`

---

## Methodology

### Exploratory Data Analysis (EDA)

- Summary statistics and visual inspection  
- Distributions of target variables  
- Identification of skewed features  
- Correlation matrices to inform feature selection  

### Feature Selection and Engineering

- Removal of multicollinear and redundant variables  
- Creation of engineered features:
  - Log, squared, cubic transformations  
  - Combined/interaction features (e.g., income × population_density)

### Regression Models

Three separate models were built for each target variable:

- Schools → Negative Binomial Regression (handles overdispersion)  
- Pharmacies → Poisson Regression  
- Transport Points → Zero-Inflated Poisson Regression

Each model was evaluated using Mean Absolute Error (MAE) and AIC.

---

## Key Results

- Family income, income per capita, and population density are consistently strong predictors  
- Demographic variables (e.g., nationality breakdown) showed little predictive power  
- Overdispersion was present in school data → Negative Binomial was most appropriate  
- Zero inflation in transport access justified ZIP regression  
- High-income, high-density areas generally had better service coverage

---

## Facility Score

- Created a normalized score from the three target variables  
- Values range from 0 (low facility access) to 1 (high access)  
- Score helps rank and compare urban sections  
- Identified census sections in the bottom 25% (underserved areas)

---

## How to Run

1. Clone the repository:
   ```bash
   git clone git@github.com:MarcoBoso/Statistical-Modeling-of-Service-Distribution.git
   cd Statistical-Modeling-of-Service-Distribution
