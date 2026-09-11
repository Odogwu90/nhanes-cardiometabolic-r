#!/usr/bin/env Rscript
# Fit the diabetes logistic regression from report.qmd and write a tidy
# odds-ratio table with 95% confidence intervals.
#
# Usage:
#   Rscript run_model.R [input_csv] [output_csv]
# Defaults: adults_clean.csv -> odds_ratios.csv

suppressPackageStartupMessages({
  library(tidyverse)
  library(broom)
})

args <- commandArgs(trailingOnly = TRUE)
input_csv  <- if (length(args) >= 1) args[1] else "adults_clean.csv"
output_csv <- if (length(args) >= 2) args[2] else "odds_ratios.csv"

if (!file.exists(input_csv)) {
  stop("Input file not found: ", input_csv, call. = FALSE)
}

# Same recoding as the setup chunk in report.qmd, so the model matches.
adults <- read_csv(input_csv, show_col_types = FALSE) |>
  mutate(
    AgeDecade = str_trim(AgeDecade),
    smoker    = factor(smoker,  levels = c("Never", "Former", "Current")),
    bmi_cat   = factor(bmi_cat, levels = c("Underweight", "Normal", "Overweight", "Obese"))
  )

m <- glm(factor(Diabetes) ~ BMI + PhysActive + smoker + Age + Gender,
         data = adults, family = binomial)

odds_ratios <- tidy(m, exponentiate = TRUE, conf.int = TRUE) |>
  rename(odds_ratio = estimate) |>
  select(term, odds_ratio, conf.low, conf.high, std.error, statistic, p.value)

write_csv(odds_ratios, output_csv)

message("Fitted on ", nobs(m), " complete cases; wrote ", nrow(odds_ratios),
        " rows to ", output_csv)
