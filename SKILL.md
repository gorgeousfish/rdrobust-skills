---
name: rdrobust
description: >-
  [WHAT] rdrobust: Local polynomial regression discontinuity estimation with
  robust bias-corrected confidence intervals (Sharp/Fuzzy/Kink RD designs).
  [WHEN] Use when: analyzing causal effects at policy thresholds, evaluating
  treatment effect at eligibility cutoffs, estimating discontinuity in running
  variable, performing RDD with data-driven bandwidth selection, RD plot
  visualization with optimal binning.
  Keywords: regression discontinuity, RDD, sharp RD, fuzzy RD, kink RD,
  bandwidth selection, local polynomial, bias correction, rdplot, rdbwselect,
  Calonico Cattaneo Titiunik
metadata:
  author: ci2agent
  version: 1.0.0
  package: rdrobust
  language: r|python|stata
  estimand: LATE
  paper: Calonico, Cattaneo and Titiunik (2014)
---

# rdrobust — Local Polynomial RD Estimation with Robust Inference

## 1. Activation

This skill activates when the user's intent matches any of the following:

- "Estimate a regression discontinuity design"
- "RDD analysis at a cutoff/threshold"
- "Sharp RD / Fuzzy RD / Kink RD estimation"
- "Bandwidth selection for RD"
- "RD plot with confidence intervals"
- "rdrobust / rdbwselect / rdplot"
- "Robust bias-corrected confidence intervals for RDD"
- "Local polynomial estimation at a discontinuity"
- "rdrobust package for causal inference"
- "Calonico Cattaneo Titiunik 2014 method"
- "Sharp RD at a policy cutoff"
- "Fuzzy RD with imperfect compliance"
- "Data-driven bandwidth selection for RD"
- "Optimal RD plot with binning"
- "Treatment effect at eligibility threshold"

---

## File Index

| File | Purpose | Quick Link |
|------|---------|-----------|
| lang/r.md | R API reference | [→ View](./lang/r.md) |
| lang/python.md | Python API reference | [→ View](./lang/python.md) |
| lang/stata.md | Stata API reference | [→ View](./lang/stata.md) |
| examples/ | Executable examples | [→ View](./examples/) |
| diagnostics.md | Diagnostic procedures | [→ View](./diagnostics.md) |
| method-card.md | Method overview & theory | [→ View](./method-card.md) |
| estimators/ | Per-estimator guides | [→ View](./estimators/) |
| CROSS-LANGUAGE-MAP.md | Cross-language mapping | [→ View](./CROSS-LANGUAGE-MAP.md) |

---

## 2. Quick Start (3 Steps)

### Step 1: Install and Load

#### R
```r
install.packages("rdrobust")
library(rdrobust)
```

#### Python
```bash
pip install rdrobust
```
```python
from rdrobust import rdrobust, rdbwselect, rdplot
```

#### Stata
```stata
net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace
```

### Step 2: Load Data

> **Data**: All examples use the built-in `rdrobust_RDsenate` dataset (U.S. Senate elections). No external download needed.
> - R: `data(rdrobust_RDsenate)` loads automatically
> - Python: `from rdrobust import rdrobust_RDsenate; data = rdrobust_RDsenate()`
> - Stata: shipped as `rdrobust_senate.dta` with the package installation

#### R
```r
data(rdrobust_RDsenate)
y <- rdrobust_RDsenate$vote
x <- rdrobust_RDsenate$margin
```

#### Python
```python
from rdrobust import rdrobust
from rdrobust.datasets import rdrobust_RDsenate

data = rdrobust_RDsenate()
y = data['vote'].values
x = data['margin'].values
```

#### Stata
```stata
use rdrobust_senate.dta, clear
```

### Step 3: Run rdrobust and Interpret

#### R
```r
est <- rdrobust(y = y, x = x)
summary(est)

# Key output:
# =============================================================================
#         Method     Coef.   Std. Err.    z      P>|z|    [95% Conf. Interval]
# =============================================================================
#   Conventional    7.414     1.459     5.082    0.000     [4.554 , 10.274]
#        Robust         -         -     4.311    0.000     [3.988 , 10.949]
# =============================================================================
# BW est. (h):  16.792   BW bias (b):  27.437
# N (left):     2148     N (right):    2148
#
# Interpretation: Winning a close Senate election causes approximately 7.4
# percentage points higher vote share in the next election (incumbency advantage).
# The robust 95% CI [3.99, 10.95] excludes zero → statistically significant.
```

#### Python
```python
est = rdrobust(y=y, x=x)
print(est)

# Same interpretation: ~7.4 pp incumbency advantage, robust p < 0.001
```

#### Stata
```stata
rdrobust vote margin
* Same results: coef ~7.4, robust CI excludes zero
```

---

## 3. Multi-Language Interaction Logic

### Language Selection Protocol

1. **If user specifies a language** (e.g., "in R", "using Python", "Stata code") → use that language exclusively
2. **If user does not specify** → ask: "Which language would you prefer: R, Python, or Stata? All three produce identical results."
3. **If user asks for comparison** → provide all three in parallel blocks

### Cross-Language Parameter Mapping

Core parameters are identical across implementations but syntax differs. See [CROSS-LANGUAGE-MAP.md](./CROSS-LANGUAGE-MAP.md) for the complete mapping.

Key differences:
| Feature | R | Python | Stata |
|---------|---|--------|-------|
| Function call | `rdrobust(y, x, c=0)` | `rdrobust(y=y, x=x, c=0)` | `rdrobust y x, c(0)` |
| Fuzzy option | `fuzzy = T` (vector) | `fuzzy=T` (array) | `fuzzy(T)` (varname) |
| Covariates | `covs = Z` (matrix) | `covs=Z` (2D array) | `covs(z1 z2)` (varlist) |
| Cluster VCE | `vce = "nn", cluster = cl` | `vce="nn", cluster=cl` | `vce(cluster cl)` |
| Output access | `est$coef`, `est$ci` | `est.coef`, `est.ci` | `e(tau_cl)`, `e(ci_l_rb)` |
| RD Plot | `rdplot(y, x, c=0)` | `rdplot(y=y, x=x, c=0)` | `rdplot y x, c(0)` |

### Important Cross-Language Caveats

- **R ≥ 4.0.0**: `all = TRUE` moved from `rdrobust()` to `summary()` — produces warning if used in main call
- **Python**: Arrays must be 1-D numpy arrays (not pandas Series for some versions)
- **Stata**: Variable names directly in command; options in parentheses after comma

---

## 4. Estimator Selector / Decision Tree

Use this decision tree to select the correct estimator and function:

```
Is there a known cutoff in the running variable?
├── NO → RD is not appropriate. Consider DID, IV, or matching.
└── YES
    ├── Is treatment DETERMINISTIC at the cutoff?
    │   ├── YES → SHARP RD
    │   │   ├── Want point estimate + CI? → rdrobust(y, x, c=...)
    │   │   ├── Want bandwidth only? → rdbwselect(y, x, c=...)
    │   │   └── Want visualization? → rdplot(y, x, c=...)
    │   └── NO → Treatment is PROBABILISTIC at cutoff
    │       └── FUZZY RD
    │           ├── rdrobust(y, x, fuzzy=T, c=...)
    │           └── Check first stage: rdrobust(T, x, c=...)
    └── Is the discontinuity in the SLOPE (not level)?
        └── YES → KINK RD
            └── rdrobust(y, x, deriv=1, c=...)
```

### Quick Reference Table

| Design | When to Use | rdrobust Call (R) | Key Parameter |
|--------|-------------|-------------------|---------------|
| Sharp RD | Treatment deterministic at cutoff (e.g., test score threshold) | `rdrobust(y, x, c=0)` | Default |
| Fuzzy RD | Treatment probabilistic at cutoff (e.g., imperfect compliance) | `rdrobust(y, x, fuzzy=T, c=0)` | `fuzzy` |
| Kink RD | Slope change at cutoff (e.g., tax rate kink) | `rdrobust(y, x, deriv=1, c=0)` | `deriv=1` |
| Bandwidth only | Pre-analysis bandwidth exploration | `rdbwselect(y, x, c=0)` | `bwselect` |
| Visualization | Data visualization with optimal binning | `rdplot(y, x, c=0)` | `binselect` |

### Design Diagnostics Before Estimation

Before choosing an estimator, verify:

1. **Is the cutoff known and institutional?** (not data-driven)
2. **Does the density test pass?** (`rddensity` p > 0.05)
3. **Is treatment take-up sharp or fuzzy?** (plot treatment vs. running variable)
4. **Is the expected discontinuity in level or slope?** (determines `deriv`)

---

## 5. Core Concept

### Estimand

The regression discontinuity (RD) design identifies a **local average treatment effect (LATE)** at the cutoff \(c\) of a running variable \(X\):

\[\tau_{\text{SRD}} = \lim_{x \downarrow c} E[Y_i | X_i = x] - \lim_{x \uparrow c} E[Y_i | X_i = x] = E[Y_i(1) - Y_i(0) | X_i = c]\]

For **Fuzzy RD** (where treatment assignment is not deterministic at the cutoff):

