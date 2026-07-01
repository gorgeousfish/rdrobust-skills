# Example: Kink RD — Tax Schedule and Labor Supply

## Research Question

Does a change in the marginal tax rate at an income bracket threshold affect labor supply? At a tax kink, the *level* of the tax schedule is continuous but the *slope* (marginal rate) changes discontinuously. This creates a kink in the budget constraint that identifies the compensated elasticity of labor supply.

## Design

| Element | Description |
|---------|-------------|
| Running variable | Taxable income (centered at kink) |
| Cutoff | Tax bracket threshold ($50,000) |
| Treatment | Marginal tax rate changes slope (not level) |
| Outcome | Weekly hours worked |
| Estimand | Change in the slope of E[hours \| income] at the kink |
| Key parameter | `deriv = 1` (estimates first derivative discontinuity) |

**Why Kink RD?** At the threshold, the average tax rate is continuous (no jump in take-home pay), but the marginal rate changes. Workers respond to *marginal* incentives, so any behavioral response manifests as a slope change in labor supply with respect to income.

---

## Setup and Data Simulation

We simulate data with a kink at income = $50,000 where the marginal tax rate increases from 22% to 32%, creating a slope change in hours worked.

### R

```r
set.seed(42)
n <- 5000
cutoff <- 50000

# Running variable: taxable income (centered at cutoff)
income_centered <- runif(n, -20000, 20000)
income <- income_centered + cutoff

# Slope of hours worked differs on each side of the kink
# Below kink: slope = -0.0003 hours per dollar
# Above kink: slope = -0.0008 hours per dollar (steeper due to higher marginal rate)
slope_left  <- -0.0003
slope_right <- -0.0008

# Generate outcome: hours worked (base ~40 hours/week)
hours <- ifelse(income_centered < 0,
                40 + slope_left * income_centered,
                40 + slope_right * income_centered) +
         rnorm(n, 0, 2)

# True kink (slope change): slope_right - slope_left = -0.0005
cat("True slope change (kink):", slope_right - slope_left, "\n")
```

### Python

```python
import numpy as np
from rdrobust import rdrobust, rdplot

np.random.seed(42)
n = 5000
cutoff = 50000

income_centered = np.random.uniform(-20000, 20000, n)
income = income_centered + cutoff

slope_left = -0.0003
slope_right = -0.0008

hours = np.where(income_centered < 0,
                 40 + slope_left * income_centered,
                 40 + slope_right * income_centered) + \
        np.random.normal(0, 2, n)

print(f"True slope change (kink): {slope_right - slope_left}")
```

### Stata

```stata
clear
set seed 42
set obs 5000

* Generate running variable
gen income_centered = runiform(-20000, 20000)
gen income = income_centered + 50000

* Generate outcome with kink at cutoff
local slope_left = -0.0003
local slope_right = -0.0008

gen hours = cond(income_centered < 0, ///
    40 + `slope_left' * income_centered, ///
    40 + `slope_right' * income_centered) + rnormal(0, 2)

display "True slope change: " `slope_right' - `slope_left'
```

---

## Kink RD Estimation

The key parameter for kink RD is `deriv = 1`, which estimates the discontinuity in the *first derivative* of the conditional expectation function rather than the level.

### R

```r
library(rdrobust)

# Kink RD estimation: deriv = 1 with local quadratic (p = 2)
est_kink <- rdrobust(y = hours, x = income, c = cutoff, deriv = 1, p = 2)
summary(est_kink)

# Extract results
cat("=== Kink RD: Tax Schedule and Labor Supply ===\n")
cat(sprintf("Slope change estimate (robust): %.6f\n", est_kink$coef[3]))
cat(sprintf("Robust SE: %.6f\n", est_kink$se[3]))
cat(sprintf("Robust 95%% CI: [%.6f, %.6f]\n", est_kink$ci[3,1], est_kink$ci[3,2]))
cat(sprintf("Robust p-value: %.4f\n", est_kink$pv[3]))
cat(sprintf("MSE-optimal bandwidth: %.1f\n", est_kink$bws[1,1]))
cat(sprintf("Effective N: %d (left), %d (right)\n", est_kink$N_h[1], est_kink$N_h[2]))

# Visualization: RD plot for kink (slope change visible)
rdplot(y = hours, x = income, c = cutoff, p = 2,
       title = "Kink RD Plot: Tax Kink and Labor Supply",
       x.label = "Taxable Income ($)",
       y.label = "Weekly Hours Worked")
```

### Python

```python
from rdrobust import rdrobust, rdplot

# Kink RD estimation
est_kink = rdrobust(y=hours, x=income, c=cutoff, deriv=1, p=2)
print(est_kink)

print(f"\n=== Kink RD: Tax Schedule and Labor Supply ===")
print(f"Slope change estimate: {est_kink.coef.iloc[2]:.6f}")
print(f"Robust SE: {est_kink.se.iloc[2]:.6f}")
print(f"Robust 95% CI: [{est_kink.ci.iloc[2,0]:.6f}, {est_kink.ci.iloc[2,1]:.6f}]")
print(f"Robust p-value: {est_kink.pv.iloc[2]:.4f}")
print(f"Bandwidth: {est_kink.bws.iloc[0,0]:.1f}")

# Visualization
rdplot(y=hours, x=income, c=cutoff, p=2,
       title="Kink RD Plot: Tax Kink and Labor Supply",
       x_label="Taxable Income ($)",
       y_label="Weekly Hours Worked")
