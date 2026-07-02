# rdbwselect() — Data-Driven Bandwidth Selection

## Overview

`rdbwselect()` implements data-driven bandwidth selection procedures for local polynomial regression discontinuity estimators. It computes optimal bandwidths under two families of criteria: MSE-optimal (minimizing mean squared error of the point estimate) and CER-optimal (minimizing coverage error rate of the confidence interval). The function is the analytical engine behind `rdrobust()`'s automatic bandwidth choice and can also be called standalone for bandwidth exploration and sensitivity analysis.

**Key innovation**: Beyond the standard MSE-optimal bandwidth (CCT 2014), `rdbwselect()` implements the coverage error rate (CER)-optimal bandwidth from Calonico, Cattaneo, and Farrell (2020, *Econometrics Journal*), which explicitly targets confidence interval performance rather than point estimate accuracy.

**When to use**:
- To explore how different bandwidth criteria affect the bandwidth choice
- To compare MSE-optimal vs CER-optimal bandwidths
- To assess sensitivity of results to bandwidth choice
- To pre-compute bandwidths before calling `rdrobust()` with a manual `h`
- When reporting robustness across multiple bandwidth selection methods

---

## Theoretical Foundation

### Core Papers

- Calonico, S., Cattaneo, M. D., and Titiunik, R. (2014). "Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs." *Econometrica*, 82(6): 2295–2326. [MSE-optimal bandwidth]
- Calonico, S., Cattaneo, M. D., and Farrell, M. H. (2020). "Optimal Bandwidth Choice for Robust Bias-Corrected Inference in Regression Discontinuity Designs." *Econometrics Journal*, 23(2): 192–210. [CER-optimal bandwidth]

### MSE-Optimal Bandwidth

The MSE of the local polynomial RD estimator of order \(p\) decomposes as:

\[
\text{MSE}(h) = h^{2(p+1)} \cdot \mathcal{B}^2 + \frac{1}{nh} \cdot \mathcal{V} + o_p(h^{2(p+1)}) + o_p\left(\frac{1}{nh}\right)
\]

Minimizing over \(h\) yields the MSE-optimal bandwidth:

\[
h_{\text{MSE}} = \left(\frac{\mathcal{V}}{2(p+1)\mathcal{B}^2}\right)^{1/(2p+3)} \cdot n^{-1/(2p+3)}
\]

For the default local-linear case (\(p = 1\)):

\[
h_{\text{MSE}} \propto n^{-1/5}
\]

where:
- \(\mathcal{B}\) = leading bias, depending on \((p+1)\)-th derivatives of \(\mu_+(x)\) and \(\mu_-(x)\)
- \(\mathcal{V}\) = asymptotic variance, depending on conditional variances \(\sigma_\pm^2\) and density \(f(c)\)

### CER-Optimal Bandwidth

The coverage error of the RBC confidence interval with bandwidth \(h\) is:

\[
\mathbb{P}[\tau \in I_{\text{RBC}}(h)] - (1-\alpha) = \frac{1}{nh}\mathcal{Q}_1 + nh^{5+2p}\mathcal{Q}_2 + h^{2+p}\mathcal{Q}_3 + \epsilon
\]

Minimizing coverage error yields the CER-optimal bandwidth:

\[
h_{\text{CER}} = \mathcal{H} \cdot n^{-1/(3+p)}
\]

For \(p = 1\):

\[
h_{\text{CER}} \propto n^{-1/4}
\]

### Key Insight: CER ≈ Shrunken MSE

The CER-optimal bandwidth relates to the MSE-optimal bandwidth through:

\[
h_{\text{CER}} \approx h_{\text{MSE}} \times n^{-p/((2p+3)(p+3))}
\]

For \(p = 1\) and \(n = 500\): the CER bandwidth is approximately 27% narrower than the MSE bandwidth.

**Implication**: CER-optimal uses fewer observations but delivers confidence intervals with better coverage properties. The trade-off is a wider confidence interval (higher variance) but more honest coverage.

---

