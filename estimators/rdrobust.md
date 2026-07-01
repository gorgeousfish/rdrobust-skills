# rdrobust() — Local Polynomial RD Estimation

## Overview

`rdrobust()` is the core estimation function in the **rdrobust** package. It implements the robust bias-corrected (RBC) inference framework for regression discontinuity designs developed by Calonico, Cattaneo, and Titiunik (2014, *Econometrica*). The function computes local polynomial point estimates of the treatment effect at a known cutoff, constructs bias-corrected estimates, and provides robust confidence intervals that remain valid even when data-driven (MSE-optimal) bandwidths are used.

**Key innovation**: Rather than undersmoothing (using an ad hoc smaller bandwidth to eliminate bias), `rdrobust()` explicitly estimates the leading bias term using a higher-order polynomial, subtracts it, and inflates the variance estimator to account for the additional noise introduced by bias estimation. This yields confidence intervals with correct coverage under MSE-optimal bandwidths.

**When to use**:
- Estimating treatment effects in sharp, fuzzy, or kink RD designs
- When robust inference (valid coverage) is required with data-driven bandwidth selection
- As the main estimation workhorse after visualization with `rdplot()` and bandwidth exploration with `rdbwselect()`

---

## Theoretical Foundation

### Core Paper

Calonico, S., Cattaneo, M. D., and Titiunik, R. (2014). "Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs." *Econometrica*, 82(6): 2295–2326.

### Bias Correction Approach

The standard local polynomial estimator with MSE-optimal bandwidth \(h_{\text{MSE}} \propto n^{-1/5}\) has a non-negligible asymptotic bias of order \(O(h^2)\). Traditional approaches either:
1. Undersmooth (use smaller \(h\)) — sacrifices efficiency, bandwidth choice is ad hoc
2. Ignore the bias — confidence intervals have severe coverage distortions

The RBC approach:
1. Estimate the leading bias using a higher-order polynomial (order \(q > p\)) with pilot bandwidth \(b\)
2. Subtract the estimated bias to form the bias-corrected estimator \(\hat{\tau}^{\text{bc}}\)
3. Use a variance formula that accounts for BOTH the original variance AND the additional variability from bias estimation:

\[
\mathsf{V}_{\text{SRD}}^{\text{bc}}(h, b) = \mathsf{V}_{\text{SRD}}(h) + \mathsf{C}_{\text{SRD}}^{\text{bc}}(h, b)
\]

### Asymptotic Normality (Theorem 1, CCT 2014)

Under regularity conditions (smoothness \(S \geq 3\), \(n\min\{h^5, b^5\}\max\{h^2, b^2\} \to 0\), \(n\min\{h, b\} \to \infty\)):

\[
T_{\text{SRD}}^{\text{rbc}}(h, b) = \frac{\hat{\tau}_{\text{SRD}}^{\text{bc}}(h, b) - \tau_{\text{SRD}}}{\sqrt{\mathsf{V}_{\text{SRD}}^{\text{bc}}(h, b)}} \to_d \mathcal{N}(0, 1)
\]

This validates inference using the MSE-optimal bandwidth — the "Robust" row in the output table.

### Consistency Under MSE-Optimal or CER-Optimal Bandwidth

- **MSE-optimal** (\(h \propto n^{-1/5}\)): minimizes mean squared error of point estimate (Theorem 3/Lemma 1, CCT 2014)
- **CER-optimal** (\(h \propto n^{-1/4}\)): minimizes coverage error of confidence interval (Theorem 3.2, CCF 2020)

Both are valid for robust inference. CER-optimal produces narrower windows and better coverage properties.

---

## Estimand

### Sharp RD

\[
\tau_{\text{SRD}} = \mathbb{E}[Y_i(1) - Y_i(0) \mid X_i = c] = \lim_{x \downarrow c}\mathbb{E}[Y \mid X=x] - \lim_{x \uparrow c}\mathbb{E}[Y \mid X=x]
\]

Interpretation: Average treatment effect at the cutoff (ATE for units at \(X = c\)).

### Fuzzy RD

\[
\tau_{\text{FRD}} = \frac{\lim_{x\downarrow c}\mathbb{E}[Y \mid X=x] - \lim_{x\uparrow c}\mathbb{E}[Y \mid X=x]}{\lim_{x\downarrow c}\mathbb{E}[T \mid X=x] - \lim_{x\uparrow c}\mathbb{E}[T \mid X=x]}
\]

Interpretation: Local average treatment effect (LATE) for compliers at the cutoff.

### Kink RD (deriv = 1)

