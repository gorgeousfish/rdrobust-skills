# Example: Fuzzy RD — Program Eligibility with Imperfect Compliance

## Research Question

What is the causal effect of a social program (e.g., Head Start, scholarship, job training) on outcomes when eligibility is determined by a threshold rule but compliance is imperfect? Individuals just below the threshold may still participate (always-takers) and individuals just above may not (never-takers).

## Data

**Simulated dataset** mimicking a common Fuzzy RD scenario:

| Variable | Description |
|----------|-------------|
| `outcome` | Post-program earnings (continuous) |
| `score` | Eligibility score (running variable; higher = more disadvantaged) |
| `eligible` | = 1 if score ≥ cutoff (eligibility assignment) |
| `treated` | = 1 if actually enrolled in program (imperfect compliance) |
| `age` | Age at enrollment (covariate) |
| `education` | Years of education (covariate) |
| `district` | District ID (for clustering) |

**Cutoff**: `c = 50` (score ≥ 50 → eligible for program)

**Design**: Fuzzy RD — eligibility is deterministic at cutoff, but actual participation is not (some eligible decline, some ineligible find ways to enroll).

---

## Implementation

### R

```r
library(rdrobust)
set.seed(2024)

# Simulate Fuzzy RD data
n <- 2000
score <- runif(n, 20, 80)
eligible <- as.numeric(score >= 50)
# Imperfect compliance: 80% of eligible take up, 10% of ineligible manage to enroll
treated <- rbinom(n, 1, prob = eligible * 0.8 + (1 - eligible) * 0.1)
outcome <- 10 + 0.5 * score + 5 * treated + rnorm(n, 0, 3)
age <- 30 + 0.2 * score + rnorm(n, 0, 5)
district <- sample(1:20, n, replace = TRUE)

df <- data.frame(outcome, score, eligible, treated, age, district)

# Step 1: Verify first stage (jump in treatment at cutoff)
est_fs <- rdrobust(y = df$treated, x = df$score, c = 50)
cat(sprintf("First stage: jump = %.3f (p = %.4f)\n",
            est_fs$coef[3], est_fs$pv[3]))
# Must be significant — otherwise Fuzzy RD is invalid

# Step 2: Reduced form (jump in outcome at cutoff)
est_rf <- rdrobust(y = df$outcome, x = df$score, c = 50)
cat(sprintf("Reduced form: jump = %.3f (p = %.4f)\n",
            est_rf$coef[3], est_rf$pv[3]))

# Step 3: Fuzzy RD estimation (ratio = LATE)
est_fuzzy <- rdrobust(y = df$outcome, x = df$score, c = 50,
                      fuzzy = df$treated)
summary(est_fuzzy, all = TRUE)

# Key result extraction
cat("\n=== Fuzzy RD: Program Effect (LATE) ===\n")
cat(sprintf("LATE Estimate: %.3f\n", est_fuzzy$coef[3]))
cat(sprintf("Robust SE: %.3f\n", est_fuzzy$se[3]))
cat(sprintf("Robust 95%% CI: [%.3f, %.3f]\n",
            est_fuzzy$ci[3,1], est_fuzzy$ci[3,2]))
cat(sprintf("Robust p-value: %.4f\n", est_fuzzy$pv[3]))
cat(sprintf("Bandwidth: h = %.2f\n", est_fuzzy$bws[1,1]))

# Step 4: With covariates (efficiency gain)
est_fuzzy_covs <- rdrobust(y = df$outcome, x = df$score, c = 50,
                           fuzzy = df$treated,
                           covs = ~ age,
                           data = df)
summary(est_fuzzy_covs)

# Step 5: Cluster-robust (by district)
est_fuzzy_clust <- rdrobust(y = df$outcome, x = df$score, c = 50,
                            fuzzy = df$treated,
                            cluster = df$district, vce = "cr1")
summary(est_fuzzy_clust)

# Step 6: RD Plot of first stage
rdplot(y = df$treated, x = df$score, c = 50,
       title = "First Stage: Treatment Take-up",
       x.label = "Eligibility Score",
       y.label = "P(Treatment)")
```

### Python