\[\tau_{\text{FRD}} = \frac{\lim_{x \downarrow c} E[Y_i | X_i = x] - \lim_{x \uparrow c} E[Y_i | X_i = x]}{\lim_{x \downarrow c} E[D_i | X_i = x] - \lim_{x \uparrow c} E[D_i | X_i = x]}\]

For **Kink RD** (`deriv = 1`): the estimand is the change in the *slope* of the conditional expectation at the cutoff.

### Identification Assumptions (5-Dimension Table)

| # | Assumption | D1: Formal | D2: Intuition | D3: Testability | D4: Diagnostic | D5: Violation Consequence |
|---|-----------|-----------|---------------|-----------------|----------------|--------------------------|
| 1 | **Continuity of Conditional Expectations** | \(E[Y_i(0) \mid X_i = x]\) and \(E[Y_i(1) \mid X_i = x]\) are continuous in \(x\) at \(c\) | Units just above and just below the threshold are essentially identical — comparing them is like a local randomized experiment | Not directly testable (potential outcomes unobserved jointly). Indirect: continuity of predetermined covariates at cutoff | **R**: `rdrobust(covariate, x)` for each covariate; **Python**: `rdrobust(cov, x)`; **Stata**: `rdrobust covariate runvar` — check p-value > 0.05 | Bias in treatment effect estimate; RD estimate captures treatment effect + confounding jump |
| 2 | **No Precise Manipulation** | \(f_X(x)\) is continuous at \(c\) (no mass point or density jump at cutoff) | Individuals cannot precisely sort themselves to one side of the cutoff; assignment near the cutoff is as-good-as-random | Directly testable via density test | **R/Python**: `rddensity(x, c = cutoff)` from `rddensity` package; **Stata**: `rddensity runvar, c(cutoff)` — p > 0.05 supports assumption | If manipulated: selection bias invalidates local randomization argument |
| 3 | **Local Regularity / Smoothness** | \(\mu_+(x)\) and \(\mu_-(x)\) are \(S \geq 3\) times continuously differentiable; \(f(x)\) continuous and bounded away from zero; \(\sigma^2(x)\) bounded away from zero (CCT 2014, Assumption 1) | The regression functions must be smooth enough on each side to justify local polynomial approximation; density positive ensures observations exist | Indirectly testable: compare estimates across polynomial orders; large sensitivity suggests insufficient smoothness | Run `rdrobust` with `p = 1` and `p = 2`; check `rdbwselect()` bandwidth stability | Polynomial approximation is poor; bias estimates unreliable; CIs have incorrect coverage |
| 4 | **SUTVA (No Interference)** | \(Y_i = Y_i(D_i)\) — outcome depends only on own treatment, not others' treatment status | One person's treatment assignment near the cutoff does not affect another person's outcome | Not directly testable. Indirect: check for spillover patterns, spatial/network effects | Domain-specific: examine whether treatment of units near cutoff could spill over (e.g., geographic proximity); donut-hole specifications | Bias from interference; estimated effect is mixture of direct and indirect effects |
| 5 | **First Stage (Fuzzy RD only)** | \(\lim_{x \downarrow c} E[D_i \mid X_i = x] - \lim_{x \uparrow c} E[D_i \mid X_i = x] \neq 0\); monotonicity: \(D_i(1) \geq D_i(0)\) for all \(i\) (CCT 2014, Assumption 3) | At the cutoff, there must be a meaningful jump in the probability of receiving treatment; no defiers | Directly testable (first stage); monotonicity generally untestable | **R**: `rdrobust(treatment, x)` check if estimate significantly different from 0; **Stata**: `rdrobust treatment runvar` — check significance | Weak first stage → imprecise/biased Fuzzy RD estimates; violated monotonicity → loss of LATE interpretation |

### Parameter Sensitivity Classification

| Parameter | Risk | Rationale |
|-----------|------|-----------|
| `c` (cutoff) | 🔴 | Defines the entire identification strategy; wrong cutoff = wrong estimand |
| `fuzzy` | 🔴 | Sharp vs. Fuzzy is a design choice — wrong specification changes the estimand entirely |
| `deriv` | 🔴 | Determines whether estimating level discontinuity (0) or kink (1) — fundamentally different quantities |
| `p` (polynomial order) | 🟡 | Default p=1 is robust for most designs; higher orders risk overfitting near cutoff |
| `h` / `b` (bandwidths) | 🟡 | Data-driven MSE-optimal is default; manual override requires strong justification |
| `vce` | 🟡 | Choice of variance estimator affects inference (CI coverage); clustering is critical if data is clustered |
| `masspoints` | 🟡 | Discrete running variables need adjustment; ignoring mass points can distort bandwidth selection |
| `bwselect` | 🟢 | All MSE/CER methods are theoretically justified; choice affects precision not validity |
| `kernel` | 🟢 | Triangular is theoretically optimal; uniform/epanechnikov are standard alternatives |
| `covs` | 🟢 | Covariates improve efficiency but don't change point estimate; always valid to include |

### When to Use / When NOT to Use

**Use rdrobust when:**
- A policy/treatment is assigned based on a threshold rule (test score, age, income, vote margin)
- You observe the running variable continuously (or with many mass points, using `masspoints = "adjust"`)
- You want robust inference with automatic bias correction and data-driven bandwidth selection
- You need formal confidence intervals that account for bandwidth-induced bias

**Do NOT use rdrobust when:**
- There is no clear cutoff in the assignment mechanism
- The running variable is manipulable and density testing fails
- Sample size near the cutoff is very small (< 50 effective observations per side)
- You want average treatment effects far from the cutoff (RD is inherently local)
- The design is better captured by DID, IV, or matching

---

## 6. Implementation Workflow

### Phase 1: Data Preparation and Validation

**Objective**: Ensure data integrity, verify variable types, and center the running variable at the cutoff.

#### R
```r
library(rdrobust)
library(rddensity)

# Load data
data(rdrobust_RDsenate)
y <- rdrobust_RDsenate$vote    # Outcome: vote share at t+2
x <- rdrobust_RDsenate$margin  # Running variable: margin at t (cutoff = 0)

# Validate: check for missing values
cat("Missing y:", sum(is.na(y)), "\n")
cat("Missing x:", sum(is.na(x)), "\n")

# Verify running variable distribution around cutoff
cat("N below cutoff:", sum(x < 0), "\n")
cat("N above cutoff:", sum(x >= 0), "\n")
cat("Min x:", min(x), " Max x:", max(x), "\n")

# Check for mass points
cat("Unique values of x:", length(unique(x)), "\n")
cat("Total observations:", length(x), "\n")
```

#### Python
```python
import numpy as np
from rdrobust import rdrobust, rdbwselect, rdplot
from rdrobust.datasets import rdrobust_RDsenate

# Load data
data = rdrobust_RDsenate()
y = data['vote'].values
x = data['margin'].values

# Validate
print(f"Missing y: {np.isnan(y).sum()}")
print(f"Missing x: {np.isnan(x).sum()}")
print(f"N below cutoff: {(x < 0).sum()}")
print(f"N above cutoff: {(x >= 0).sum()}")
print(f"Unique values: {len(np.unique(x))}")
```

#### Stata
```stata
use rdrobust_senate.dta, clear

* Validate
summarize vote margin
tab margin if missing(vote)

* Check observations around cutoff
count if margin < 0
count if margin >= 0

* Mass points check
distinct margin
```

### Phase 2: Visualization with rdplot()

**Objective**: Visually inspect the data for evidence of a discontinuity before formal estimation.

#### R
```r
# Basic RD plot with data-driven binning
rdplot(y = y, x = x, c = 0,
       title = "RD Plot: Senate Incumbency Advantage",
       x.label = "Vote Margin at Election t",
       y.label = "Vote Share at Election t+2")

# Evenly-spaced bins (IMSE-optimal)
rdplot(y = y, x = x, c = 0,
       binselect = "es",
       title = "RD Plot (ES Bins)")

# Quantile-spaced bins (IMSE-optimal)
rdplot(y = y, x = x, c = 0,
       binselect = "qs",
       title = "RD Plot (QS Bins)")

# Custom bin count for robustness
rdplot(y = y, x = x, c = 0,
       nbins = c(20, 20),
       title = "RD Plot (20 bins each side)")
```

#### Python
```python
# Basic RD plot
rdplot(y=y, x=x, c=0,
       title="RD Plot: Senate Incumbency Advantage",
       x_label="Vote Margin at Election t",
       y_label="Vote Share at Election t+2")

# With evenly-spaced bins
rdplot(y=y, x=x, c=0,
       binselect="es",
       title="RD Plot (ES Bins)")
```

#### Stata
```stata
* Basic RD plot
rdplot vote margin, c(0) graph_options(title("RD Plot: Senate Incumbency"))

* Evenly-spaced bins
rdplot vote margin, c(0) binselect(es)

* Quantile-spaced bins
rdplot vote margin, c(0) binselect(qs)
```

### Phase 3: Bandwidth Selection with rdbwselect()

**Objective**: Explore data-driven bandwidth choices before estimation; compare MSE-optimal vs CER-optimal.