\[
\tau_{\text{KRD}} = \lim_{x\downarrow c}\mu_+^{(1)}(x) - \lim_{x\uparrow c}\mu_-^{(1)}(x)
\]

Interpretation: Change in the slope (first derivative) of the regression function at the cutoff.

---

## Parameters (Complete)

### Required

| Parameter | Type | Description |
|-----------|------|-------------|
| `y` | numeric vector/array | Dependent (outcome) variable |
| `x` | numeric vector/array | Running (forcing/score) variable |

### Cutoff & Design

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `c` | numeric scalar | 0 | RD cutoff value |
| `fuzzy` | numeric vector/varname | NULL/None | Treatment status variable for fuzzy RD design |
| `deriv` | integer | 0 | Order of derivative of the regression function to estimate (0 = level, 1 = kink) |

### Polynomial Orders

| Parameter | Type | Default | Constraint | Description |
|-----------|------|---------|------------|-------------|
| `p` | integer | 1 | \(p \geq 0\) | Order of the local polynomial for point estimation |
| `q` | integer | p + 1 | \(q > p\) | Order of the local polynomial for bias correction |

### Bandwidth

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `h` | numeric scalar or vector(2) | auto (via `bwselect`) | Main bandwidth for point estimation. If vector(2), specifies (left, right) separately |
| `b` | numeric scalar or vector(2) | auto (via `bwselect`) | Pilot bandwidth for bias estimation |
| `rho` | numeric scalar | 0 (ignored) | If > 0, sets \(b = h/\rho\). Overrides `b` |
| `bwselect` | string | "mserd" | Bandwidth selection method. Options: `mserd`, `msetwo`, `msesum`, `msecomb1`, `msecomb2`, `cerrd`, `certwo`, `cersum`, `cercomb1`, `cercomb2` |
| `scaleregul` | numeric | 1 | Scaling factor for regularization term in bandwidth selection |
| `bwcheck` | integer | NULL/None/0 | Minimum number of unique observations required within bandwidth |
| `bwrestrict` | logical/bool | TRUE/True | Restrict bandwidth to range of running variable |
| `sharpbw` | logical/bool | FALSE/False | Use sharp RD bandwidth in fuzzy design |

### Kernel

| Parameter | Type | Default | Options | Description |
|-----------|------|---------|---------|-------------|
| `kernel` | string | "tri" | `tri` (triangular), `epa` (Epanechnikov), `uni` (uniform) | Kernel function for local polynomial fitting. Triangular is MSE-optimal |

### Inference

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `vce` | string | "nn" | Variance-covariance estimator: `nn` (nearest-neighbor), `hc0`, `hc1`, `hc2`, `hc3`, `cluster` |
| `cluster` | vector/varname | NULL/None | Cluster ID variable for cluster-robust inference |
| `nnmatch` | integer | 3 | Minimum number of neighbors for nearest-neighbor variance estimator |
| `level` | numeric | 95 | Confidence level (%) for interval construction |
| `scalepar` | numeric | 1 | Scaling factor for the RD parameter of interest |

### Covariates

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `covs` | matrix/formula/varlist | NULL/None | Pre-treatment covariates for efficiency improvement (CCFT 2019) |
| `covs_drop` | logical/bool | TRUE/True | Automatically drop collinear covariates |

### Advanced / Diagnostics

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `weights` | numeric vector/varname | NULL/None | Observation-level weights |
| `masspoints` | string | "adjust" | Mass points handling: `adjust` (modify VCE), `check` (warn only), `off` (ignore) |
| `stdvars` | logical/bool | TRUE/True | Standardize x and y for bandwidth selection computations |
| `subset` | logical/index vector | NULL/None | Subset of observations to use |
| `data` | data.frame/DataFrame | NULL/None | Optional data frame (R/Python only) |
| `all` | logical/bool/flag | NULL/None | Report all three estimation methods (Python/Stata) |

### Platform-Specific

| Parameter | Platform | Description |
|-----------|----------|-------------|
| `ginv.tol` | R only | Tolerance for generalized matrix inversion (default: 1e-20) |
| `nochecks` | Stata only | Skip input validation |
| `nowarnings` | Stata only | Suppress warning messages |
| `detail` | Stata only | Print detailed output |
| `vleverage` | Stata only | Show leverage diagnostics |
| `PRECision` | Stata only | Numeric precision control |

---

## Usage Patterns

### Sharp RD (Basic)

```r
# R
library(rdrobust)
out <- rdrobust(y, x, c = 0)
summary(out)
```

```python
# Python
from rdrobust import rdrobust
out = rdrobust(y, x, c = 0)
print(out)
```

```stata
* Stata
rdrobust y x, c(0)
```

