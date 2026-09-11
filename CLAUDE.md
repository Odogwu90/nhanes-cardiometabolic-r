# NHANES cardiometabolic risk analysis

Learning project analysing cardiometabolic risk (hypertension, obesity, diabetes)
in NHANES adults aged 20+.

## Files

- `adults_clean.csv` - cleaned analysis dataset with derived variables
  (hypertension, obese, bmi_cat, smoker, prehypertension).
- `report.qmd` - Quarto report (Table 1, prevalence figures, logistic model).
- `run_model.R` - standalone script that fits the report's logistic model and
  writes a tidy odds-ratio table to CSV.
- `run_from_python.py` - Python orchestrator that runs `run_model.R` via
  `subprocess` and prints the result with pandas.

## R conventions

- tidyverse style; use the native pipe `|>`, not `%>%`.
- Tables: gtsummary. Model output: broom (`tidy(..., exponentiate = TRUE, conf.int = TRUE)`).
- Factor levels are set explicitly (e.g. smoker: Never / Former / Current).

## Python conventions

- Python only orchestrates R (via `subprocess` or rpy2). All statistics stay in R.
- Do not re-implement models or tests in Python.

## Working with me

- I am learning. Explain every change you make and why.
- Do not silently rewrite my files; make targeted edits and describe them.