## Bandwidth Selection Criteria

### MSE-Optimal Family

| Criterion | `bwselect` value | Description | When to Use |
|-----------|-----------------|-------------|-------------|
| MSE-RD (common) | `"mserd"` | Common MSE-optimal bandwidth (same left & right) | **Default**; standard sharp/fuzzy RD |
| MSE-Two | `"msetwo"` | Separate MSE-optimal bandwidths (left ≠ right) | When asymmetry in data density or curvature is expected |
| MSE-Sum | `"msesum"` | MSE-optimal based on sum of left and right MSEs | Alternative aggregation method |
| MSE-Comb1 | `"msecomb1"` | Minimum of `mserd` and `msetwo` | Conservative choice (takes smaller bandwidth) |
| MSE-Comb2 | `"msecomb2"` | Median of `mserd`, `msetwo`, `msesum` | Robust alternative (median of three) |

### CER-Optimal Family

| Criterion | `bwselect` value | Description | When to Use |
|-----------|-----------------|-------------|-------------|
| CER-RD (common) | `"cerrd"` | Common CER-optimal bandwidth | When CI coverage is the primary concern |
| CER-Two | `"certwo"` | Separate CER-optimal bandwidths (left ≠ right) | Asymmetric case, coverage-focused |
| CER-Sum | `"cersum"` | CER-optimal based on sum criterion | Alternative aggregation |
| CER-Comb1 | `"cercomb1"` | Minimum of `cerrd` and `certwo` | Conservative coverage-optimal |
| CER-Comb2 | `"cercomb2"` | Median of `cerrd`, `certwo`, `cersum` | Robust coverage-optimal |

---

## MSE vs CER: When to Use Which

| Criterion | Optimizes | Bandwidth Size | CI Width | Coverage | Best For |
|-----------|-----------|---------------|----------|----------|----------|
| **MSE-optimal** | Point estimate accuracy | Larger (\(n^{-1/5}\)) | Narrower | May under-cover | Reporting point estimates; maximizing power |
| **CER-optimal** | CI coverage accuracy | Smaller (\(n^{-1/4}\)) | Wider | Closer to nominal | Honest inference; when coverage matters most |

### Decision Guide

1. **Primary analysis**: Use `"mserd"` (default) for the main specification. This gives the best point estimate and is standard in the literature.

2. **Coverage-focused inference**: Use `"cerrd"` when the primary goal is a confidence interval with correct coverage (e.g., when reporting that "the effect is between X and Y with 95% confidence").

3. **Robustness check**: Report both `"mserd"` and `"cerrd"` results to show sensitivity. Also consider `"msetwo"` to check for left-right asymmetry.

4. **Small samples**: CER-optimal may be preferred as it provides more honest coverage when sample sizes are limited and bias may be substantial.

5. **Asymmetric designs**: Use `"msetwo"` or `"certwo"` when the running variable distribution or regression function curvature differs substantially on each side of the cutoff.

---

## Parameters (Complete)

### Required

| Parameter | Type | Description |
|-----------|------|-------------|
| `y` | numeric vector/array | Dependent (outcome) variable |
| `x` | numeric vector/array | Running (forcing/score) variable |

### Design

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `c` | numeric scalar | 0 | RD cutoff value |
| `fuzzy` | numeric vector/varname | NULL/None | Treatment status variable for fuzzy RD |
| `deriv` | integer | 0 | Derivative order (0 = level, 1 = kink) |

### Polynomial Orders

| Parameter | Type | Default | Constraint | Description |
|-----------|------|---------|------------|-------------|
| `p` | integer | 1 | \(p \geq 0\) | Order of local polynomial for point estimation |
| `q` | integer | p + 1 | \(q > p\) | Order of local polynomial for bias estimation |