#### R
```r
# MSE-optimal bandwidth (default)
bw_mse <- rdbwselect(y = y, x = x, c = 0, bwselect = "mserd")
summary(bw_mse)
# Output: h = 16.79 (main bandwidth), b = 27.44 (bias bandwidth)

# CER-optimal bandwidth (tighter, better coverage)
bw_cer <- rdbwselect(y = y, x = x, c = 0, bwselect = "cerrd")
summary(bw_cer)
# CER bandwidth is typically smaller: h_CER < h_MSE

# Two-sided (asymmetric) bandwidth
bw_two <- rdbwselect(y = y, x = x, c = 0, bwselect = "msetwo")
summary(bw_two)

# Compare all methods simultaneously
bw_all <- rdbwselect(y = y, x = x, c = 0, all = TRUE)
summary(bw_all)
```

#### Python
```python
# MSE-optimal
bw_mse = rdbwselect(y=y, x=x, c=0, bwselect="mserd")
print(bw_mse)

# CER-optimal
bw_cer = rdbwselect(y=y, x=x, c=0, bwselect="cerrd")
print(bw_cer)

# All methods
bw_all = rdbwselect(y=y, x=x, c=0, all=True)
print(bw_all)
```

#### Stata
```stata
* MSE-optimal
rdbwselect vote margin, c(0) bwselect(mserd)

* CER-optimal
rdbwselect vote margin, c(0) bwselect(cerrd)

* All methods
rdbwselect vote margin, c(0) all
```

### Phase 4: Estimation with rdrobust() and Interpretation

**Objective**: Obtain robust bias-corrected point estimates and confidence intervals; interpret all three inference rows.

#### R
```r
# Main estimation: Sharp RD with MSE-optimal bandwidth
est <- rdrobust(y = y, x = x, c = 0)
summary(est)

# Full output with all three inference rows
summary(est, all = TRUE)
# Row 1: Conventional — uses standard SE (may have coverage distortion)
# Row 2: Bias-corrected — corrects point estimate for bias
# Row 3: Robust — bias-corrected point + variance that accounts for bias estimation
#         → THIS IS THE RECOMMENDED ROW FOR INFERENCE (CCT 2014)

# Extract key results programmatically
cat("Point estimate (conventional):", est$coef[1], "\n")
cat("Robust 95% CI: [", est$ci[3,1], ",", est$ci[3,2], "]\n")
cat("Robust p-value:", est$pv[3], "\n")
cat("Bandwidth (h):", est$bws[1,1], "\n")
cat("Bandwidth (b):", est$bws[1,2], "\n")
cat("N (left of cutoff):", est$N_h[1], "\n")
cat("N (right of cutoff):", est$N_h[2], "\n")

# Robustness: CER-optimal bandwidth
est_cer <- rdrobust(y = y, x = x, c = 0, bwselect = "cerrd")
summary(est_cer)

# Robustness: alternative polynomial order
est_p2 <- rdrobust(y = y, x = x, c = 0, p = 2)
summary(est_p2)

# Robustness: half and double bandwidth
est_half <- rdrobust(y = y, x = x, c = 0, h = est$bws[1,1] * 0.5)
est_double <- rdrobust(y = y, x = x, c = 0, h = est$bws[1,1] * 2)
```

#### Python
```python
# Main estimation
est = rdrobust(y=y, x=x, c=0)
print(est)

# CER-optimal bandwidth
est_cer = rdrobust(y=y, x=x, c=0, bwselect="cerrd")
print(est_cer)

# Polynomial order sensitivity
est_p2 = rdrobust(y=y, x=x, c=0, p=2)
print(est_p2)
```

#### Stata
```stata
* Main estimation
rdrobust vote margin, c(0)

* Full three-row table
rdrobust vote margin, c(0) all

* CER-optimal bandwidth
rdrobust vote margin, c(0) bwselect(cerrd)

* Polynomial order sensitivity
rdrobust vote margin, c(0) p(2)

* Half bandwidth robustness
local h_half = e(h_l) * 0.5
rdrobust vote margin, c(0) h(`h_half')
```

#### Interpretation Guide

After obtaining results, report:

1. **Point estimate** (from Robust row): magnitude and direction of the treatment effect
2. **Robust 95% CI**: if it excludes zero, the effect is statistically significant at 5%
3. **Effective sample size** (`N_h`): observations within the bandwidth window
4. **Bandwidth**: report `h` (main) and `b` (bias) for replication
5. **Robustness**: results should be qualitatively similar across bandwidth choices and polynomial orders

---

## Complete Template: Your Own RD Dataset

> Replace variable names with your own. This template covers Sharp RD; for Fuzzy, add `fuzzy = treatment_var`.

### R

```r
# === YOUR RD ANALYSIS TEMPLATE ===
# Step 0: Replace these with your variables
df <- read.csv("your_data.csv")
y  <- df$outcome_variable        # Outcome
x  <- df$running_variable        # Running variable (score)
c  <- 60                          # Your cutoff value
covs <- cbind(df$covariate1, df$covariate2)  # Pre-treatment covariates

# Step 1: Density test (manipulation check)
library(rddensity)
dens <- rddensity(X = x, c = c)
summary(dens)  # p > 0.05 required

# Step 2: Visualization
library(rdrobust)
rdplot(y, x, c = c)

# Step 3: Bandwidth selection
bw <- rdbwselect(y, x, c = c)
summary(bw)

# Step 4: Main estimation
est <- rdrobust(y, x, c = c, covs = covs)
summary(est)

# Step 5: Robustness (bandwidth sensitivity)
h_opt <- est$bws[1,1]
for (mult in c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)) {
  est_i <- rdrobust(y, x, c = c, h = h_opt * mult)
  cat(sprintf("h = %.2f: tau_rb = %.4f, p_rb = %.4f\n",
              h_opt * mult, est_i$coef[3], est_i$pv[3]))
}
```

### Python

```python
# === YOUR RD ANALYSIS TEMPLATE ===
import numpy as np
import pandas as pd
from rdrobust import rdrobust, rdbwselect, rdplot
from rddensity import rddensity

# Step 0: Replace with your variables
df = pd.read_csv("your_data.csv")
y = df["outcome_variable"].values
x = df["running_variable"].values
c = 60  # Your cutoff value
covs = df[["covariate1", "covariate2"]].values

# Step 1: Density test
dens = rddensity(X=x, c=c)
print(dens)  # p > 0.05 required

# Step 2: Visualization
rdplot(y=y, x=x, c=c)

# Step 3: Bandwidth selection
bw = rdbwselect(y=y, x=x, c=c)
print(bw)

# Step 4: Main estimation
est = rdrobust(y=y, x=x, c=c, covs=covs)
print(est)

# Step 5: Robustness
h_opt = est.bws.iloc[0, 0]
for mult in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]:
    est_i = rdrobust(y=y, x=x, c=c, h=h_opt * mult)
    print(f"h = {h_opt*mult:.2f}: tau_rb = {est_i.coef.iloc[2]:.4f}, p_rb = {est_i.pv.iloc[2]:.4f}")
```

### Stata

```stata
* === YOUR RD ANALYSIS TEMPLATE ===
use your_data.dta, clear

* Step 0: Define your variables
local y outcome_variable
local x running_variable
local c 60
local covs covariate1 covariate2

* Step 1: Density test
rddensity `x', c(`c')

* Step 2: Visualization
rdplot `y' `x', c(`c')

* Step 3: Bandwidth selection
rdbwselect `y' `x', c(`c')

* Step 4: Main estimation
rdrobust `y' `x', c(`c') covs(`covs')
local h_opt = e(h_l)

* Step 5: Robustness
foreach mult in 0.5 0.75 1.0 1.25 1.5 2.0 {
    local h_i = `h_opt' * `mult'
    rdrobust `y' `x', c(`c') h(`h_i')
    display "h = " %6.2f `h_i' ": tau_rb = " %8.4f e(tau_bc) ", p_rb = " %6.4f e(pv_rb)
}
```

---

## 7. Complete Examples

### Example 1: U.S. Senate Incumbency Advantage (Sharp RD)

**Research question**: Does winning a close election cause an incumbency advantage in the next election?

**Data**: U.S. Senate elections (`rdrobust_RDsenate`). Running variable = vote margin at time t (cutoff = 0). Outcome = vote share at time t+2.

**Design**: Sharp RD — winning (margin > 0) deterministically assigns incumbency status.

#### R
```r
library(rdrobust)
data(rdrobust_RDsenate)
y <- rdrobust_RDsenate$vote
x <- rdrobust_RDsenate$margin

# Step 1: Visualize
rdplot(y = y, x = x, c = 0,
       title = "Senate Incumbency RD",
       x.label = "Margin at t", y.label = "Vote Share at t+2")

# Step 2: Estimate
est <- rdrobust(y = y, x = x, c = 0)
summary(est)

# Step 3: Robustness
est_cer <- rdrobust(y = y, x = x, c = 0, bwselect = "cerrd")
est_p2 <- rdrobust(y = y, x = x, c = 0, p = 2)

