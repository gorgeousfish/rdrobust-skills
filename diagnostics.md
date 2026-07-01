# Diagnostics Guide: rdrobust

## Overview

This document provides comprehensive pre-estimation and post-estimation diagnostic procedures for RD designs using rdrobust. All diagnostics are presented in R, Python, and Stata simultaneously.

---

## Pre-Estimation Diagnostics

### 1. Density Test (McCrary / rddensity)

**Purpose**: Test for manipulation of the running variable at the cutoff.

**Null hypothesis**: The density of the running variable is continuous at the cutoff.

#### R
```r
library(rddensity)
dens_test <- rddensity(X = data$runvar, c = 0)
summary(dens_test)

# Interpretation:
# p-value > 0.05 → No evidence of manipulation (proceed)
# p-value < 0.05 → Evidence of sorting; RD validity threatened

# Visualization
rdplotdensity(dens_test, X = data$runvar)
```

#### Python
```python
from rddensity import rddensity, rdplotdensity

dens_test = rddensity(X = data['runvar'].values, c = 0)
print(dens_test)

# Visualization
rdplotdensity(dens_test, X = data['runvar'].values)
```

#### Stata
```stata
rddensity runvar, c(0) plot
* Stored results: e(pv_q) for robust p-value
```

---

### 2. Covariate Balance at the Cutoff

**Purpose**: Verify that predetermined characteristics don't jump at the cutoff.

**Logic**: If continuity holds, pre-treatment covariates should show no discontinuity.

#### R
```r
library(rdrobust)
covariates <- c("age", "income", "education", "gender")
balance_results <- data.frame(
  Covariate = character(),
  RD_Effect = numeric(),
  Robust_pval = numeric(),
  stringsAsFactors = FALSE
)

for (cov in covariates) {
  est <- rdrobust(y = data[[cov]], x = data$runvar, c = 0)
  balance_results <- rbind(balance_results, data.frame(
    Covariate = cov,
    RD_Effect = est$coef[1],
    Robust_pval = est$pv[3]
  ))
}
print(balance_results)
# All p-values should be > 0.05
```

#### Python
```python
from rdrobust import rdrobust
import pandas as pd

covariates = ['age', 'income', 'education', 'gender']
balance = []

for cov in covariates:
    est = rdrobust(y = data[cov].values, x = data['runvar'].values, c = 0)
    balance.append({
        'Covariate': cov,
        'RD_Effect': est.coef.iloc[0],
        'Robust_pval': est.pv.iloc[2]
    })

balance_df = pd.DataFrame(balance)
print(balance_df)
```

#### Stata
```stata
local covariates "age income education gender"
foreach var of local covariates {
    quietly rdrobust `var' runvar, c(0)
    display "`var': effect = " e(tau_cl) " , p-value = " e(pv_rb)
}
```

---

### 3. Mass Points Diagnostic

**Purpose**: Check whether the running variable has repeated values that could affect estimation.

#### R
```r
# Check number of unique values
n_unique_left <- length(unique(data$runvar[data$runvar < 0]))
n_unique_right <- length(unique(data$runvar[data$runvar >= 0]))
cat("Unique values: left =", n_unique_left, ", right =", n_unique_right, "\n")

# Run with masspoints = "check"
est <- rdrobust(y = data$outcome, x = data$runvar, masspoints = "check")
```

#### Python
```python
import numpy as np

n_unique_left = len(np.unique(data['runvar'][data['runvar'] < 0]))
n_unique_right = len(np.unique(data['runvar'][data['runvar'] >= 0]))
print(f"Unique values: left = {n_unique_left}, right = {n_unique_right}")

est = rdrobust(y = data['outcome'].values, x = data['runvar'].values,
               masspoints = "check")
```

#### Stata
```stata
rdrobust outcome runvar, masspoints(check)
* Reports number of unique observations each side
```

---

## Post-Estimation Diagnostics

### 4. Bandwidth Sensitivity

**Purpose**: Show that results are not driven by a particular bandwidth choice.

#### R
```r
# Base estimation
est_base <- rdrobust(y = data$outcome, x = data$runvar)
h_opt <- est_base$bws[1,1]  # Left bandwidth