### Bandwidth Selection

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `bwselect` | string | "mserd" | Bandwidth criterion. Options: `mserd`, `msetwo`, `msesum`, `msecomb1`, `msecomb2`, `cerrd`, `certwo`, `cersum`, `cercomb1`, `cercomb2` |
| `all` | logical/bool/flag | NULL/None | Report ALL bandwidth criteria simultaneously |
| `scaleregul` | numeric | 1 | Scaling factor for the regularization term (stabilizes bandwidth when estimated bias is small) |
| `bwcheck` | integer | NULL/None/0 | Minimum number of unique observations required within bandwidth |
| `bwrestrict` | logical/bool | TRUE/True | Restrict bandwidth to not exceed range of running variable |
| `stdvars` | logical/bool | TRUE/True | Standardize x and y internally for numerical stability |
| `sharpbw` | logical/bool | FALSE/False | Use sharp RD bandwidth formula even in fuzzy design |

### Kernel & VCE

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `kernel` | string | "tri" | Kernel function: `tri` (triangular), `epa` (Epanechnikov), `uni` (uniform) |
| `vce` | string | "nn" | Variance estimator: `nn`, `hc0`, `hc1`, `hc2`, `hc3`; use `cluster` param for cluster-robust |
| `cluster` | vector/varname | NULL/None | Cluster ID variable |
| `nnmatch` | integer | 3 | Minimum neighbors for nearest-neighbor variance estimation |

### Covariates

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `covs` | matrix/formula/varlist | NULL/None | Pre-treatment covariates |
| `covs_drop` | logical/bool | TRUE/True | Drop collinear covariates |

### Advanced

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `weights` | numeric vector/varname | NULL/None | Observation weights |
| `masspoints` | string | "adjust" | Mass points handling: `adjust`, `check`, `off` |
| `subset` | logical/index vector | NULL/None | Subset of observations |
| `data` | data.frame/DataFrame | NULL/None | Optional data frame (R/Python only) |

### Platform-Specific

| Parameter | Platform | Description |
|-----------|----------|-------------|
| `ginv.tol` | R only | Matrix inversion tolerance (default: 1e-20) |
| `prchk` | Python only | Print diagnostic checks (default: True) |
| `nochecks` | Stata only | Skip input validation |
| `PRECision` | Stata only | Numeric precision control |

---

## Usage Patterns

### Basic Usage (Default MSE-Optimal)

```r
# R
library(rdrobust)
bw <- rdbwselect(y, x, c = 0)
summary(bw)
```

```python
# Python
from rdrobust import rdbwselect
bw = rdbwselect(y, x, c = 0)
print(bw)
```

```stata
* Stata
rdbwselect y x, c(0)
```

### Compare All Bandwidth Criteria

```r
# R
bw_all <- rdbwselect(y, x, c = 0, all = TRUE)
summary(bw_all)
```

```python
# Python
bw_all = rdbwselect(y, x, c = 0, all = True)
print(bw_all)
```

```stata
* Stata
rdbwselect y x, c(0) all
```

### CER-Optimal Bandwidth

```r
# R
bw_cer <- rdbwselect(y, x, c = 0, bwselect = "cerrd")
summary(bw_cer)
```

```python
# Python
bw_cer = rdbwselect(y, x, c = 0, bwselect = "cerrd")
print(bw_cer)
```

```stata
* Stata
rdbwselect y x, c(0) bwselect(cerrd)
```

### Separate Left/Right Bandwidths

```r
# R
bw_two <- rdbwselect(y, x, c = 0, bwselect = "msetwo")
summary(bw_two)
```

```python
# Python
bw_two = rdbwselect(y, x, c = 0, bwselect = "msetwo")
print(bw_two)
```

```stata
* Stata
rdbwselect y x, c(0) bwselect(msetwo)
```

### Fuzzy RD Bandwidth

```r
# R
bw_fuzzy <- rdbwselect(y, x, fuzzy = treatment, c = 0)
summary(bw_fuzzy)
```

```python
# Python
bw_fuzzy = rdbwselect(y, x, fuzzy = treatment, c = 0)
print(bw_fuzzy)
```

```stata
* Stata
rdbwselect y x, c(0) fuzzy(treatment)
```

### With Covariates