# Results: ~7.4 pp incumbency advantage
# Robust CI: [3.99, 10.95], p < 0.001
```

#### Python
```python
from rdrobust import rdrobust, rdplot
from rdrobust.datasets import rdrobust_RDsenate
data = rdrobust_RDsenate()
y = data['vote'].values
x = data['margin'].values

rdplot(y=y, x=x, c=0, title="Senate Incumbency RD")
est = rdrobust(y=y, x=x, c=0)
print(est)
```

#### Stata
```stata
use rdrobust_senate.dta, clear
rdplot vote margin, c(0) graph_options(title("Senate Incumbency RD"))
rdrobust vote margin, c(0)
rdrobust vote margin, c(0) bwselect(cerrd)
```

### Example 2: Fuzzy RD with Imperfect Compliance

**Research question**: What is the effect of Head Start eligibility on child health outcomes?

**Design**: Fuzzy RD — crossing the poverty threshold makes children *eligible* for Head Start, but not all eligible children enroll (imperfect compliance).

#### R
```r
library(rdrobust)
# Suppose: y = health outcome, x = poverty score, T = actual enrollment
# cutoff = poverty threshold

# Fuzzy RD estimation
est_fuzzy <- rdrobust(y = y, x = x, fuzzy = T, c = 0)
summary(est_fuzzy)

# CRITICAL: Check first stage
first_stage <- rdrobust(y = T, x = x, c = 0)
summary(first_stage)
# First stage must be significant (p < 0.05) for Fuzzy RD to be valid

# Interpretation: Fuzzy RD coefficient is LATE for compliers at the cutoff
# (those who enroll in Head Start because they crossed the eligibility threshold)
```

#### Python
```python
# Fuzzy RD
est_fuzzy = rdrobust(y=y, x=x, fuzzy=T, c=0)
print(est_fuzzy)

# First stage check
first_stage = rdrobust(y=T, x=x, c=0)
print(first_stage)
```

#### Stata
```stata
* Fuzzy RD
rdrobust outcome score, c(0) fuzzy(enrolled)

* First stage
rdrobust enrolled score, c(0)
```

---

## 8. Common Pitfalls

| # | Pitfall | Consequence | Fix | Citation |
|---|---------|-------------|-----|----------|
| 1 | **Choosing bandwidth manually** without justification | Coverage distortion: manually chosen bandwidths do not satisfy the MSE-optimality conditions, leading to CIs with incorrect coverage | Use data-driven `bwselect = "mserd"` (default) or `"cerrd"` for inference-focused bandwidth; report sensitivity to 0.5h, 1.5h | CCF (2020), Econometrics Journal |
| 2 | **Confusing rdplot() binning with rdrobust() bandwidth** | rdplot() uses IMSE-optimal binning for visualization; rdrobust() uses MSE-optimal bandwidth for estimation — these are entirely separate problems with different optimal solutions | Understand that rdplot is for data display; rdrobust is for formal inference. Never use rdplot bin widths as estimation bandwidths | CCT (2015), JASA |
| 3 | **Not testing for manipulation** at the cutoff | Violates Assumption 2 (density continuity); biased estimates due to selective sorting | Run `rddensity` before estimation; if p < 0.05, the design may be invalid | McCrary (2008); Cattaneo, Jansson, Ma (2020) |
| 4 | **Using wrong polynomial order** (p ≥ 3) | High-order polynomials overfit near boundaries, producing erratic behavior in sparse regions; bias correction becomes unreliable | Stick to p = 1 (default, theoretically optimal for boundary estimation); use p = 2 only for robustness checks | CCT (2014), Econometrica, Remark 9 |
| 5 | **Forgetting LATE interpretation for Fuzzy RD** | Reporting the Fuzzy RD estimate as if it applies to the entire population; it identifies only the effect for compliers at the cutoff | Explicitly state: "This is the LATE for compliers at the eligibility threshold." Check first-stage magnitude | Hahn, Todd, van der Klaauw (2001) |
| 6 | **Reporting conventional SE instead of robust** | Under-coverage of confidence intervals; Type I error rate inflated beyond nominal level | Always report robust bias-corrected CI (row 3 in output); conventional CIs are invalid with MSE-optimal bandwidths | CCT (2014), Theorem 1 |
| 7 | **Ignoring mass points** in discrete running variables | Biased bandwidth selection; too few effective observations within the window; smoothness conditions locally violated | Use `masspoints = "adjust"` (default in recent versions); check with `masspoints = "check"` | Cattaneo, Idrobo, Titiunik (2020) |
| 8 | **Not verifying covariate balance** at cutoff | Cannot indirectly assess continuity assumption; possible confounding if covariates jump at cutoff | Run rdrobust on each pre-treatment covariate as the outcome; all should have p > 0.05 | Cattaneo, Idrobo, Titiunik (2020), Ch. 4 |
| 9 | **Using RD with a data-driven cutoff** | If the cutoff is chosen based on the data (e.g., a kink in the outcome), the design has no external validity and identification fails | The cutoff must be determined by institutional rules independent of the outcome data | Lee and Lemieux (2010), JEL |
| 10 | **Clustering data without specifying cluster VCE** | Standard errors too small; over-rejection of null hypothesis; invalid inference | Use `vce = "cluster"` with cluster variable: R/Python `cluster = cl`; Stata `vce(cluster cl)` | CCT (2014), Section 4 |

### Covariate Selection: Do and Don't

**Include (pre-treatment only):**
- Baseline demographics (age, gender, pre-program education)
- Historical performance (past test scores, pre-treatment income)
- Institutional features (school type, district characteristics)

**Do NOT include (post-treatment / affected by treatment):**
- Outcomes measured after treatment (post-program earnings)
- Intermediate variables on the causal path (program hours, services received)
- Variables defined only for treated units

> **Rule of thumb**: If a variable could plausibly change *because of* crossing the cutoff, do NOT put it in `covs`.

---

## 9. Anti-Patterns

### Anti-Pattern 1: Reporting Conventional Inference

#### ❌ WRONG
```r
est <- rdrobust(y, x)
# Using conventional CI (row 1) — INVALID with MSE-optimal bandwidth
cat("CI:", est$ci[1,1], "to", est$ci[1,2])
cat("p-value:", est$pv[1])
```

#### ✅ CORRECT
```r
est <- rdrobust(y, x)
# Using robust bias-corrected CI (row 3) — valid per CCT (2014) Theorem 1
cat("CI:", est$ci[3,1], "to", est$ci[3,2])
cat("p-value:", est$pv[3])
```

**Why**: Conventional CIs have severe under-coverage when used with MSE-optimal bandwidths because they ignore the asymptotic bias term. The robust CI accounts for both the bias correction and the additional variance from estimating the bias (CCT 2014).

---

### Anti-Pattern 2: Using `all = TRUE` in rdrobust() (R ≥ 4.0.0)

#### ❌ WRONG
```r
# In R >= 4.0.0, `all` was moved to summary()
est <- rdrobust(y, x, all = TRUE)  # Produces warning; argument ignored
```

#### ✅ CORRECT
```r
# Correct usage in R >= 4.0.0
est <- rdrobust(y, x)
summary(est, all = TRUE)  # Shows all three inference rows
```

**Why**: The API was refactored to separate estimation from display. The `all` flag controls which rows appear in the summary table, not the estimation itself.

---

### Anti-Pattern 3: Specifying Cluster as Separate Option in Stata

#### ❌ WRONG
```stata
* Stata does NOT accept cluster as a standalone option
rdrobust y x, cluster(clvar)
* Error: option cluster() not allowed
```

#### ✅ CORRECT
```stata
* Cluster variable must be inside vce()
rdrobust y x, vce(cluster clvar)
```

**Why**: In Stata's `rdrobust` syntax, clustering is a sub-option of `vce()`. This differs from many other Stata commands where `cluster()` is a standalone option.

---

### Anti-Pattern 4: Fuzzy RD Without Checking First Stage

#### ❌ WRONG
```r
# Running Fuzzy RD without verifying first-stage relevance
est <- rdrobust(y, x, fuzzy = treatment)
summary(est)
# Reporting the ratio estimator without checking denominator
```

#### ✅ CORRECT
```r
# Step 1: Verify first stage
first_stage <- rdrobust(y = treatment, x = x)
summary(first_stage)
# CHECK: Is the first-stage coefficient significant? Is N_h adequate?