# Sensitivity grid
multipliers <- c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)
sensitivity <- data.frame(
  Multiplier = multipliers,
  h = h_opt * multipliers,
  Estimate = NA,
  Robust_CI_lower = NA,
  Robust_CI_upper = NA,
  Robust_pval = NA
)

for (i in seq_along(multipliers)) {
  h_test <- h_opt * multipliers[i]
  est_i <- rdrobust(y = data$outcome, x = data$runvar, h = h_test)
  sensitivity$Estimate[i] <- est_i$coef[1]
  sensitivity$Robust_CI_lower[i] <- est_i$ci[3, 1]
  sensitivity$Robust_CI_upper[i] <- est_i$ci[3, 2]
  sensitivity$Robust_pval[i] <- est_i$pv[3]
}
print(sensitivity)
```

#### Python
```python
est_base = rdrobust(y = data['outcome'].values, x = data['runvar'].values)
h_opt = est_base.bws.iloc[0, 0]

multipliers = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
sensitivity = []

for mult in multipliers:
    h_test = h_opt * mult
    est_i = rdrobust(y = data['outcome'].values, x = data['runvar'].values,
                     h = h_test)
    sensitivity.append({
        'Multiplier': mult,
        'h': h_test,
        'Estimate': est_i.coef.iloc[0],
        'Robust_CI_lower': est_i.ci.iloc[2, 0],
        'Robust_CI_upper': est_i.ci.iloc[2, 1],
        'Robust_pval': est_i.pv.iloc[2]
    })

print(pd.DataFrame(sensitivity))
```

#### Stata
```stata
quietly rdrobust outcome runvar
local h_opt = e(h_l)