```r
# R
bw_cov <- rdbwselect(y, x, covs = cbind(z1, z2), c = 0)
summary(bw_cov)
```

```python
# Python
import numpy as np
bw_cov = rdbwselect(y, x, covs = np.column_stack([z1, z2]), c = 0)
print(bw_cov)
```

```stata
* Stata
rdbwselect y x, c(0) covs(z1 z2)
```

### Higher-Order Polynomial

```r
# R — local quadratic (p = 2)
bw_p2 <- rdbwselect(y, x, p = 2, q = 3, c = 0)
summary(bw_p2)
```

```python
# Python
bw_p2 = rdbwselect(y, x, p = 2, q = 3, c = 0)
print(bw_p2)
```

```stata
* Stata
rdbwselect y x, c(0) p(2) q(3)
```

---

## Return Object

### R Return Structure

The function returns a list object of class `"rdbwselect"` with:

| Element | Access | Description |
|---------|--------|-------------|
| `bws` | `$bws` | Matrix of bandwidth values. Rows: selection criteria. Columns: h (left), h (right), b (left), b (right) |
| `bwselect` | `$bwselect` | String identifying the bandwidth method used |
| `kernel` | `$kernel` | Kernel type |
| `p` | `$p` | Polynomial order |
| `q` | `$q` | Bias polynomial order |
| `c` | `$c` | Cutoff value |
| `N` | `$N` | Total sample size [left, right] |
| `N_h` | `$N_h` | Effective sample size within h [left, right] |
| `M` | `$M` | Unique observations [left, right] |
| `vce` | `$vce` | VCE method |
| `masspoints` | `$masspoints` | Mass points option |

### Python Return Structure

Returns a tuple `(bws_DataFrame, bwselect_string)`:
- `bws[0]`: DataFrame with bandwidth values (h_left, h_right, b_left, b_right)
- `bws[1]`: String identifying the bandwidth criterion

### Stata Return Structure

Results stored in `e()`:

| Scalar/Matrix | Access | Description |
|--------------|--------|-------------|
| `e(h_mserd)` | scalar | MSE-RD optimal h |
| `e(b_mserd)` | scalar | MSE-RD optimal b |
| `e(h_msetwo_l)`, `e(h_msetwo_r)` | scalars | MSE-Two optimal h (left, right) |
| `e(h_msesum)` | scalar | MSE-Sum optimal h |
| `e(h_cerrd)` | scalar | CER-RD optimal h |
| `e(mat_h)`, `e(mat_b)` | matrices | Full bandwidth matrices (when `all` specified) |
| `e(N_l)`, `e(N_r)` | scalars | Sample size (left, right) |
| `e(p)`, `e(q)` | scalars | Polynomial orders |
| `e(c)` | scalar | Cutoff |
| `e(kernel)` | string | Kernel type |
| `e(bwselect)` | string | BW method |
| `e(vce_type)` | string | VCE type |
| `e(n_clust)` | scalar | Number of clusters |

---

## Workflow Integration

### Standard Workflow: rdbwselect → rdrobust

```r
# R — Step 1: Explore bandwidths
bw <- rdbwselect(y, x, c = 0, all = TRUE)
summary(bw)

# Step 2: Use MSE-optimal bandwidth in rdrobust
h_mse <- bw$bws["mserd", "h"]
out <- rdrobust(y, x, c = 0, h = h_mse)
summary(out)
```

```python
# Python
bw = rdbwselect(y, x, c = 0, all = True)
h_mse = bw[0].iloc[0, 0]  # First row, first column = h_left for mserd
out = rdrobust(y, x, c = 0, h = h_mse)
print(out)
```