# Step 2: Only proceed if first stage is strong
if (first_stage$pv[3] < 0.05) {
  est <- rdrobust(y, x, fuzzy = treatment)
  summary(est)
  cat("LATE for compliers:", est$coef[1], "\n")
}
```

**Why**: The Fuzzy RD estimator divides by the first-stage discontinuity. If the first stage is weak (near zero), the ratio is unstable, producing extreme or meaningless estimates—analogous to weak instruments in IV (Hahn et al. 2001).

---

### Anti-Pattern 5: Using rdplot Bandwidth for Estimation

#### ❌ WRONG
```r
# Using rdplot's bin width as if it were an estimation bandwidth
pl <- rdplot(y, x, c = 0)
# Extracting rdplot's bin boundaries and using them in rdrobust
est <- rdrobust(y, x, c = 0, h = pl$binselect$h)  # WRONG concept
```

#### ✅ CORRECT
```r
# rdplot and rdrobust solve DIFFERENT optimization problems
# rdplot: IMSE-optimal binning for visualization (bin count ~ n^{1/3})
# rdrobust: MSE-optimal bandwidth for estimation (h ~ n^{-1/5})
rdplot(y, x, c = 0)         # For display
est <- rdrobust(y, x, c = 0) # For inference (uses its own optimal bandwidth)
```

**Why**: rdplot minimizes integrated MSE of bin means for visualization (CCT 2015 JASA). rdrobust minimizes MSE of the point estimator for inference (CCT 2014 Econometrica). These are mathematically distinct problems with different convergence rates.

---

## 10. Validation Checklist

After completing an RD analysis with rdrobust, verify all items:

### Design Validity
- [ ] Cutoff value `c` matches the institutional assignment rule (not data-driven)
- [ ] Running variable has sufficient observations near the cutoff (check `N_h` ≥ 50 per side)
- [ ] Density test (`rddensity`) shows no evidence of manipulation (p > 0.05)
- [ ] Covariate balance holds at the cutoff (rdrobust on each pre-treatment covariate, all p > 0.05)
- [ ] Sharp vs. Fuzzy design correctly identified (check actual treatment take-up at cutoff)

### Estimation Quality
- [ ] Reported inference uses **robust bias-corrected** CI (not conventional)
- [ ] Bandwidth selection method is documented (default `mserd` or justified alternative)
- [ ] Polynomial order documented (default p = 1; p = 2 for robustness)
- [ ] Kernel choice documented (default triangular; alternatives for robustness)
- [ ] If Fuzzy RD: first-stage jump is statistically significant and economically meaningful

### Robustness
- [ ] Sensitivity to bandwidth shown (at minimum: 0.5h, 0.75h, 1.5h, 2h)
- [ ] Sensitivity to polynomial order shown (p = 1 and p = 2)
- [ ] CER-optimal bandwidth results reported alongside MSE-optimal
- [ ] Placebo cutoffs tested (effects should be null at non-cutoff points)
- [ ] If clustered data: cluster-robust VCE is specified

### Reporting
- [ ] Mass points diagnostic run if running variable is discrete/coarse
- [ ] RD plot (`rdplot`) visually supports the discontinuity
- [ ] Effective sample sizes reported (N_h left and right)
- [ ] Results are consistent across R/Python/Stata (within floating-point tolerance)
- [ ] LATE interpretation explicitly stated (effect is local to the cutoff)

---

## 11. References

### Sub-files

| File | Purpose |
|------|---------|
| [CROSS-LANGUAGE-MAP.md](./CROSS-LANGUAGE-MAP.md) | Complete parameter and return object mapping across R/Python/Stata |
| [method-card.md](./method-card.md) | Theoretical foundation and mathematical framework |
| [diagnostics.md](./diagnostics.md) | Pre-estimation and post-estimation diagnostic procedures |
| [lang/r.md](./lang/r.md) | Complete R API reference |
| [lang/python.md](./lang/python.md) | Complete Python API reference |
| [lang/stata.md](./lang/stata.md) | Complete Stata API reference |
| [examples/example-sharp-rd-senate.md](./examples/example-sharp-rd-senate.md) | Three-language parallel: Senate incumbency advantage |
| [examples/example-fuzzy-rd-headstart.md](./examples/example-fuzzy-rd-headstart.md) | Three-language parallel: Fuzzy RD with imperfect compliance |

### Primary Academic Sources

- Calonico, S., M. D. Cattaneo, and R. Titiunik (2014). "Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs." *Econometrica* 82(6): 2295-2326.
- Calonico, S., M. D. Cattaneo, and M. H. Farrell (2018). "On the Effect of Bias Estimation on Coverage Accuracy in Nonparametric Inference." *JASA* 113(522): 767-779.
- Calonico, S., M. D. Cattaneo, M. H. Farrell, and R. Titiunik (2019). "Regression Discontinuity Designs using Covariates." *Review of Economics and Statistics* 101(3): 442-451.
- Calonico, S., M. D. Cattaneo, and M. H. Farrell (2020). "Optimal Bandwidth Choice for Robust Bias Corrected Inference in Regression Discontinuity Designs." *Econometrics Journal* 23(2): 192-210.
- Calonico, S., M. D. Cattaneo, and R. Titiunik (2015). "Optimal Data-Driven Regression Discontinuity Plots." *JASA* 110(512): 1753-1769.
- Hahn, J., P. Todd, and W. van der Klaauw (2001). "Identification and Estimation of Treatment Effects with a Regression-Discontinuity Design." *Econometrica* 69(1): 201-209.
- Lee, D. S., and T. Lemieux (2010). "Regression Discontinuity Designs in Economics." *Journal of Economic Literature* 48(2): 281-355.

### Software Articles

- Calonico, S., M. D. Cattaneo, and R. Titiunik (2015). "rdrobust: An R Package for Robust Nonparametric Inference in Regression-Discontinuity Designs." *R Journal* 7(1): 38-51.
- Calonico, S., M. D. Cattaneo, M. H. Farrell, and R. Titiunik (2017). "rdrobust: Software for Regression Discontinuity Designs." *Stata Journal* 17(2): 372-404.

---

## 12. Prerequisites

### R
```r
install.packages("rdrobust")    # >= 2.2.0 recommended
install.packages("rddensity")   # For density tests
library(rdrobust)
```
- R >= 3.5.0
- Dependencies: `ggplot2` (for rdplot)

### Python
```bash
pip install rdrobust              # >= 2.2.0 recommended
pip install rddensity             # For density tests
```
- Python >= 3.7
- Dependencies: `numpy`, `pandas`, `scipy`

### Stata
```stata
net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace
net install rddensity, from(https://raw.githubusercontent.com/rdpackages/rddensity/master/stata) replace
```
- Stata >= 16

### Data Format Requirements
- Outcome variable: continuous numeric
- Running variable: continuous numeric (or discrete with mass-point adjustment)
- For Fuzzy RD: binary treatment indicator
- For clustering: cluster ID variable
- No string variables in estimation columns

---

## 13. Limitations & Disclaimers

### Method Limitations

1. **Local identification only**: RD estimates are valid only at the cutoff; extrapolation to other values of the running variable is not justified without additional assumptions.
2. **Bandwidth-dependent**: Results are sensitive to bandwidth choice, though MSE-optimal selection provides a principled default.
3. **Requires sufficient density near cutoff**: If few observations exist near the threshold, estimates will be imprecise regardless of total sample size.
4. **Continuity assumption is untestable**: The core identifying assumption (continuity of potential outcomes at cutoff) cannot be directly verified — only indirectly supported via diagnostics.
5. **Mass points**: Highly discrete running variables may violate smoothness conditions; `masspoints = "adjust"` provides mitigation but not a complete solution for variables with very few distinct values.
6. **External validity**: Even when internally valid, RD effects at the cutoff may not generalize to other populations or other values of the running variable.

### User Responsibility

- The analyst is responsible for verifying that the RD design is appropriate for the research question and that institutional details support the continuity assumption.
- Robustness checks (bandwidth sensitivity, polynomial order sensitivity, placebo cutoffs, covariate balance) should always be reported.
- Software produces valid statistical output regardless of whether the design assumptions hold — the user must assess assumption plausibility.

---

## 14. Domain-Specific Discovery

### What rdrobust reveals that manual analysis cannot easily replicate:

1. **Automatic bias correction**: The robust bias-corrected CI accounts for the bias introduced by local polynomial estimation, something hand-coded approaches typically ignore.
2. **Optimal bandwidth with regularization**: The MSE-optimal bandwidth selection includes regularization for mass points and boundary effects that naive plug-in selectors miss.
3. **Three inference procedures in one call**: Conventional, bias-corrected, and robust inference — allowing researchers to assess sensitivity to inference method immediately.
4. **CR2/CR3 cluster-robust variance**: Bell-McCaffrey and Pustejovsky-Tipton corrections for few-cluster settings that generic clustering approaches don't provide.
5. **Principled bin selection for plots**: rdplot uses IMSE-optimal and mimicking-variance methods (CCT 2015) rather than arbitrary bin counts.

### User Journey Self-Check

Before finalizing your RD analysis, ask yourself:

1. "Is the cutoff value I specified the actual institutional threshold?"
2. "Did I check for sorting/manipulation at the cutoff?"
3. "Am I reporting the robust CI (not conventional)?"
4. "Have I shown robustness to bandwidth and polynomial order?"
5. "If my data is clustered, did I use cluster-robust VCE?"
6. "Does my RD plot visually corroborate the estimated discontinuity?"
7. "Have I checked covariate balance at the cutoff?"
8. "Is my interpretation correctly local (LATE at the cutoff)?"
9. "Have I tested placebo cutoffs to rule out spurious discontinuities?"
10. "Are my results consistent across all three languages (if replication required)?"

---

## 15. Advanced Usage

### 15.1 Covariate-Adjusted Estimation

Following Calonico, Cattaneo, Farrell, and Titiunik (2019, *Review of Economics and Statistics*), covariates can be included to improve efficiency without changing the point estimate (asymptotically).

#### R
```r
library(rdrobust)
data(rdrobust_RDsenate)
y <- rdrobust_RDsenate$vote
x <- rdrobust_RDsenate$margin

# Include pre-treatment covariates for efficiency
# Covariates must be pre-determined (not affected by treatment)
covs <- cbind(rdrobust_RDsenate$class, rdrobust_RDsenate$termshouse)

est_cov <- rdrobust(y = y, x = x, c = 0, covs = covs)
summary(est_cov)

# Compare with baseline (no covariates)
est_base <- rdrobust(y = y, x = x, c = 0)
# Expect: SE with covariates <= SE without covariates
```

#### Python
```python
import numpy as np
from rdrobust import rdrobust

# Prepare covariate matrix
covs = np.column_stack([data['class'].values, data['termshouse'].values])

est_cov = rdrobust(y=y, x=x, c=0, covs=covs)
print(est_cov)
```

#### Stata
```stata
rdrobust vote margin, c(0) covs(class termshouse)
```

**Key properties (CCFT 2019)**:
- Point estimate is asymptotically equivalent (covariates do not affect consistency)
- Standard errors can decrease substantially with good predictive covariates
- Bandwidth selection accounts for covariates
- Collinear covariates are automatically dropped when `covs_drop = TRUE`

---

### 15.2 Cluster-Robust Inference

When observations within clusters (e.g., schools, districts, states) are correlated, standard errors must account for within-cluster dependence.

#### R
```r
# Cluster-robust variance estimation
# cluster_var must be a numeric vector of cluster identifiers
est_cl <- rdrobust(y = y, x = x, c = 0,
                   vce = "cluster", cluster = cluster_var)
summary(est_cl)

# For few clusters, rdrobust provides bias-reduced CRV corrections
# CR2 (Bell-McCaffrey) and CR3 (Pustejovsky-Tipton) are available
```

#### Python
```python
est_cl = rdrobust(y=y, x=x, c=0, vce="cluster", cluster=cluster_var)
print(est_cl)
```

#### Stata
```stata
* Cluster-robust — cluster variable inside vce()
rdrobust vote margin, c(0) vce(cluster state_id)
```

**When to cluster**:
- Data collected at a group level (students within schools)
- Treatment assigned at a cluster level (state-level policy)
- Serial correlation in panel data

---

### 15.3 Sensitivity and Robustness Analysis

A complete RD analysis requires demonstrating robustness to methodological choices.

#### Bandwidth Sensitivity
```r
library(rdrobust)
data(rdrobust_RDsenate)
y <- rdrobust_RDsenate$vote
x <- rdrobust_RDsenate$margin

# Get baseline bandwidth
est <- rdrobust(y = y, x = x, c = 0)
h_opt <- est$bws[1,1]

# Sensitivity grid
multipliers <- c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)
results <- data.frame(mult = multipliers, h = NA, coef = NA,
                      ci_l = NA, ci_r = NA, pv = NA)