### Fuzzy RD

```r
# R
out <- rdrobust(y, x, fuzzy = treatment, c = 0)
summary(out)
```

```python
# Python
out = rdrobust(y, x, fuzzy = treatment, c = 0)
print(out)
```

```stata
* Stata
rdrobust y x, c(0) fuzzy(treatment)
```

### Kink RD

```r
# R
out <- rdrobust(y, x, deriv = 1, c = 0)
summary(out)
```

```python
# Python
out = rdrobust(y, x, deriv = 1, c = 0)
print(out)
```

```stata
* Stata
rdrobust y x, c(0) deriv(1)
```

### With Covariates (Efficiency Gain)

```r
# R
out <- rdrobust(y, x, covs = cbind(z1, z2), c = 0)
summary(out)
```

```python
# Python
import numpy as np
covs_matrix = np.column_stack([z1, z2])
out = rdrobust(y, x, covs = covs_matrix, c = 0)
print(out)
```

```stata
* Stata
rdrobust y x, c(0) covs(z1 z2)
```

### With Clustering

```r
# R
out <- rdrobust(y, x, cluster = cluster_id, vce = "cluster", c = 0)
summary(out)
```

```python
# Python
out = rdrobust(y, x, cluster = cluster_id, vce = "cluster", c = 0)
print(out)
```

```stata
* Stata
rdrobust y x, c(0) vce(cluster cluster_id)
```

### Manual Bandwidth Specification

```r
# R — symmetric bandwidth
out <- rdrobust(y, x, h = 10, c = 0)

# R — asymmetric bandwidth
out <- rdrobust(y, x, h = c(8, 12), c = 0)
```

```python
# Python — symmetric
out = rdrobust(y, x, h = 10, c = 0)

# Python — asymmetric
out = rdrobust(y, x, h = [8, 12], c = 0)
```

```stata
* Stata — symmetric
rdrobust y x, c(0) h(10)

* Stata — asymmetric
rdrobust y x, c(0) h(8 12)
```

### CER-Optimal Bandwidth for Better Coverage

```r
# R
out <- rdrobust(y, x, c = 0, bwselect = "cerrd")
summary(out)
```

```python
# Python
out = rdrobust(y, x, c = 0, bwselect = "cerrd")
print(out)
```

```stata
* Stata
rdrobust y x, c(0) bwselect(cerrd)
```

### Higher-Order Polynomial with Custom Kernel

```r
# R — local quadratic with Epanechnikov kernel
out <- rdrobust(y, x, p = 2, q = 3, kernel = "epa", c = 0)
summary(out)
```

```python
# Python
out = rdrobust(y, x, p = 2, q = 3, kernel = "epa", c = 0)
print(out)
```

```stata
* Stata
rdrobust y x, c(0) p(2) q(3) kernel(epa)
```

---

## Weighted RD Estimation

The `weights` parameter allows observation-level weights in RD estimation. This is useful for survey data (probability weights) or frequency-weighted datasets.

### When to Use Weights

| Use Case | Appropriate | Example |
|----------|-------------|----------|
| Survey sampling weights | Yes | Inverse probability weights from complex survey design |
| Frequency weights (aggregated data) | Yes | Cell means with counts as weights |
| Population representativeness | Yes | Reweighting to target population |
| "Making results significant" | **Never** | P-hacking via selective weighting |
| Outcome-driven reweighting | **Never** | Weights that depend on Y |

### How Weights Interact with Bandwidth Selection

- Weights enter the local polynomial objective function: heavier-weighted observations exert more influence on the fit
- Bandwidth selection accounts for weights (MSE-optimal h changes with weighting)
- The effective sample size (N_h) reflects weighted counts
- Kernel weights and observation weights multiply: final weight = kernel(x) × user_weight

### R

```r
library(rdrobust)

# Survey-weighted RD estimation
est_weighted <- rdrobust(y = y, x = x, c = 0, weights = survey_weights)
summary(est_weighted)

# Compare weighted vs unweighted
est_unweighted <- rdrobust(y = y, x = x, c = 0)
cat("Unweighted estimate:", est_unweighted$coef[3], "\n")
cat("Weighted estimate:", est_weighted$coef[3], "\n")
```

### Python

```python
from rdrobust import rdrobust

# Survey-weighted RD
est_weighted = rdrobust(y=y, x=x, c=0, weights=survey_weights)
print(est_weighted)
```

### Stata

```stata
* Survey-weighted RD estimation
rdrobust y x, c(0) weights(survey_wt)
```

### Practical Guidance