```

### Stata

```stata
* Kink RD estimation with deriv(1) and p(2)
rdrobust hours income, c(50000) deriv(1) p(2)

* Display key results
display "=== Kink RD: Tax Schedule and Labor Supply ==="
display "Slope change: " %9.6f e(tau_bc)
display "Robust SE: " %9.6f e(se_tau_rb)
display "Robust p-value: " %6.4f e(pv_rb)
display "Bandwidth: " %8.1f e(h_l)

* RD Plot
rdplot hours income, c(50000) p(2) ///
    graph_options(title("Kink RD: Tax Kink and Labor Supply") ///
                  xtitle("Taxable Income ($)") ///
                  ytitle("Weekly Hours Worked"))
```

---

## Output Comparison Table

All three languages produce numerically equivalent results (simulated data, seed = 42):

| Metric | R | Python | Stata |
|--------|---|--------|-------|
| Slope change estimate | ≈ -0.0005 | ≈ -0.0005 | ≈ -0.0005 |
| Robust SE | ≈ 0.0001 | ≈ 0.0001 | ≈ 0.0001 |
| Robust p-value | < 0.001 | < 0.001 | < 0.001 |
| Bandwidth (h) | ~ 10000 | ~ 10000 | ~ 10000 |
| Polynomial order (p) | 2 | 2 | 2 |
| Bias correction order (q) | 3 | 3 | 3 |

> Note: Exact values depend on the random seed and platform. The true slope change is -0.0005.

---

## Interpretation

The `deriv = 1` estimate represents the **discontinuity in the first derivative** (slope) of E[hours | income] at the kink point:

\[
\hat{\tau}_{\text{kink}} = \lim_{x \downarrow c} \hat{\mu}'_+(x) - \lim_{x \uparrow c} \hat{\mu}'_-(x)
\]

- A negative estimate (≈ -0.0005) means the slope of labor supply with respect to income becomes more negative above the kink — workers reduce hours more steeply when facing the higher marginal tax rate.
- Economically: for each additional dollar of income above the kink, workers supply approximately 0.0005 fewer hours per week compared to the response below the kink.
- The **elasticity** can be computed as: `(slope_change / baseline_slope) / (tax_rate_change / (1 - tax_rate))`.

---

## Kink-Specific Diagnostics

### Polynomial Order Sensitivity

For kink RD, higher polynomial orders are recommended. Use `p = 2` as default and check robustness with `p = 3` and `p = 4`.

```r
# Polynomial sensitivity for kink RD
for (p_order in 2:4) {
  est_p <- rdrobust(y = hours, x = income, c = cutoff, deriv = 1, p = p_order)
  cat(sprintf("p = %d: slope_change = %.6f, robust_p = %.4f, h = %.1f\n",
              p_order, est_p$coef[3], est_p$pv[3], est_p$bws[1,1]))
}
# Results should be qualitatively consistent across p = 2, 3, 4
```

### Bandwidth Sensitivity

```r
# Bandwidth sensitivity for kink RD
est_base <- rdrobust(y = hours, x = income, c = cutoff, deriv = 1, p = 2)
h_opt <- est_base$bws[1,1]

cat("=== Bandwidth Sensitivity (Kink RD) ===\n")
for (mult in c(0.5, 0.75, 1.0, 1.25, 1.5, 2.0)) {
  est_i <- rdrobust(y = hours, x = income, c = cutoff, deriv = 1, p = 2,
                    h = h_opt * mult)
  cat(sprintf("h = %.0f (%.2fx): slope = %.6f, p_rb = %.4f\n",
              h_opt * mult, mult, est_i$coef[3], est_i$pv[3]))
}
```

### Slope Visualization

To visually confirm the kink, plot the local polynomial fits on each side and observe the slope change:

```r
# Visual diagnostic: compare slopes on each side
rdplot(y = hours, x = income, c = cutoff, p = 2,
       title = "Slope Change at Tax Kink",
       x.label = "Taxable Income ($)",
       y.label = "Weekly Hours Worked")

# The fitted lines should show a visible change in slope (not level) at the cutoff
# A steeper negative slope on the right indicates labor supply response to higher marginal rate
```

---

## Key Differences from Sharp RD

| Feature | Sharp RD (deriv=0) | Kink RD (deriv=1) |
|---------|-------------------|-------------------|
| Estimand | Jump in level of E[Y\|X] | Jump in slope of E[Y\|X] |
| Minimum polynomial | p = 1 (local linear) | p = 2 (local quadratic) |
| Bias correction order | q = p + 1 = 2 | q = p + 1 = 3 |
| Smoothness requirement | S ≥ 3 | S ≥ 4 |
| Statistical power | Higher | Lower (slope changes harder to detect) |
| Visual signature | Vertical jump in rdplot | Change in slope angle in rdplot |
| Typical application | Eligibility thresholds | Tax kinks, price schedules |

## Recommendations for Kink RD

1. **Always use `deriv = 1`** — this is what distinguishes kink from sharp RD
2. **Use `p = 2` or higher** — local linear (p=1) cannot capture curvature needed for kink estimation
3. **Report sensitivity to p = 2, 3, 4** — kink estimates can be more sensitive to polynomial order than sharp RD
4. **Larger samples needed** — kink effects are harder to detect; ensure N_h ≥ 100 per side
5. **Check for level discontinuity first** — run `rdrobust(y, x, c, deriv=0)` to verify no jump in level exists (a level jump would confound kink interpretation)