for (i in seq_along(multipliers)) {
  h_i <- h_opt * multipliers[i]
  est_i <- rdrobust(y = y, x = x, c = 0, h = h_i)
  results$h[i] <- h_i
  results$coef[i] <- est_i$coef[1]
  results$ci_l[i] <- est_i$ci[3, 1]
  results$ci_r[i] <- est_i$ci[3, 2]
  results$pv[i] <- est_i$pv[3]
}
print(results)
# Results should be qualitatively consistent across bandwidths
```

#### Polynomial Order Sensitivity
```r
# p = 1 (local linear, default)
est_p1 <- rdrobust(y = y, x = x, c = 0, p = 1)

# p = 2 (local quadratic)
est_p2 <- rdrobust(y = y, x = x, c = 0, p = 2)

cat("p=1: coef =", est_p1$coef[1], "CI =", est_p1$ci[3,], "\n")
cat("p=2: coef =", est_p2$coef[1], "CI =", est_p2$ci[3,], "\n")
# Large discrepancy suggests specification sensitivity
```

#### Placebo Cutoff Tests
```r
# Test at non-cutoff points — should find NO effect
placebo_cutoffs <- c(-10, -5, 5, 10)
for (c_placebo in placebo_cutoffs) {
  est_placebo <- rdrobust(y = y, x = x, c = c_placebo)
  cat("Cutoff =", c_placebo, ": coef =", est_placebo$coef[1],
      "p =", est_placebo$pv[3], "\n")
}
# All placebo tests should be insignificant (p > 0.05)
```

#### Donut-Hole Sensitivity
```r
# Exclude observations very close to the cutoff
# Tests robustness to potential manipulation
donut <- 0.5  # Exclude |x - c| < 0.5
y_donut <- y[abs(x) >= donut]
x_donut <- x[abs(x) >= donut]
est_donut <- rdrobust(y = y_donut, x = x_donut, c = 0)
summary(est_donut)
```

---

### 15.4 Diagnostics Embedded in Workflow

#### Density Test (McCrary / rddensity)
```r
library(rddensity)

# Formal density test
dens <- rddensity(X = x, c = 0)
summary(dens)
# Key output:
# T-statistic and p-value for H0: density is continuous at cutoff
# p > 0.05 — no evidence of manipulation
# p < 0.05 — potential manipulation, design may be invalid
```

```python
# Python (rddensity package)
from rddensity import rddensity
dens = rddensity(X=x, c=0)
print(dens)
```

```stata
* Stata
rddensity margin, c(0)
```

#### Covariate Balance Tests
```r
# Test each pre-treatment covariate for jumps at cutoff
covariates <- c("age", "income", "education", "gender")

for (cov_name in covariates) {
  cov_val <- data[[cov_name]]
  est_cov <- rdrobust(y = cov_val, x = x, c = 0)
  cat(cov_name, ": coef =", est_cov$coef[1], ", p =", est_cov$pv[3], "\n")
}
# All covariates should show p > 0.05 (no discontinuity)
```

---

### 15.5 Mass Points Handling

When the running variable is discrete or has tied values:

```r
# Check for mass points
cat("Unique values:", length(unique(x)), "out of", length(x), "\n")

# Default behavior (adjust for mass points)
est_adj <- rdrobust(y = y, x = x, c = 0, masspoints = "adjust")

# Check mode (diagnostic only)
est_check <- rdrobust(y = y, x = x, c = 0, masspoints = "check")