1. **Always report both weighted and unweighted** — large discrepancies warrant investigation
2. **Document the source of weights** — sampling frame, calibration method, or frequency counts
3. **Weights must be pre-determined** — never construct weights using the outcome or post-treatment variables
4. **Density test with weights** — run `rddensity` with the same weights to check manipulation in the weighted sample

---

## Return Object Interpretation

The output object contains three estimation approaches reported in the summary table:

| Row | Name | Point Estimate | Standard Error | CI | When to Use |
|-----|------|---------------|----------------|-----|-------------|
| 1 | **Conventional** | \(\hat{\tau}(h)\) | \(\sqrt{\hat{V}(h)}\) | Based on conventional SE | NOT recommended (invalid coverage with MSE-optimal h) |
| 2 | **Bias-Corrected** | \(\hat{\tau}^{bc}(h,b)\) | \(\sqrt{\hat{V}(h)}\) | Uses BC estimate, conventional SE | NOT recommended (underestimates variability) |
| 3 | **Robust** | \(\hat{\tau}^{bc}(h,b)\) | \(\sqrt{\hat{V}^{bc}(h,b)}\) | Uses BC estimate, robust SE | **RECOMMENDED** (valid coverage) |

### Key Output Elements

| Element | R Access | Python Access | Stata Access | Description |
|---------|----------|--------------|--------------|-------------|
| Point estimates | `$coef` | `.coef` | `e(b)` | Vector of [Conventional, Bias-Corrected, Robust] coefficients |
| Standard errors | `$se` | `.se` | `e(se_tau_cl)`, `e(se_tau_rb)` | SE for each method |
| p-values | `$pv` | `.pv` | `e(pv_cl)`, `e(pv_rb)` | Two-sided p-values |
| Confidence intervals | `$ci` | `.ci` | `e(ci)` matrix | CI bounds for each method |
| Bandwidths | `$bws` | `.bws` | `e(h_l)`, `e(h_r)`, `e(b_l)`, `e(b_r)` | Matrix: rows = (h, b), cols = (left, right) |
| Sample size (total) | `$N` | `.N` | `e(N_l)`, `e(N_r)` | Total observations [left, right] |
| Sample size (effective) | `$N_h` | `.N_h` | `e(N_h_l)`, `e(N_h_r)` | Observations within bandwidth h |
| Bias estimates | `$bias` | `.bias` | `e(bias_l)`, `e(bias_r)` | Estimated leading bias [left, right] |
| Polynomial coefs (left) | `$beta_Y_p_l` | `.beta_p_l` | `e(beta_Y_p_l)` | Left-side polynomial coefficients |
| Polynomial coefs (right) | `$beta_Y_p_r` | `.beta_p_r` | `e(beta_Y_p_r)` | Right-side polynomial coefficients |
| VCE matrix (conventional) | `$V_cl_l`, `$V_cl_r` | `.V_cl_l`, `.V_cl_r` | `e(V_cl_l)`, `e(V_cl_r)` | Conventional VCE matrices |
| VCE matrix (robust) | `$V_rb_l`, `$V_rb_r` | `.V_rb_l`, `.V_rb_r` | `e(V_rb_l)`, `e(V_rb_r)` | Robust VCE matrices |

### Fuzzy-Specific Output

| Element | Access (R) | Description |
|---------|-----------|-------------|
| First-stage coefficient | `$tau_T` | Treatment discontinuity at cutoff |
| First-stage SE | `$se_T` | Standard error of first stage |
| First-stage z-stat | `$z_T` | z-statistic for first stage |
| First-stage p-value | `$pv_T` | p-value for first stage relevance |
| First-stage CI | `$ci_T` | Confidence interval for first stage |
| First-stage poly coefs | `$beta_T_p_l`, `$beta_T_p_r` | Treatment polynomial coefficients |

---

## Key Methodological Choices

### Polynomial Order (p)

| Order | Name | Bias | Variance | When to Use |
|-------|------|------|----------|-------------|
| p = 0 | Local constant | High (Nadaraya-Watson) | Low | Rarely recommended; boundary bias issues |
| p = 1 | Local linear | Moderate (default) | Moderate | **Default choice**; adapts to boundary, MSE-optimal |
| p = 2 | Local quadratic | Low | Higher | When local linear shows sensitivity; kink RD needs p ≥ 2 |
| p = 3 | Local cubic | Very low | High | Rarely needed; check robustness |

**Recommendation**: Start with `p = 1` (default). Report `p = 2` as robustness check.

### Bandwidth (h)