```python
import numpy as np
import pandas as pd
from rdrobust import rdrobust, rdplot

np.random.seed(2024)

# Simulate Fuzzy RD data
n = 2000
score = np.random.uniform(20, 80, n)
eligible = (score >= 50).astype(float)
treated = np.random.binomial(1, eligible * 0.8 + (1 - eligible) * 0.1)
outcome = 10 + 0.5 * score + 5 * treated + np.random.normal(0, 3, n)
age = 30 + 0.2 * score + np.random.normal(0, 5, n)
district = np.random.randint(1, 21, n)

# Step 1: First stage
est_fs = rdrobust(y = treated, x = score, c = 50)
print(f"First stage: jump = {est_fs.coef.iloc[2]:.3f} "
      f"(p = {est_fs.pv.iloc[2]:.4f})")

# Step 2: Reduced form
est_rf = rdrobust(y = outcome, x = score, c = 50)
print(f"Reduced form: jump = {est_rf.coef.iloc[2]:.3f} "
      f"(p = {est_rf.pv.iloc[2]:.4f})")

# Step 3: Fuzzy RD (LATE)
est_fuzzy = rdrobust(y = outcome, x = score, c = 50, fuzzy = treated)
print(est_fuzzy)

# Key results
tau = est_fuzzy.coef.iloc[2]
se = est_fuzzy.se.iloc[2]
ci_l = est_fuzzy.ci.iloc[2, 0]
ci_r = est_fuzzy.ci.iloc[2, 1]
pval = est_fuzzy.pv.iloc[2]

print(f"\n=== Fuzzy RD: Program Effect (LATE) ===")
print(f"LATE Estimate: {tau:.3f}")
print(f"Robust SE: {se:.3f}")
print(f"Robust 95% CI: [{ci_l:.3f}, {ci_r:.3f}]")
print(f"Robust p-value: {pval:.4f}")
print(f"Bandwidth: h = {est_fuzzy.bws.iloc[0,0]:.2f}")

# Step 4: With covariates
est_fuzzy_covs = rdrobust(y = outcome, x = score, c = 50,
                          fuzzy = treated, covs = age.reshape(-1, 1))
print(f"\nWith covariates - LATE: {est_fuzzy_covs.coef.iloc[2]:.3f}")

# Step 5: Cluster-robust
est_fuzzy_clust = rdrobust(y = outcome, x = score, c = 50,
                           fuzzy = treated, cluster = district, vce = "cr1")
print(f"Clustered - LATE: {est_fuzzy_clust.coef.iloc[2]:.3f} "
      f"(SE = {est_fuzzy_clust.se.iloc[2]:.3f})")

# Step 6: First stage plot
rdplot(y = treated, x = score, c = 50,
       title = "First Stage: Treatment Take-up",
       x_label = "Eligibility Score",
       y_label = "P(Treatment)")
```

### Stata

```stata
* Simulate Fuzzy RD data
clear
set seed 2024
set obs 2000

gen score = 20 + 60 * runiform()
gen eligible = (score >= 50)
gen take_up_prob = eligible * 0.8 + (1 - eligible) * 0.1
gen treated = (runiform() < take_up_prob)
gen outcome = 10 + 0.5 * score + 5 * treated + rnormal(0, 3)
gen age = 30 + 0.2 * score + rnormal(0, 5)
gen district = ceil(20 * runiform())

* Step 1: First stage
rdrobust treated score, c(50)
display "First stage jump: " e(tau_cl) " (p = " e(pv_rb) ")"

* Step 2: Reduced form
rdrobust outcome score, c(50)
display "Reduced form jump: " e(tau_cl) " (p = " e(pv_rb) ")"

* Step 3: Fuzzy RD (LATE)
rdrobust outcome score, c(50) fuzzy(treated)
rdrobust outcome score, c(50) fuzzy(treated) all

display _n "=== Fuzzy RD: Program Effect (LATE) ==="
display "LATE Estimate: " %7.3f e(tau_bc)
display "Robust SE: " %6.3f e(se_tau_rb)
display "Robust 95% CI: [" %7.3f e(ci_l_rb) " , " %7.3f e(ci_r_rb) "]"
display "Robust p-value: " %6.4f e(pv_rb)
display "Bandwidth: h_l = " %6.2f e(h_l) " , h_r = " %6.2f e(h_r)

* Step 4: With covariates
rdrobust outcome score, c(50) fuzzy(treated) covs(age)

* Step 5: Cluster-robust
rdrobust outcome score, c(50) fuzzy(treated) vce(cluster district)

* Step 6: First stage plot
rdplot treated score, c(50) ///
    graph_options(title("First Stage: Treatment Take-up") ///
                  xtitle("Eligibility Score") ///
                  ytitle("P(Treatment)"))
```

---

## Output Comparison

Results from simulated data (exact values depend on seed; structure is consistent):

| Metric | R | Python | Stata |
|--------|---|--------|-------|
| First stage jump | ~0.70 | ~0.70 | ~0.70 |
| Reduced form jump | ~3.5 | ~3.5 | ~3.5 |
| LATE (Fuzzy estimate) | ~5.0 | ~5.0 | ~5.0 |
| Robust SE | ~1.2 | ~1.2 | ~1.2 |
| Robust p-value | < 0.001 | < 0.001 | < 0.001 |
| True effect | 5.0 | 5.0 | 5.0 |

Note: The Fuzzy RD estimate ≈ Reduced Form / First Stage ≈ 3.5 / 0.70 ≈ 5.0, recovering the true LATE.

---

## Interpretation

The Fuzzy RD estimate of approximately **5.0 units** represents the Local Average Treatment Effect (LATE) for compliers at the cutoff — individuals whose program participation is determined by crossing the eligibility threshold.

**Key checks**:
1. **First stage is strong** (jump ≈ 0.70, p < 0.001): 70 percentage point increase in treatment probability at cutoff ensures the denominator of the Wald ratio is far from zero.
2. **LATE recovers true effect**: The estimated 5.0 closely matches the data-generating process parameter of 5.0.
3. **Interpretation scope**: This effect is local to compliers at score = 50. It does not apply to always-takers (who enroll regardless) or never-takers (who never enroll).

**Critical Fuzzy RD workflow**:
1. Always check first stage first — if insignificant, Fuzzy RD is unreliable
2. Report both reduced form AND Fuzzy estimate
3. LATE interpretation requires monotonicity (crossing threshold can only increase treatment probability, never decrease it)