# Turn off (not recommended unless running variable is truly continuous)
est_off <- rdrobust(y = y, x = x, c = 0, masspoints = "off")
```

**Guidelines**:
- If unique(x)/length(x) > 0.9: likely continuous, mass points not a concern
- If unique(x)/length(x) < 0.5: substantial discreteness, `adjust` is critical
- If very few unique values (< 20 per side): RD may not be feasible

---

### 15.6 Output Interpretation Template

When reporting rdrobust results in a paper or report, use this template:

> **RD Estimate**: The local polynomial regression discontinuity estimate indicates a treatment effect of [COEF] (robust 95% CI: [CI_L, CI_R], p = [P_VALUE]). The MSE-optimal bandwidth is h = [H], with [N_L] observations below and [N_R] observations above the cutoff within the bandwidth window. Results are robust to alternative bandwidth choices (0.5h to 2h) and polynomial orders (p = 1, 2). The McCrary density test (p = [DENS_P]) shows no evidence of manipulation. Covariate balance tests confirm no significant discontinuities in pre-treatment variables.

**Template for Fuzzy RD**:
> **Fuzzy RD (LATE) Estimate**: The local Wald (ratio) estimator yields a LATE of [COEF] for compliers at the cutoff (robust 95% CI: [CI_L, CI_R]). The first-stage discontinuity in treatment take-up is [FS_COEF] (p = [FS_P]), indicating [strong/moderate] compliance response. This estimate identifies the causal effect for individuals who change treatment status precisely because they cross the eligibility threshold.

### Methods Write-Up Template

> Adapt the following template for your paper's Methods section. Replace bracketed items with your specifics.

**Sharp RD Template:**

> We estimate a sharp regression discontinuity design at the [variable name] cutoff of [c value] using the local polynomial framework of Calonico, Cattaneo, and Titiunik (2014). The outcome [Y description] is regressed on the running variable [X description], with treatment assigned deterministically when [X ≥ c / X < c]. We implement local linear RD estimators (p = 1) with MSE-optimal bandwidth selection (`bwselect = "mserd"`) and report robust bias-corrected confidence intervals following Calonico, Cattaneo, and Farrell (2020). [If covariates:] Pre-treatment covariates ([list]) enter as efficiency-enhancing controls following Calonico et al. (2019), without changing the estimand. We assess design validity using density tests (Cattaneo, Jansson, and Ma 2020) and covariate balance at the cutoff. Robustness is assessed via bandwidth sensitivity (0.5h–2h), polynomial order variation (p = 1, 2), and placebo cutoff tests.

**Fuzzy RD Template:**

> We estimate a fuzzy regression discontinuity design exploiting the discontinuous jump in [treatment] probability at [cutoff description]. The reduced-form and first-stage discontinuities are estimated via local polynomial methods (Calonico, Cattaneo, and Titiunik 2014), and the local average treatment effect (LATE) at the cutoff is identified as the Wald ratio. We verify the strength of the first stage by confirming a statistically significant jump in treatment probability (p < 0.01). All inference uses robust bias-corrected confidence intervals.

**Citation block (copy-paste for References):**

> Calonico, S., M. D. Cattaneo, and M. H. Farrell (2020). "Optimal Bandwidth Choice for Robust Bias-Corrected Inference in Regression Discontinuity Designs." *Econometrics Journal* 23(2): 192-210.
>
> Calonico, S., M. D. Cattaneo, and R. Titiunik (2014). "Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs." *Econometrica* 82(6): 2295-2326.
>
> Cattaneo, M. D., M. Jansson, and X. Ma (2020). "Simple Local Polynomial Density Estimators." *JASA* 115(531): 1449-1455.

---

## 16. Theoretical Foundations Summary

For complete mathematical derivations, see [method-card.md](./method-card.md).

### Key Theoretical Results

1. **CCT (2014) Theorem 1**: The robust bias-corrected t-statistic converges to \(\mathcal{N}(0,1)\) under regularity conditions, enabling valid inference with MSE-optimal bandwidths.

2. **CCF (2020) Theorem 3.2**: The CE-optimal bandwidth \(h_{\text{CER}} \propto n^{-1/(3+p)}\) minimizes coverage error, achieving rate \(O(n^{-(2+p)/(3+p)})\) — superior to undersmoothing.

3. **CCT (2014) Lemma 1**: The MSE-optimal bandwidth \(h_{\text{MSE}} \propto n^{-1/(2p+3)}\) balances squared bias and variance.

### Convergence Rate Summary

| Component | Rate (p=1) | Interpretation |
|-----------|-----------|----------------|
| MSE-optimal bandwidth | \(n^{-1/5}\) | Bandwidth shrinks slowly; needs moderate sample |
| CER-optimal bandwidth | \(n^{-1/4}\) | Tighter than MSE; better coverage |
| Point estimator bias | \(n^{-2/5}\) | Bias vanishes at this rate |
| Point estimator RMSE | \(n^{-2/5}\) | Optimal rate for local linear |
| RBC coverage error | \(n^{-3/4}\) | Fast convergence to nominal level |
| Conventional coverage error | Does not vanish | CIs remain invalid at MSE bandwidth |

---

## 17. Comparison with Related Methods

| Feature | RD (rdrobust) | IV (ivreg) | DID | Matching |
|---------|--------------|-----------|-----|----------|
| **Identifying assumption** | Continuity at cutoff | Exclusion restriction + relevance | Parallel trends | Conditional independence |
| **Estimand** | LATE at cutoff | LATE for compliers | ATT | ATT/ATE |
| **Scope** | Local (at threshold) | Can be global | Global (over time) | Global (conditional) |
| **Running variable** | Required (continuous score) | Instrument | Time | Covariates |
| **Bandwidth choice** | Critical (data-driven) | Not applicable | Not applicable | Caliper/exact |
| **Key diagnostic** | Density test + covariate balance | First stage F-stat | Pre-trends | Balance table |
| **Extrapolation** | Not valid beyond cutoff | Depends on heterogeneity | Assumes parallel trends hold | Assumes overlap |
| **Software** | `rdrobust` | `ivreg2` / `linearmodels` | `did` / `fixest` | `MatchIt` / `cem` |

**When RD is preferred over alternatives**:
- A clear institutional threshold exists in the assignment mechanism
- The continuity assumption is more credible than parallel trends (DID) or exclusion restriction (IV)
- The policy question is inherently local ("what happens at the margin of eligibility?")

**When alternatives are preferred over RD**:
- No threshold rule exists (use DID or matching)
- Interest in global effects far from cutoff (use IV or DID)
- Manipulation is detected at the cutoff (RD invalid; consider DID or IV)

---

## 18. Example: Kink RD Design

### Scenario: Tax Rate Kink

**Research question**: Does a kink in the marginal tax rate at an income threshold affect labor supply?

**Design**: At the threshold, the tax rate changes slope (not level). This creates a kink in the budget constraint that identifies the elasticity of labor supply.

#### R
```r
library(rdrobust)

# Kink RD: deriv = 1 estimates slope change
# Running variable: taxable income (centered at kink point)
# Outcome: hours worked or earnings

# Estimation with derivative = 1
est_kink <- rdrobust(y = hours, x = income, c = threshold, deriv = 1)
summary(est_kink)

# Note: Kink RD uses p = 2 (local quadratic) by default when deriv = 1
# Bias correction uses q = 3 (local cubic)

# Interpretation: The coefficient represents the change in the slope
# of E[Y|X] at the cutoff. For tax kinks, this identifies the
# compensated elasticity of taxable income.
```

#### Python
```python
from rdrobust import rdrobust

# Kink RD estimation
est_kink = rdrobust(y=hours, x=income, c=threshold, deriv=1)
print(est_kink)
```

#### Stata
```stata
* Kink RD
rdrobust hours income, c(threshold) deriv(1)

* With explicit polynomial order
rdrobust hours income, c(threshold) deriv(1) p(2) q(3)
```

### Key Differences from Level RD

| Feature | Level RD (deriv=0) | Kink RD (deriv=1) |
|---------|-------------------|-------------------|
| Estimand | Jump in level | Jump in slope |
| Default p | 1 (local linear) | 2 (local quadratic) |
| Default q | 2 (local quadratic) | 3 (local cubic) |
| Smoothness needed | \(S \geq 3\) | \(S \geq 4\) |
| Visual check | Jump visible in rdplot | Kink visible (slope change) |
| Power | Generally higher | Generally lower (harder to detect) |

---

## 19. Bandwidth Selection Deep Dive

### Understanding the Bias-Variance Tradeoff

```
Bandwidth h
├── Too small (h → 0)
│   ├── Low bias (good)
│   └── High variance / few observations (bad)
├── Too large (h → ∞)
│   ├── Low variance / many observations (good)
│   └── High bias from polynomial misfit (bad)
└── Optimal h (MSE or CER)
    └── Balances bias² and variance
```

### MSE vs CER: When to Use Which

| Criterion | Use Case | Bandwidth Size | Output Focus |
|-----------|----------|---------------|---------------|
| `mserd` | Default choice; want best point estimate | Larger | Point estimate (\(\hat{\tau}\)) |
| `cerrd` | Want best CI coverage; inference-focused | Smaller (~75% of MSE) | Confidence interval coverage |
| `msetwo` | Asymmetric density around cutoff | Different left/right | Point estimate with asymmetry |
| `certwo` | Asymmetric + inference-focused | Different left/right | CI coverage with asymmetry |

### Practical Guidance

```r
library(rdrobust)
data(rdrobust_RDsenate)
y <- rdrobust_RDsenate$vote
x <- rdrobust_RDsenate$margin

# Compare all bandwidth methods
bw <- rdbwselect(y = y, x = x, c = 0, all = TRUE)
summary(bw)

# Typical output (approximate values for Senate data):
# Method     h (left)   h (right)   b (left)   b (right)
# mserd      16.79      16.79       27.44      27.44
# msetwo     16.40      17.28       28.10      26.85
# cerrd      12.41      12.41       27.44      27.44
# certwo     12.12      12.77       28.10      26.85

# Rule of thumb: CER bandwidth ≈ 0.75 × MSE bandwidth
cat("Ratio CER/MSE:", 12.41 / 16.79, "\n")  # ≈ 0.74
```

### Bandwidth for Bias Estimation (b)

The bias bandwidth `b` is used to estimate the leading bias term:
- Default: `b` is computed as the MSE-optimal bandwidth for the bias estimator
- Typically `b > h` (wider window to estimate derivatives more precisely)
- The ratio \(\rho = h/b\) is bounded; default allows data-driven choice

---

## 20. Output Structure Reference

### R Output Object (`rdrobust` class)

```r
est <- rdrobust(y = y, x = x, c = 0)

# Key components:
est$coef        # Point estimates: [Conventional, Bias-corrected, Robust]
est$se          # Standard errors: [Conventional, Bias-corrected, Robust]
est$z           # z-statistics
est$pv          # p-values: [Conventional, Bias-corrected, Robust]
est$ci          # Confidence intervals: 3x2 matrix (rows = methods, cols = lower/upper)
est$bws         # Bandwidths: [h_left, b_left; h_right, b_right]
est$N_h         # Effective sample size within bandwidth [N_left, N_right]
est$N           # Total sample size [N_left, N_right]
est$tau_cl      # Conventional point estimate
est$tau_bc      # Bias-corrected point estimate

# Accessing the recommended (robust) results:
robust_coef <- est$coef[3]   # or est$coef[1] (same point estimate)
robust_ci_l <- est$ci[3, 1]  # Robust CI lower bound
robust_ci_u <- est$ci[3, 2]  # Robust CI upper bound
robust_pv   <- est$pv[3]     # Robust p-value
```

### Python Output Object

```python
est = rdrobust(y=y, x=x, c=0)