foreach mult in 0.5 0.75 1.0 1.25 1.5 2.0 {
    local h_test = `h_opt' * `mult'
    quietly rdrobust outcome runvar, h(`h_test')
    display "h = " %6.2f `h_test' ": tau = " %7.4f e(tau_cl) ///
            " , p_rb = " %6.4f e(pv_rb)
}
```

---

### 5. Polynomial Order Sensitivity

**Purpose**: Results should be qualitatively similar across polynomial orders.

#### R
```r
for (poly_order in 1:3) {
  est_p <- rdrobust(y = data$outcome, x = data$runvar, p = poly_order)
  cat(sprintf("p = %d: tau = %.4f, robust p-val = %.4f\n",
              poly_order, est_p$coef[1], est_p$pv[3]))
}
```

#### Python
```python
for poly_order in [1, 2, 3]:
    est_p = rdrobust(y = data['outcome'].values, x = data['runvar'].values,
                     p = poly_order)
    print(f"p = {poly_order}: tau = {est_p.coef.iloc[0]:.4f}, "
          f"robust p-val = {est_p.pv.iloc[2]:.4f}")
```

#### Stata
```stata
forvalues p = 1/3 {
    quietly rdrobust outcome runvar, p(`p')
    display "p = `p': tau = " %7.4f e(tau_cl) " , p_rb = " %6.4f e(pv_rb)
}
```

---

### 6. Placebo Cutoff Tests

**Purpose**: If the effect is truly at the cutoff, there should be no effect at other points.

#### R
```r
placebo_cutoffs <- c(-0.5, -0.25, 0.25, 0.5)
placebo_results <- data.frame(
  Cutoff = placebo_cutoffs,
  Estimate = NA,
  Robust_pval = NA
)

for (i in seq_along(placebo_cutoffs)) {
  # Use only observations on the appropriate side of the true cutoff
  if (placebo_cutoffs[i] < 0) {
    sub <- data$runvar < 0
  } else {
    sub <- data$runvar >= 0
  }
  est_plac <- rdrobust(y = data$outcome[sub], x = data$runvar[sub],
                       c = placebo_cutoffs[i])
  placebo_results$Estimate[i] <- est_plac$coef[1]
  placebo_results$Robust_pval[i] <- est_plac$pv[3]
}
print(placebo_results)
# Expect: all p-values > 0.05 (no significant placebo effects)
```

#### Python
```python
placebo_cutoffs = [-0.5, -0.25, 0.25, 0.5]
placebo_results = []

for pc in placebo_cutoffs:
    if pc < 0:
        mask = data['runvar'].values < 0
    else:
        mask = data['runvar'].values >= 0

    est_plac = rdrobust(y = data['outcome'].values[mask],
                        x = data['runvar'].values[mask], c = pc)
    placebo_results.append({
        'Cutoff': pc,
        'Estimate': est_plac.coef.iloc[0],
        'Robust_pval': est_plac.pv.iloc[2]
    })

print(pd.DataFrame(placebo_results))
```

#### Stata
```stata
* Left-side placebo
rdrobust outcome runvar if runvar < 0, c(-0.25)
display "Placebo c=-0.25: p_rb = " e(pv_rb)

* Right-side placebo
rdrobust outcome runvar if runvar >= 0, c(0.25)
display "Placebo c=0.25: p_rb = " e(pv_rb)
```

---

### 7. Donut Hole Test

**Purpose**: Exclude observations very close to the cutoff to check if results are driven by outliers near threshold.

#### R
```r
# Exclude observations within epsilon of cutoff
epsilon_values <- c(0.01, 0.05, 0.1)
for (eps in epsilon_values) {
  donut_sub <- abs(data$runvar) > eps
  est_donut <- rdrobust(y = data$outcome[donut_sub],
                        x = data$runvar[donut_sub], c = 0)
  cat(sprintf("Donut (|x| > %.2f): tau = %.4f, p_rb = %.4f, N_h = %d/%d\n",
              eps, est_donut$coef[1], est_donut$pv[3],
              est_donut$N_h[1], est_donut$N_h[2]))
}
```

#### Python
```python
epsilon_values = [0.01, 0.05, 0.1]
for eps in epsilon_values:
    mask = np.abs(data['runvar'].values) > eps
    est_donut = rdrobust(y = data['outcome'].values[mask],
                         x = data['runvar'].values[mask], c = 0)
    print(f"Donut (|x| > {eps:.2f}): tau = {est_donut.coef.iloc[0]:.4f}, "
          f"p_rb = {est_donut.pv.iloc[2]:.4f}")
```

#### Stata
```stata
foreach eps in 0.01 0.05 0.1 {
    rdrobust outcome runvar if abs(runvar) > `eps', c(0)
    display "Donut (eps=`eps'): tau = " e(tau_cl) " , p_rb = " e(pv_rb)
}
```

---

### 8. Visual Diagnostic: RD Plot

**Purpose**: Visual confirmation that the discontinuity is apparent and not an artifact of functional form.

#### R
```r
# Standard RD plot
rdplot(y = data$outcome, x = data$runvar, c = 0,
       binselect = "esmv",
       title = "RD Plot: Main Outcome",
       x.label = "Running Variable",
       y.label = "Outcome")

# With confidence intervals
rdplot(y = data$outcome, x = data$runvar, c = 0,
       binselect = "es", ci = 95,
       title = "RD Plot with 95% CI")
```

#### Python
```python
from rdrobust import rdplot

rdplot(y = data['outcome'].values, x = data['runvar'].values, c = 0,
       binselect = "esmv",
       title = "RD Plot: Main Outcome",
       x_label = "Running Variable",
       y_label = "Outcome")
```

#### Stata
```stata
rdplot outcome runvar, c(0) binselect(esmv) ///
    graph_options(title("RD Plot: Main Outcome") ///
                  xtitle("Running Variable") ///
                  ytitle("Outcome"))
```

---

### 9. First-Stage Diagnostic (Fuzzy RD Only)

**Purpose**: Verify that crossing the cutoff significantly changes the probability of treatment (first-stage relevance). A weak first stage invalidates the Fuzzy RD estimator.

**Logic**: The Fuzzy RD estimand is a ratio; if the denominator (treatment probability jump) is near zero, the estimate is unreliable.

#### R
```r
# Estimate the first-stage discontinuity
# T = treatment take-up indicator
first_stage <- rdrobust(y = data$treatment, x = data$runvar, c = 0)
summary(first_stage)

cat("First-stage estimate:", first_stage$coef[1], "\n")
cat("Robust p-value:", first_stage$pv[3], "\n")
cat("Robust 95% CI: [", first_stage$ci[3, 1], ",",
    first_stage$ci[3, 2], "]\n")

# Visual: treatment probability jump
rdplot(y = data$treatment, x = data$runvar, c = 0,
       title = "First Stage: Treatment Probability",
       x.label = "Running Variable",
       y.label = "P(Treatment)")

# Rule of thumb: first-stage F-stat analog
# If |coef / se| < 3.2 (approx sqrt(10)), consider weak instrument
f_analog <- (first_stage$coef[1] / first_stage$se[3])^2
cat("First-stage F-analog:", f_analog, "\n")
if (f_analog < 10) {
  warning("Weak first stage: F-analog < 10. Fuzzy RD may be unreliable.")
}
```

#### Python
```python
# Estimate the first-stage discontinuity
first_stage = rdrobust(y = data['treatment'].values,
                       x = data['runvar'].values, c = 0)
print(first_stage)

print(f"First-stage estimate: {first_stage.coef.iloc[0]:.4f}")
print(f"Robust p-value: {first_stage.pv.iloc[2]:.4f}")
print(f"Robust 95% CI: [{first_stage.ci.iloc[2, 0]:.4f}, "
      f"{first_stage.ci.iloc[2, 1]:.4f}]")

# Visual: treatment probability jump
rdplot(y = data['treatment'].values, x = data['runvar'].values, c = 0,
       title = "First Stage: Treatment Probability",
       x_label = "Running Variable",
       y_label = "P(Treatment)")

# F-analog check
f_analog = (first_stage.coef.iloc[0] / first_stage.se.iloc[2]) ** 2
print(f"First-stage F-analog: {f_analog:.2f}")
if f_analog < 10:
    print("WARNING: Weak first stage (F < 10). Fuzzy RD may be unreliable.")
```

#### Stata
```stata
* First-stage estimation
rdrobust treatment runvar, c(0)
display "First-stage estimate: " e(tau_cl)
display "Robust p-value: " e(pv_rb)

* Visual
rdplot treatment runvar, c(0) ///
    graph_options(title("First Stage: Treatment Probability") ///
                  xtitle("Running Variable") ytitle("P(Treatment)"))

* F-analog
local f_analog = (e(tau_cl) / e(se_tau_rb))^2
display "First-stage F-analog: " `f_analog'
if `f_analog' < 10 {
    display "WARNING: Weak first stage. Fuzzy RD may be unreliable."
}
```

---

### 10. SUTVA / No Interference Check

**Purpose**: Investigate whether spillover effects exist near the cutoff. If treated units affect nearby control units' outcomes, SUTVA is violated.

**Logic**: Under SUTVA, effects should be confined to the treated unit. Interference is often untestable, but indirect evidence can be gathered.

#### R
```r
# Strategy 1: Check for "displacement" effects
# If treated units crowd out control units, we expect negative effects
# on control outcomes near the cutoff.
# Subset to control side only, test for outcome gradient
est_control_gradient <- rdrobust(y = data$outcome[data$runvar < 0],
                                  x = data$runvar[data$runvar < 0],
                                  c = -0.1)  # artificial cutoff near 0

# Strategy 2: Distance-based heterogeneity (if geographic/network data)
# Compare effect for units far vs. close to other treated units
# (requires additional data structure)

# Strategy 3: Donut-hole sensitivity as SUTVA proxy
# If interference exists, excluding units closest to cutoff
# (who interact most with the other side) should change results
epsilon_values <- c(0.01, 0.05, 0.1, 0.2)
cat("SUTVA Sensitivity (Donut Hole):\n")
for (eps in epsilon_values) {
  donut_sub <- abs(data$runvar) > eps
  est_donut <- rdrobust(y = data$outcome[donut_sub],
                        x = data$runvar[donut_sub], c = 0)
  cat(sprintf("  Exclude |x| <= %.2f: tau = %.4f (N_h = %d/%d)\n",
              eps, est_donut$coef[1], est_donut$N_h[1], est_donut$N_h[2]))
}
```

#### Python
```python
import numpy as np

# Strategy 1: Test for displacement on control side
mask_control = data['runvar'].values < 0
est_control = rdrobust(y = data['outcome'].values[mask_control],
                       x = data['runvar'].values[mask_control],
                       c = -0.1)

# Strategy 3: Donut-hole sensitivity
epsilon_values = [0.01, 0.05, 0.1, 0.2]
print("SUTVA Sensitivity (Donut Hole):")
for eps in epsilon_values:
    mask = np.abs(data['runvar'].values) > eps
    est_donut = rdrobust(y = data['outcome'].values[mask],
                         x = data['runvar'].values[mask], c = 0)
    print(f"  Exclude |x| <= {eps:.2f}: tau = {est_donut.coef.iloc[0]:.4f} "
          f"(N_h = {est_donut.N_h[0]}/{est_donut.N_h[1]})")
```

#### Stata
```stata
* Strategy 1: Control-side gradient test
rdrobust outcome runvar if runvar < 0, c(-0.1)

* Strategy 3: Donut-hole sensitivity (using bias-corrected estimates for consistency)
foreach eps in 0.01 0.05 0.1 0.2 {
    quietly rdrobust outcome runvar if abs(runvar) > `eps', c(0)
    display "  Exclude |x| <= `eps': tau_bc = " %7.4f e(tau_bc) ///
            " se_rb = " %7.4f e(se_tau_rb) ///
            " (N_h = " e(N_h_l) "/" e(N_h_r) ")"
}
```

**Interpretation**: If the estimate changes dramatically when excluding near-cutoff observations, this may indicate interference effects. Stable estimates across donut sizes suggest SUTVA is plausible.

---

## Diagnostic Decision Matrix

| Diagnostic | Assumption Tested | Fail Signal | Action if Fails |
|-----------|-------------------|------------|------------------|
| Density test | #2: No Manipulation | p < 0.05 | Investigate manipulation; consider donut-hole design; report limitation |
| Covariate balance | #1: Continuity | Any covariate p < 0.05 | Check if due to multiple testing; consider covariate adjustment; report |
| Bandwidth sensitivity | #3: Smoothness | Sign/significance changes dramatically | Investigate functional form; consider narrower bandwidth; report sensitivity |
| Polynomial sensitivity | #3: Smoothness | p=1 and p=2 give contradictory results | Narrow bandwidth to reduce polynomial sensitivity; use rdplot to visualize |
| Placebo cutoffs | #1: Continuity | Significant effects at non-cutoff points | May indicate confounding trend; consider difference-in-discontinuity |
| Donut hole | #4: SUTVA | Results vanish when excluding near-cutoff obs | Effect may be driven by outliers or interference; investigate data quality |
| Mass points | Technical | Very few unique values | Use `masspoints = "adjust"`; consider local randomization approach |
| RD plot | #3: Smoothness | No visible discontinuity or extreme nonlinearity | Re-examine design; consider higher polynomial; check data errors |
| First stage (Fuzzy) | #5: Relevance | p > 0.05 or F-analog < 10 | Weak instrument problem; consider sharp RD subset; report limitation |
| SUTVA check | #4: No Interference | Estimate changes with donut size | Possible spillovers; consider spatial models; report as limitation |

---

## Recommended Diagnostic Reporting Template

```
Table A: RD Validity Diagnostics
─────────────────────────────────────────────────────────────
1. Density Test (rddensity)
   - Test statistic: ___
   - p-value: ___ (H0: no manipulation)

2. Covariate Balance at Cutoff
   [Table: Covariate | RD Estimate | Robust p-value]

3. Bandwidth Sensitivity
   [Table: h multiplier | Estimate | 95% Robust CI | p-value]

4. Polynomial Sensitivity
   [Table: p order | Estimate | Robust p-value]

5. Placebo Cutoffs
   [Table: Placebo c | Estimate | Robust p-value]

6. First Stage (Fuzzy RD only)
   - First-stage estimate: ___
   - Robust p-value: ___
   - F-analog: ___

7. SUTVA / Interference Check
   [Table: Donut radius | Estimate | N effective]
─────────────────────────────────────────────────────────────
```

---

## Assumption-to-Diagnostic Mapping

| # | Assumption | Primary Diagnostic | Secondary Diagnostic |
|---|-----------|-------------------|---------------------|
| 1 | Continuity of CEF at cutoff | Covariate balance test (§2) | Placebo cutoffs (§6) |
| 2 | No manipulation of running variable | Density test / rddensity (§1) | Visual density plot |
| 3 | Local smoothness / regularity | Polynomial sensitivity (§5) | Bandwidth sensitivity (§4), RD plot (§8) |
| 4 | SUTVA / No interference | Donut hole test (§7) | SUTVA check (§10) |
| 5 | First-stage relevance (Fuzzy only) | First-stage diagnostic (§9) | rdplot of treatment probability |