| Method | Rate | Property | `bwselect` value |
|--------|------|----------|-----------------|
| MSE-optimal (common) | \(n^{-1/5}\) | Minimizes MSE of point estimate | `"mserd"` (default) |
| MSE-optimal (two) | \(n^{-1/5}\) | Separate left/right bandwidths | `"msetwo"` |
| CER-optimal (common) | \(n^{-1/4}\) | Minimizes coverage error of CI | `"cerrd"` |
| CER-optimal (two) | \(n^{-1/4}\) | Separate left/right, coverage-optimal | `"certwo"` |

**Key insight**: CER bandwidth ≈ MSE bandwidth × \(n^{-p/((2p+3)(p+3))}\), yielding a narrower window with better coverage properties.

### Kernel

| Kernel | Shape | Weights | Optimality |
|--------|-------|---------|------------|
| `"tri"` (triangular) | Linear decay | Higher weight to obs near cutoff | **MSE-optimal** (default) |
| `"epa"` (Epanechnikov) | Quadratic decay | Moderate weighting | Efficient but not boundary-optimal |
| `"uni"` (uniform) | Flat | Equal weight within bandwidth | Maximum effective sample; higher bias |

**Recommendation**: Use `"tri"` (default) unless there is a specific reason to prefer uniform weighting.

### Variance-Covariance Estimator (VCE)

| Method | Description | When to Use |
|--------|-------------|-------------|
| `"nn"` | Nearest-neighbor (default) | Standard RD; robust to heteroskedasticity; uses `nnmatch` closest observations |
| `"hc0"` | White heteroskedasticity-robust | When NN is too conservative |
| `"hc1"` | HC1 (degrees-of-freedom correction) | Small-sample adjustment |
| `"hc2"` | HC2 (leverage correction) | More precise small-sample correction |
| `"hc3"` | HC3 (jackknife-like) | Most conservative HC variant |
| `"cluster"` | Cluster-robust | When observations are clustered (e.g., by school, district) |

**Recommendation**: Use `"nn"` (default) for most applications. Switch to `"cluster"` when the running variable has a group structure.

---

## Relationship to Other Functions

### rdrobust() ← rdbwselect()

`rdbwselect()` computes data-driven bandwidths that feed into `rdrobust()`. When `h` is not manually specified, `rdrobust()` internally calls the bandwidth selection procedure specified by `bwselect`.

```r
# Explicit workflow
bw <- rdbwselect(y, x, c = 0)
h_opt <- bw$bws[1, 1]  # MSE-optimal h (left = right for "mserd")
out <- rdrobust(y, x, c = 0, h = h_opt)
```

### rdrobust() + rdplot()

`rdplot()` provides visualization that complements `rdrobust()` estimation. **Critical**: `rdplot()` uses IMSE-optimal binning for visualization, which is a DIFFERENT optimization from the MSE-optimal bandwidth used by `rdrobust()` for point estimation. They should not be conflated.

```r
# Complete workflow
rdplot(y, x, c = 0)                    # Visualize
out <- rdrobust(y, x, c = 0)           # Estimate
summary(out)                            # Inference (use "Robust" row)
```

---

## Common Pitfalls

1. **Using "Conventional" CI**: The conventional confidence interval has incorrect coverage when MSE-optimal bandwidth is used. Always report the **Robust** row.

2. **Conflating rdplot bins with rdrobust bandwidth**: The optimal number of bins for visualization (rdplot) has no direct relationship to the optimal bandwidth for estimation (rdrobust).

3. **Ignoring mass points**: When the running variable has mass points (repeated values), the default `masspoints = "adjust"` modifies the VCE. Set to `"off"` only if you are certain mass points are not a concern.

4. **Wrong polynomial for kink RD**: Kink RD (`deriv = 1`) requires at minimum `p = 1` and uses the first derivative. The bias correction order is `q = p + 1`.

5. **Weak first stage in fuzzy RD**: Always check `$tau_T` and its significance. A small or insignificant first stage leads to unreliable fuzzy RD estimates (analogous to weak instruments in IV).

---

## References

- Calonico, S., Cattaneo, M. D., and Titiunik, R. (2014). "Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs." *Econometrica*, 82(6): 2295–2326.
- Calonico, S., Cattaneo, M. D., and Farrell, M. H. (2020). "Optimal Bandwidth Choice for Robust Bias-Corrected Inference in Regression Discontinuity Designs." *Econometrics Journal*, 23(2): 192–210.
- Calonico, S., Cattaneo, M. D., Farrell, M. H., and Titiunik, R. (2019). "Regression Discontinuity Designs Using Covariates." *Review of Economics and Statistics*, 101(3): 442–451.

---

*See also*: [rdbwselect.md](rdbwselect.md) for bandwidth selection details | [rdplot.md](rdplot.md) for visualization