# Key attributes:
est.coef     # Coefficients
est.se       # Standard errors
est.pv       # p-values
est.ci       # Confidence intervals
est.bws      # Bandwidths
est.N_h      # Effective sample sizes
```

### Stata Stored Results

```stata
rdrobust y x, c(0)

* Stored in e():
ereturn list

* Key scalars:
e(tau_cl)      // Conventional estimate
e(tau_bc)      // Bias-corrected estimate
e(h_l)         // Bandwidth left
e(h_r)         // Bandwidth right
e(b_l)         // Bias bandwidth left
e(b_r)         // Bias bandwidth right
e(N_h_l)       // N within bandwidth (left)
e(N_h_r)       // N within bandwidth (right)
e(se_tau_rb)   // Robust standard error
e(pv_rb)       // Robust p-value
e(ci_l_rb)     // Robust CI lower
e(ci_r_rb)     // Robust CI upper
```

---

## 21. Frequently Asked Questions

### Q1: Which row of rdrobust output should I report?

**Answer**: Always report the **Robust** row (row 3). This is the robust bias-corrected inference from CCT (2014) Theorem 1. The conventional row has incorrect coverage with MSE-optimal bandwidths. The bias-corrected row corrects the point estimate but uses the wrong variance formula.

### Q2: Is rdrobust the same as running a local linear regression manually?

**Answer**: The point estimate is the same as a kernel-weighted local linear regression on each side. However, rdrobust provides: (1) optimal bandwidth selection, (2) bias correction, (3) a variance formula that accounts for bias estimation uncertainty. Manual implementations typically lack items (2) and (3), leading to invalid inference.

### Q3: Can I use rdrobust with panel data?

**Answer**: Yes. If you have repeated observations per unit, use clustering: `rdrobust(y, x, cluster = unit_id)`. The running variable should be the assignment variable (not time). If you have a panel RD (e.g., unit crosses cutoff at different times), ensure proper handling of the time dimension.

### Q4: What if my running variable is discrete (e.g., test scores in integers)?

**Answer**: Use `masspoints = "adjust"` (default in recent versions). This adjusts the bandwidth selection to account for mass points. If the running variable has very few unique values (< 20 per side of cutoff), RD may not be feasible — consider alternative identification strategies.

### Q5: How do I test for a placebo effect at non-cutoff points?

**Answer**: Run `rdrobust(y, x, c = c_placebo)` at multiple false cutoff values. Significant effects at non-cutoff points suggest either: (1) the continuity assumption is violated, or (2) there are multiple thresholds in the data. All placebo tests should be insignificant (p > 0.05).

### Q6: Should I use the MSE or CER bandwidth?

**Answer**: 
- **For reporting a point estimate**: use MSE (`bwselect = "mserd"`, the default) — minimizes squared error of the estimate.
- **For inference / CI**: use CER (`bwselect = "cerrd"`) — minimizes coverage error of the confidence interval.
- **In practice**: report MSE as main result, CER as robustness check. Both are valid; CER is more conservative.

### Q7: What sample size do I need for RD?

**Answer**: There is no fixed rule, but guidelines include:
- Effective sample within bandwidth (N_h) should be ≥ 50 per side for reliable inference
- Total sample depends on density near cutoff: even large N may have few observations in the bandwidth window
- Fuzzy RD requires larger samples (due to first-stage division)
- Use the reported N_h to assess whether you have adequate local sample size

### Q8: Can I include time fixed effects with rdrobust?

**Answer**: rdrobust does not directly support fixed effects within the local polynomial regression. Options:
- Include time dummies as covariates via `covs` (linear adjustment)
- Residualize the outcome first: regress Y on time FEs, use residuals in rdrobust
- The covariate adjustment approach (CCFT 2019) is preferred as it is formally justified

### Q9: How do I handle multiple cutoffs?

**Answer**: Options include:
1. **Separate estimation**: Run rdrobust at each cutoff independently
2. **Normalized pooling**: Normalize each running variable by its cutoff (X - c_i), pool data, run rdrobust with c = 0
3. **Cutoff-specific effects**: If treatment varies by cutoff, report heterogeneous effects

The pooled approach assumes a common treatment effect across cutoffs — test this with separate estimates first.

### Q10: What if rdrobust returns a very wide CI?

**Answer**: Wide CIs typically indicate:
- Too few observations near the cutoff (check N_h)
- High outcome variance near the cutoff
- The CER bandwidth is being used (tighter than MSE; try MSE if N_h is adequate)
- Adding predictive covariates (`covs`) can reduce variance and narrow the CI

Do NOT manually narrow the bandwidth to achieve significance — this invalidates the data-driven inference framework.

### Q11: rdrobust() returns NA or fails — what should I do?

**Quick Troubleshooting Checklist:**

1. **Missing values in data**
   - R: `sum(is.na(y)); sum(is.na(x))` — remove NAs before calling rdrobust
     ```r
     complete <- !is.na(y) & !is.na(x)
     est <- rdrobust(y[complete], x[complete], c = 0)
     ```
   - Python: rdrobust does NOT handle NaN — clean first:
     ```python
     mask = ~(np.isnan(y) | np.isnan(x))
     est = rdrobust(y[mask], x[mask], c=0)
     ```
   - Stata: `drop if missing(y) | missing(x)`

2. **Too few observations near cutoff** (N_h very small)
   - Check: `est$N_h` (R), `est.N_h` (Python), `e(N_h_l)`/`e(N_h_r)` (Stata)
   - If N_h < 20 per side: estimates are unreliable; consider wider bandwidth or alternative design

3. **Running variable has very few unique values**
   - Check: `length(unique(x))` (R/Python) or `distinct x` (Stata)
   - If few unique values near cutoff: use `masspoints = "adjust"` and check `bwcheck`

4. **Bandwidth exceeds data support**
   - Verify: `range(x)` vs reported bandwidth `h`
   - If h > half the data range: consider `bwrestrict = TRUE` (default) and check data quality

---

## 22. Version History and API Changes

### R Package Changes (rdrobust)

| Version | Key Change |
|---------|------------|
| ≥ 2.0.0 | `all` moved from `rdrobust()` to `summary()` |
| ≥ 2.1.0 | `masspoints` option added (default: "adjust") |
| ≥ 2.2.0 | CER-optimal bandwidth methods added to `rdbwselect()` |
| ≥ 1.0.0 | `covs_drop` option added for collinear covariates |

### Stata Package Changes

| Version | Key Change |
|---------|------------|
| 2023 update | Mass points handling; improved large-sample performance |
| 2019 update | CER bandwidth methods added |
| 2017 update | Covariate adjustment (CCFT 2019) |

### Python Package

- Python implementation mirrors R API closely
- Arrays must be 1-D numpy arrays
- Return object uses dot notation (est.coef, est.ci) vs R's dollar notation (est$coef, est$ci)

---

## 23. Replication and Reproducibility

### Cross-Language Consistency

All three implementations (R, Python, Stata) should produce identical results within floating-point tolerance:

| Component | Expected Agreement |
|-----------|-------------------|
| Point estimate | Identical to 6+ decimal places |
| Standard errors | Identical to 4+ decimal places |
| Bandwidth h | Identical to 2+ decimal places |
| p-values | Identical to 3+ decimal places |
| N_h (effective sample) | Exactly identical |

### Minimum Reporting Standards

When reporting RD results, always include:

1. **Cutoff value** and institutional justification
2. **Point estimate** with robust CI and p-value
3. **Bandwidth** (h and b) and selection method
4. **Effective sample sizes** (N_h left and right)
5. **Polynomial order** (p) and kernel type
6. **Density test** p-value (from rddensity)
7. **Covariate balance** results (or statement that no covariates are available)
8. **Robustness table**: sensitivity to bandwidth (0.5h to 2h) and polynomial order (p=1, p=2)

### Replication Code Template

```r
# Minimal reproducible RD analysis
library(rdrobust)
library(rddensity)

# Data
data(rdrobust_RDsenate)
y <- rdrobust_RDsenate$vote
x <- rdrobust_RDsenate$margin

# 1. Density test
dens <- rddensity(X = x, c = 0)
cat("Density test p-value:", dens$test$p_jk, "\n")

# 2. Main estimate
est <- rdrobust(y = y, x = x, c = 0)
cat("RD estimate:", est$coef[1], "\n")
cat("Robust CI: [", est$ci[3,1], ",", est$ci[3,2], "]\n")
cat("Robust p:", est$pv[3], "\n")
cat("h =", est$bws[1,1], ", b =", est$bws[1,2], "\n")
cat("N_h: left =", est$N_h[1], ", right =", est$N_h[2], "\n")

# 3. Robustness
est_cer <- rdrobust(y = y, x = x, c = 0, bwselect = "cerrd")
est_p2  <- rdrobust(y = y, x = x, c = 0, p = 2)
est_h50 <- rdrobust(y = y, x = x, c = 0, h = est$bws[1,1] * 0.5)
est_h150 <- rdrobust(y = y, x = x, c = 0, h = est$bws[1,1] * 1.5)

# 4. Visualization
rdplot(y = y, x = x, c = 0, title = "RD Plot")
```