```stata
* Stata
rdbwselect y x, c(0)
local h_opt = e(h_mserd)
rdrobust y x, c(0) h(`h_opt')
```

### Sensitivity Analysis Workflow

```r
# R — Test robustness across bandwidth choices
criteria <- c("mserd", "cerrd", "msetwo")
results <- lapply(criteria, function(bws) {
  rdrobust(y, x, c = 0, bwselect = bws)$coef[3]  # Robust estimate
})
names(results) <- criteria
```

```python
# Python
criteria = ["mserd", "cerrd", "msetwo"]
results = {}
for bws in criteria:
    out = rdrobust(y, x, c = 0, bwselect = bws)
    results[bws] = out.coef[2]  # Robust estimate
print(results)
```

```stata
* Stata
foreach bws in mserd cerrd msetwo {
    quietly rdrobust y x, c(0) bwselect(`bws')
    display "`bws': tau = " e(tau_bc) " h = " e(h_l)
}
```

### Manual Bandwidth Grid

```r
# R — Estimate across a grid of bandwidths
bw_opt <- rdbwselect(y, x, c = 0)$bws[1, 1]
h_grid <- seq(0.5 * bw_opt, 1.5 * bw_opt, length.out = 5)
results <- sapply(h_grid, function(h) {
  rdrobust(y, x, c = 0, h = h)$coef[3]
})
```

---

## Practical Guidance

### Interpreting the Output Table

When `all = TRUE`, the summary displays a table with rows for each criterion:

```
=============================================================================
        Method     h       b       N_l    N_r
=============================================================================
        mserd    10.52   17.31    342    375
        msetwo   9.87/11.20  16.12/18.44  318/389  ...
        cerrd    7.83   12.89    254    279
        ...
=============================================================================
```

- **h**: Main bandwidth (used for point estimation)
- **b**: Pilot bandwidth (used for bias estimation, typically larger)
- **N_l, N_r**: Effective sample sizes (observations within h, left and right)
- CER bandwidths are always smaller than corresponding MSE bandwidths

### Rules of Thumb

1. **MSE bandwidth is always larger than CER bandwidth** for the same criterion variant
2. **Ratio h/b** is typically around 0.5–0.7 (bias bandwidth is larger to estimate higher-order derivatives)
3. **If MSE and CER give very different results**, the design may have power issues or substantial bias
4. **If left/right bandwidths differ greatly** (`msetwo`), consider whether this reflects genuine asymmetry or finite-sample noise

### Regularization

The `scaleregul` parameter (default: 1) stabilizes bandwidth selection when the estimated bias term is very small. It adds a regularization term proportional to:

\[
h_{\text{reg}} = \text{scaleregul} \times \hat{\sigma}^2 / \hat{n}_h
\]

This prevents the bandwidth from diverging when bias estimates are near zero. Setting `scaleregul = 0` removes regularization (not recommended).

---

## Common Pitfalls

1. **Ignoring the pilot bandwidth (b)**: The bias correction uses bandwidth `b`, not `h`. If `b` is too small, the bias estimate has high variance. If too large, it introduces its own bias. Trust the data-driven choice.

2. **Reporting only one bandwidth criterion**: Best practice is to report `mserd` as the primary analysis and show robustness to `cerrd` and possibly `msetwo`.

3. **Manual bandwidth without justification**: If you override the data-driven bandwidth with a manual `h`, you must justify the choice. Sensitivity plots (effect vs. bandwidth) are recommended.

4. **Confusing h and b**: `h` is the main bandwidth for the point estimator; `b` is the pilot bandwidth for the bias estimator. They serve different roles and are optimized differently.

5. **Not checking effective sample sizes**: Always inspect `N_h` (effective N within bandwidth). If the bandwidth is very small, effective sample sizes may be too low for reliable inference.

---

## References

- Calonico, S., Cattaneo, M. D., and Titiunik, R. (2014). "Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs." *Econometrica*, 82(6): 2295–2326.
- Calonico, S., Cattaneo, M. D., and Farrell, M. H. (2020). "Optimal Bandwidth Choice for Robust Bias-Corrected Inference in Regression Discontinuity Designs." *Econometrics Journal*, 23(2): 192–210.

---

*See also*: [rdrobust.md](rdrobust.md) for estimation using the selected bandwidth | [rdplot.md](rdplot.md) for visualization
