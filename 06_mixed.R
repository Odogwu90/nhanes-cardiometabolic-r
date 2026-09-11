# 06_mixed.R
# Mixed-effects models on lme4::sleepstudy: reaction time (ms) across days of
# sleep deprivation, 18 subjects x 10 days.
#
# Usage: Rscript 06_mixed.R

suppressPackageStartupMessages({
  library(tidyverse)
  library(lme4)
  library(lmerTest)     # masks lme4::lmer to add Satterthwaite df / p-values
  library(broom.mixed)  # tidy() methods for lmer objects
  library(performance)  # icc()
})

# ---- Data -------------------------------------------------------------------
sleep <- lme4::sleepstudy |>
  as_tibble() |>
  rename(subject = Subject, day = Days, rt = Reaction)

# ---- Figure: per-subject trajectories + overall OLS line ---------------------
p_traj <- ggplot(sleep, aes(day, rt)) +
  geom_line(aes(group = subject), alpha = 0.4) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE,
              colour = "black", linewidth = 1.2) +
  scale_x_continuous(breaks = 0:9) +
  labs(x = "Days of sleep deprivation", y = "Mean reaction time (ms)",
       title = "Sleep study: one line per subject, black = pooled lm fit") +
  theme_minimal()

ggsave("fig_sleep_trajectories.png", p_traj, width = 7, height = 4.5, dpi = 150)

# ---- Models -----------------------------------------------------------------
m_naive <- lm(rt ~ day, data = sleep)                       # ignores clustering
m_ri    <- lmer(rt ~ day + (1 | subject), data = sleep)     # random intercept
m_rs    <- lmer(rt ~ day + (day | subject), data = sleep)   # random intercept + slope

# ---- Output -----------------------------------------------------------------
cat("\n==== summary(m_ri) ====\n")
print(summary(m_ri))

cat("\n==== icc(m_ri) ====\n")
print(icc(m_ri))

cat("\n==== anova(m_ri, m_rs) ====\n")
print(anova(m_ri, m_rs))

cat("\n==== Fixed effect of day across models (95% CI) ====\n")
day_effects <- bind_rows(
  naive            = tidy(m_naive, conf.int = TRUE),
  random_intercept = tidy(m_ri, effects = "fixed", conf.int = TRUE),
  random_slope     = tidy(m_rs, effects = "fixed", conf.int = TRUE),
  .id = "model"
) |>
  filter(term == "day") |>
  select(model, estimate, std.error, conf.low, conf.high, p.value)

print(day_effects)
