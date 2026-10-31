# Forecasting the 10Y–2Y Treasury Yield Spread

## Project Overview

The 10-year minus 2-year U.S. Treasury yield spread is a widely monitored indicator of economic conditions. When short-term Treasury yields exceed long-term yields, the yield curve becomes inverted, a phenomenon historically associated with economic recessions.

This project examines historical movements in the 10Y–2Y Treasury yield spread and uses time series forecasting to estimate its behavior over a 52-week horizon.

Using R, we applied time series analysis, ARIMA modeling, diagnostic testing, and Monte Carlo simulation to investigate the likelihood of a future yield curve inversion.

## Data

The analysis uses historical 10-year minus 2-year Treasury yield spread observations, a series available through the Federal Reserve Bank of St. Louis (FRED).

- **Variable:** 10-Year Treasury Constant Maturity Minus 2-Year Treasury Constant Maturity (T10Y2Y)
- **Frequency:** Daily observations aggregated to weekly data
- **Original dataset:** 13,001 observations
- **Preprocessing:** Removed missing observations and converted the cleaned series to weekly frequency

The weekly series was used to examine historical patterns, assess stationarity, and develop forecasting models.

## Methodology

### 1. Data Preparation and Exploratory Analysis

We cleaned the dataset, aggregated daily observations into a weekly time series, and examined historical movements in the yield spread.

Autocorrelation (ACF) and partial autocorrelation (PACF) plots were used to identify temporal dependence and assess stationarity. First differencing was applied to address non-stationarity.

### 2. ARIMA Modeling

We evaluated several ARIMA specifications, including ARIMA(4,1,5) and ARIMA(0,1,1).

Although the more complex model demonstrated reasonable forecasting performance, residual diagnostic testing identified remaining autocorrelation.

We ultimately selected ARIMA(0,1,1) as a more parsimonious forecasting model.

### 3. Residual Diagnostics

We examined residual behavior using diagnostic plots and the Ljung–Box test.

Residual autocorrelation and changes in variance remained concerns. We investigated alternative specifications, variance-stabilizing transformations, and a shorter historical sample.

### 4. Forecasting and Monte Carlo Simulation

Using the ARIMA(0,1,1) model, we generated a 52-week forecast with 95% prediction intervals.

We then simulated 10,000 possible future paths to estimate the probability of the yield spread falling below zero at least once during the forecast period.

## Key Findings

- **40.65% probability of inversion:** Monte Carlo simulation estimated a 40.65% probability of at least one yield curve inversion over the next 52 weeks.
- **Approximately 23% probability at week 52:** The estimated probability of inversion at the final forecast week was approximately 23%.
- **Increasing forecast uncertainty:** Prediction intervals widened over the forecast horizon, reflecting greater uncertainty in longer-term forecasts.
- **Model limitations:** Residual autocorrelation and time-varying variance remained, suggesting opportunities for more advanced modeling approaches.

These estimates are conditional on the fitted model and its assumptions. They should not be interpreted as the probability of an economic recession.

## How to Run the Project

1. Clone the GitHub repository to your computer.
2. Open the project directory in RStudio.
3. Restore the required R package environment using:

   ```r
   renv::restore()
   ```

4. Run the time series analysis script.

   ```r
   # Replace with the actual script filename
   source("analysis/your_script.R")
   ```

5. If applicable, launch the Shiny application using the instructions provided with its source files.

## Limitations and Future Research

Although ARIMA(0,1,1) provided a relatively simple approach to forecasting, residual diagnostics indicated that the model did not fully capture the dependence and changing volatility in the yield spread.

Future research could examine models such as GARCH to address volatility clustering or vector autoregressive (VAR) models to incorporate additional economic variables.

## Project Materials

This repository contains the R analysis scripts, Shiny application source code, final written report, and project presentation.

## Authors

- La Mia Pruitt
- Braxton Johnson
- Gabriella Mariano
- Graciela Guajardo