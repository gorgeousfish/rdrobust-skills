# rdrobust — Stata API Reference

> Robust Data-Driven Statistical Inference in Regression-Discontinuity Designs

---

## Installation

```stata
* From SSC (Statistical Software Components)
ssc install rdrobust, replace

* From GitHub (latest development version)
net install rdrobust, from("https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata") replace
```

## Package Overview

| Field | Value |
|-------|-------|
| Package | rdrobust |
| Version | 11.1.0 |
| Date | 22may2026 |
| Requires | Stata 16.0+ |
| Authors | S. Calonico, M. D. Cattaneo, M. H. Farrell, R. Titiunik |

The `rdrobust` Stata package provides commands for data-driven graphical and analytical statistical inference in regression-discontinuity designs. The package includes `rdrobust` for local-polynomial point estimation with robust inference, `rdbwselect` for optimal bandwidth selection, and `rdplot` for RD visualization.

### Available Commands

| Command | .ado File | Purpose |
|---------|-----------|---------|
| `rdrobust` | rdrobust.ado (1332 lines) | Local-polynomial RD estimation |
| `rdbwselect` | rdbwselect.ado (877 lines) | Bandwidth selection |
| `rdplot` | rdplot.ado (~850 lines) | RD plots |

---

## Commands

### rdrobust

Implements local-polynomial regression-discontinuity point estimators with robust bias-corrected confidence intervals.

#### Syntax

```stata
* File: stata/rdrobust.ado, Line 10
rdrobust depvar runvar [if] [in] [, options]
```

#### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `c(real 0)` | real | `0` | RD cutoff value [verified: stata/rdrobust.ado#L10] |
| `fuzzy(string)` | varname | — | Treatment variable for Fuzzy RD [verified: stata/rdrobust.ado#L10] |
| `deriv(real 0)` | real | `0` | Derivative order (0 = sharp/fuzzy, 1 = kink) [verified: stata/rdrobust.ado#L10] |
| `p(string)` | integer | `1` | Polynomial order for point estimation [verified: stata/rdrobust.ado#L10] |
| `q(real 0)` | real | `p+1` | Polynomial order for bias estimation [verified: stata/rdrobust.ado#L10] |
| `h(string)` | numlist | auto | Main bandwidth. One value = common; two = left right [verified: stata/rdrobust.ado#L10] |
| `b(string)` | numlist | auto | Bias bandwidth [verified: stata/rdrobust.ado#L10] |
| `rho(real 0)` | real | `0` | Ratio h/b [verified: stata/rdrobust.ado#L10] |
| `covs(string)` | varlist | — | Additional covariates [verified: stata/rdrobust.ado#L10] |
| `covs_drop(string)` | string | `"pinv"` | Covariate collinearity handling: `"pinv"` (default, pseudo-inverse), `"invsym"` (symmetric inverse), `"off"` (no dropping) [verified: stata/rdrobust.ado#L10] |
| `kernel(string)` | string | `"tri"` | Kernel: `tri`, `epa`, `uni` [verified: stata/rdrobust.ado#L10] |
| `weights(string)` | varname | — | Weight variable [verified: stata/rdrobust.ado#L10] |
| `bwselect(string)` | string | `"mserd"` | Bandwidth selection method [verified: stata/rdrobust.ado#L10] |
| `vce(string)` | string | `"nn"` | Variance estimator: `nn`, `hc0`, `hc1`, `hc2`, `hc3`, `cluster varname` [verified: stata/rdrobust.ado#L10] |
| `level(real 95)` | real | `95` | Confidence level (percent) [verified: stata/rdrobust.ado#L10] |
| `all` | flag | off | Display all estimation methods [verified: stata/rdrobust.ado#L10] |
| `scalepar(real 1)` | real | `1` | Scaling factor for RD parameter [verified: stata/rdrobust.ado#L10] |
| `scaleregul(real 1)` | real | `1` | Regularization scaling for bandwidth [verified: stata/rdrobust.ado#L10] |
| `masspoints(string)` | string | `"adjust"` | Mass points: `adjust`, `check`, `off` [verified: stata/rdrobust.ado#L10] |
| `bwcheck(real 0)` | real | `0` | Min unique obs in bandwidth [verified: stata/rdrobust.ado#L10] |
| `bwrestrict(string)` | string | `"on"` | Restrict BW to range of running variable [verified: stata/rdrobust.ado#L10] |
| `stdvars(string)` | string | `"on"` | Standardize variables for BW selection [verified: stata/rdrobust.ado#L10] |
| `nochecks` | flag | off | Skip input validation checks [verified: stata/rdrobust.ado#L10] |
| `nowarnings` | flag | off | Suppress warning messages [verified: stata/rdrobust.ado#L10] |
| `detail` | flag | off | Print detailed estimation output [verified: stata/rdrobust.ado#L10] |
| `vleverage` | flag | off | Show leverage diagnostics [verified: stata/rdrobust.ado#L10] |
| `PRECision(string)` | string | — | Numeric display precision [verified: stata/rdrobust.ado#L10] |

#### covs_drop Mode Selection Guide

| Mode | Numerical Method | When to Use |
|------|-----------------|-------------|
| `"pinv"` (default) | Moore-Penrose pseudo-inverse | Safe default; handles rank-deficient designs gracefully |
| `"invsym"` | Symmetric matrix inverse | Faster but requires full-rank covariate matrix; use when you are confident covariates are not collinear |
| `"off"` | No dropping | Dangerous: if covariates are collinear, estimates become unstable. Only use when you have verified no collinearity AND want maximum covariate retention |

**Recommendation**: Keep the default `"pinv"` unless you have a specific reason to change it. If you encounter warnings about dropped covariates, do NOT switch to `"off"` — instead, review your covariate set for redundancy.

#### Stored Results

After execution, `rdrobust` stores the following in `e()`:

**Scalars:**

| e() scalar | Description |
|------------|-------------|
| `e(N_l)` | Sample size, left of cutoff |
| `e(N_r)` | Sample size, right of cutoff |
| `e(N_h_l)` | Effective sample in h-bandwidth, left |
| `e(N_h_r)` | Effective sample in h-bandwidth, right |
| `e(N_b_l)` | Sample in b-bandwidth, left |
| `e(N_b_r)` | Sample in b-bandwidth, right |
| `e(c)` | Cutoff value |
| `e(p)` | Polynomial order |
| `e(q)` | Bias polynomial order |
| `e(h_l)` | Main bandwidth, left |
| `e(h_r)` | Main bandwidth, right |
| `e(b_l)` | Bias bandwidth, left |
| `e(b_r)` | Bias bandwidth, right |
| `e(tau_cl)` | Conventional RD estimate |
| `e(tau_bc)` | Bias-corrected estimate |
| `e(tau_cl_l)` | Conventional estimate, left |
| `e(tau_cl_r)` | Conventional estimate, right |
| `e(tau_bc_l)` | Bias-corrected, left |
| `e(tau_bc_r)` | Bias-corrected, right |
| `e(se_tau_cl)` | SE, conventional |
| `e(se_tau_rb)` | SE, robust bias-corrected |
| `e(bias_l)` | Estimated bias, left |
| `e(bias_r)` | Estimated bias, right |
| `e(pv_cl)` | p-value, conventional |
| `e(pv_bc)` | p-value, bias-corrected |
| `e(pv_rb)` | p-value, robust |
| `e(ci_l_cl)` | CI lower, conventional |
| `e(ci_r_cl)` | CI upper, conventional |
| `e(ci_l_rb)` | CI lower, robust |
| `e(ci_r_rb)` | CI upper, robust |
| `e(level)` | Confidence level |
| `e(n_clust)` | Number of clusters |
| `e(tau_T_cl)` | First-stage estimate, conventional (fuzzy) |
| `e(tau_T_bc)` | First-stage estimate, bias-corrected (fuzzy) |
| `e(se_tau_T_cl)` | First-stage SE, conventional (fuzzy) |
| `e(se_tau_T_rb)` | First-stage SE, robust (fuzzy) |

**Strings:**

| e() string | Description |
|------------|-------------|
| `e(kernel)` | Kernel type used |
| `e(vce_type)` | VCE method |
| `e(bwselect)` | BW selection method |
| `e(title)` | Model description |

**Matrices:**

| e() matrix | Description |
|------------|-------------|
| `e(b)` | Coefficient vector (conventional, bias-corrected, robust) |
| `e(bws)` | Bandwidth matrix (2×2) |
| `e(ci)` | Confidence interval matrix |
| `e(V_cl_l)` | Conventional VCE, left |
| `e(V_cl_r)` | Conventional VCE, right |
| `e(V_rb_l)` | Robust VCE, left |
| `e(V_rb_r)` | Robust VCE, right |
| `e(beta_Y_p_l)` | Left polynomial coefficients (outcome) |
| `e(beta_Y_p_r)` | Right polynomial coefficients (outcome) |
| `e(beta_T_p_l)` | Left polynomial coefficients (first-stage) |
| `e(beta_T_p_r)` | Right polynomial coefficients (first-stage) |
| `e(coef_covs)` | Covariate coefficients |

#### Usage Example

```stata
* Load example data (Senate elections)
use rdrobust_senate.dta, clear

* Basic Sharp RD
rdrobust vote margin
* =============================================================================
*         Method     Coef. Std. Err.         z     P>|z|      CI Lower   CI Upper
* =============================================================================
*   Conventional     7.414     1.459     5.081     0.000         4.554     10.274
*   Bias-Corrected   7.640     1.459     5.236     0.000         4.780     10.500
*        Robust      7.640     1.697     4.502     0.000         4.314     10.966
* =============================================================================

* Access stored results
display e(tau_cl)        // Conventional estimate
display e(h_l)           // Left bandwidth
display e(N_h_l)         // Effective N, left
matrix list e(bws)       // Bandwidth matrix

* Custom options
rdrobust vote margin, h(10) kernel(epa) vce(hc1)

* Fuzzy RD
rdrobust vote margin, fuzzy(treatment)

* With covariates and clustering
rdrobust vote margin, covs(age income) vce(cluster state)

* All estimation methods
rdrobust vote margin, all

* Subsetting
rdrobust vote margin if year >= 2000
rdrobust vote margin in 1/500

* Post-estimation
rdrobust vote margin
local bw_h = e(h_l)
local tau = e(tau_cl)
display "Bandwidth: `bw_h', Effect: `tau'"
```

---

### rdbwselect

Implements data-driven bandwidth selection for local-polynomial RD estimation.

#### Syntax

```stata
* File: stata/rdbwselect.ado, Line 10
rdbwselect depvar runvar [if] [in] [, options]
```

#### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `c(real 0)` | real | `0` | RD cutoff value [verified: stata/rdbwselect.ado#L10] |
| `fuzzy(string)` | varname | — | Treatment variable for Fuzzy RD [verified: stata/rdbwselect.ado#L10] |
| `deriv(real 0)` | real | `0` | Derivative order [verified: stata/rdbwselect.ado#L10] |
| `p(string)` | integer | `1` | Polynomial order [verified: stata/rdbwselect.ado#L10] |
| `q(real 0)` | real | `p+1` | Bias polynomial order [verified: stata/rdbwselect.ado#L10] |
| `covs(string)` | varlist | — | Additional covariates [verified: stata/rdbwselect.ado#L10] |
| `covs_drop(string)` | string | `"pinv"` | Collinearity handling: `pinv` (pseudoinverse), `invsym` (sweep), `off` (no adjustment) [verified: stata/rdbwselect.ado#L10] |
| `kernel(string)` | string | `"tri"` | Kernel: `tri`, `epa`, `uni` [verified: stata/rdbwselect.ado#L10] |
| `weights(string)` | varname | — | Weight variable [verified: stata/rdbwselect.ado#L10] |
| `bwselect(string)` | string | `"mserd"` | Bandwidth selection method [verified: stata/rdbwselect.ado#L10] |
| `vce(string)` | string | `"nn"` | Variance estimator [verified: stata/rdbwselect.ado#L10] |
| `scaleregul(real 1)` | real | `1` | Regularization scaling [verified: stata/rdbwselect.ado#L10] |
| `all` | flag | off | Report all bandwidth methods [verified: stata/rdbwselect.ado#L10] |
| `masspoints(string)` | string | `"adjust"` | Mass points handling [verified: stata/rdbwselect.ado#L10] |
| `bwcheck(real 0)` | real | `0` | Min unique obs in bandwidth [verified: stata/rdbwselect.ado#L10] |
| `bwrestrict(string)` | string | `"on"` | Restrict BW to range [verified: stata/rdbwselect.ado#L10] |
| `stdvars(string)` | string | `"on"` | Standardize variables [verified: stata/rdbwselect.ado#L10] |
| `nochecks` | flag | off | Skip validation [verified: stata/rdbwselect.ado#L10] |
| `PRECision(string)` | string | — | Numeric precision [verified: stata/rdbwselect.ado#L10] |

#### covs_drop Mode Selection Guide

| Mode | Numerical Method | When to Use |
|------|-----------------|-------------|
| `"pinv"` (default) | Moore-Penrose pseudo-inverse | Safe default; handles rank-deficient designs gracefully |
| `"invsym"` | Symmetric matrix inverse | Faster but requires full-rank covariate matrix; use when you are confident covariates are not collinear |
| `"off"` | No dropping | Dangerous: if covariates are collinear, estimates become unstable. Only use when you have verified no collinearity AND want maximum covariate retention |

**Recommendation**: Keep the default `"pinv"` unless you have a specific reason to change it. If you encounter warnings about dropped covariates, do NOT switch to `"off"` — instead, review your covariate set for redundancy.

#### Stored Results

**Scalars:**

| e() scalar | Description |
|------------|-------------|
| `e(N_l)` | Sample size, left |
| `e(N_r)` | Sample size, right |
| `e(c)` | Cutoff value |
| `e(p)` | Polynomial order |
| `e(q)` | Bias polynomial order |
| `e(h_mserd)` | MSE-RD optimal h |
| `e(b_mserd)` | MSE-RD optimal b |
| `e(h_msetwo_l)` | MSE-TWO optimal h, left |
| `e(h_msetwo_r)` | MSE-TWO optimal h, right |
| `e(h_msesum)` | MSE-SUM optimal h |
| `e(h_cerrd)` | CER-RD optimal h |
| `e(n_clust)` | Number of clusters |

**Strings:**

| e() string | Description |
|------------|-------------|
| `e(kernel)` | Kernel type |
| `e(vce_type)` | VCE method |
| `e(bwselect)` | BW method selected |

**Matrices:**

| e() matrix | Description |
|------------|-------------|
| `e(mat_h)` | Main bandwidth matrix (methods × left/right) |
| `e(mat_b)` | Bias bandwidth matrix |

#### Usage Example

```stata
use rdrobust_senate.dta, clear

* Default MSE-RD bandwidth
rdbwselect vote margin
* =============================================================================
*         BW est. (h)    BW bias (b)
*    Left  Right   Left  Right
* mserd  17.71  17.71  28.04  28.04
* =============================================================================

* Report all methods
rdbwselect vote margin, all

* Access stored bandwidths
display e(h_mserd)
matrix list e(mat_h)

* Custom settings
rdbwselect vote margin, kernel(epa) p(2) vce(hc1)

* With covariates
rdbwselect vote margin, covs(age income)
```

---

### rdplot

Implements RD plots with binned scatter points and polynomial fits.

#### Syntax

```stata
* File: stata/rdplot.ado, Line 10
rdplot depvar runvar [if] [in] [, options]
```

#### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `c(real 0)` | real | `0` | RD cutoff value [verified: stata/rdplot.ado#L10] |
| `p(integer 4)` | integer | `4` | Global polynomial order [verified: stata/rdplot.ado#L10] |
| `nbins(string)` | numlist | auto | Number of bins (one or two values) [verified: stata/rdplot.ado#L10] |
| `covs(string)` | varlist | — | Additional covariates [verified: stata/rdplot.ado#L10] |
| `covs_eval(string)` | string | `"mean"` | Covariate evaluation: `mean` or `0` [verified: stata/rdplot.ado#L10] |
| `covs_drop(string)` | string | `"pinv"` | Collinearity handling: `pinv` (pseudoinverse), `invsym` (sweep), `off` (no adjustment) [verified: stata/rdplot.ado#L10] |
| `binselect(string)` | string | `"esmv"` | Bin selection: `es`, `espr`, `esmv`, `qs`, `qspr`, `qsmv` [verified: stata/rdplot.ado#L10] |
| `scale(string)` | numlist | `1` | Bin-number scaling factor [verified: stata/rdplot.ado#L10] |
| `kernel(string)` | string | `"uni"` | Kernel: `tri`, `epa`, `uni` [verified: stata/rdplot.ado#L10] |
| `weights(string)` | varname | — | Weight variable [verified: stata/rdplot.ado#L10] |
| `h(string)` | numlist | full range | Bandwidth for polynomial fit [verified: stata/rdplot.ado#L10] |
| `support(string)` | numlist(2) | — | Support of running variable [verified: stata/rdplot.ado#L10] |
| `masspoints(string)` | string | `"adjust"` | Mass points: `adjust`, `check`, `off` [verified: stata/rdplot.ado#L10] |
| `genvars` | flag | off | Generate Stata variables with plot data [verified: stata/rdplot.ado#L10] |
| `hide` | flag | off | Suppress graph display [verified: stata/rdplot.ado#L10] |
| `ci(real 0)` | real | `0` | CI level for bin means (0 = none) [verified: stata/rdplot.ado#L10] |
| `shade` | flag | off | Shade CI region [verified: stata/rdplot.ado#L10] |
| `graph_options(string asis)` | string | — | Passthrough Stata graph options [verified: stata/rdplot.ado#L10] |
| `nochecks` | flag | off | Skip input validation [verified: stata/rdplot.ado#L10] |
| `PRECision(string)` | string | — | Numeric display precision [verified: stata/rdplot.ado#L10] |

#### covs_drop Mode Selection Guide

| Mode | Numerical Method | When to Use |
|------|-----------------|-------------|
| `"pinv"` (default) | Moore-Penrose pseudo-inverse | Safe default; handles rank-deficient designs gracefully |
| `"invsym"` | Symmetric matrix inverse | Faster but requires full-rank covariate matrix; use when you are confident covariates are not collinear |
| `"off"` | No dropping | Dangerous: if covariates are collinear, estimates become unstable. Only use when you have verified no collinearity AND want maximum covariate retention |

**Recommendation**: Keep the default `"pinv"` unless you have a specific reason to change it. If you encounter warnings about dropped covariates, do NOT switch to `"off"` — instead, review your covariate set for redundancy.

#### Stored Results

**Scalars:**

| e() scalar | Description |
|------------|-------------|
| `e(N_l)` | Sample size, left |
| `e(N_r)` | Sample size, right |
| `e(N_h_l)` | Effective sample, left |
| `e(N_h_r)` | Effective sample, right |
| `e(c)` | Cutoff value |
| `e(p)` | Polynomial order |
| `e(J_star_l)` | Number of bins, left |
| `e(J_star_r)` | Number of bins, right |

**Strings:**

| e() string | Description |
|------------|-------------|
| `e(binselect)` | Bin selection method |

**Matrices:**

| e() matrix | Description |
|------------|-------------|
| `e(coef_l)` | Polynomial coefficients, left |
| `e(coef_r)` | Polynomial coefficients, right |
| `e(coef_covs)` | Covariate coefficients |

#### Generated Variables (with `genvars` option)

When `genvars` is specified, `rdplot` creates the following variables:

| Variable | Description |
|----------|-------------|
| `rdplot_id` | Bin identifier for each observation |
| `rdplot_mean_x` | Bin midpoint (x-axis) |
| `rdplot_mean_y` | Bin mean (y-axis) |
| `rdplot_hat_y` | Polynomial fitted value |
| `rdplot_ci_l` | CI lower bound (if ci > 0) |
| `rdplot_ci_r` | CI upper bound (if ci > 0) |

#### Usage Example

```stata
use rdrobust_senate.dta, clear

* Basic RD plot
rdplot vote margin

* Customized plot
rdplot vote margin, p(3) nbins(20 20) ///
    graph_options(title("RD Plot: Senate Elections") ///
                  xtitle("Vote Margin") ytitle("Vote Share"))

* With confidence intervals
rdplot vote margin, ci(95) shade

* Generate variables for custom plotting
rdplot vote margin, genvars hide
list rdplot_mean_x rdplot_mean_y in 1/10

* Custom bin selection
rdplot vote margin, binselect(qs) scale(1.5 1.5)

* With bandwidth restriction
rdplot vote margin, h(20 20)

* With covariates
rdplot vote margin, covs(age income) covs_eval(mean)

* Export graph
rdplot vote margin, graph_options(saving(rd_plot.gph, replace))
graph export rd_plot.pdf, replace
```

---

## Stata-Specific Conventions

### Subsetting Observations

Unlike R/Python which use a `subset` parameter, Stata uses standard `[if]` and `[in]` qualifiers:

```stata
* Using if condition
rdrobust vote margin if year >= 2000

* Using in range
rdrobust vote margin in 1/1000

* Combined
rdrobust vote margin if state == "CA" in 1/500
```

### Variable References

Stata operates on variables in memory. Unlike R/Python, there is no `data` argument:

```stata
* Variables must exist in the current dataset
use mydata.dta, clear
rdrobust outcome running_var
```

### Cluster Standard Errors

In Stata, clustering is specified via the `vce()` option:

```stata
* Clustered SEs
rdrobust vote margin, vce(cluster state)

* Compared to R: rdrobust(y, x, cluster = state)
* Compared to Python: rdrobust(y, x, cluster=state_array)
```

### Boolean/Flag Options

Stata uses presence/absence of option names rather than TRUE/FALSE:

```stata
* Equivalent to all=TRUE in R/Python
rdrobust vote margin, all

* Equivalent to nochecks (Stata-only)
rdrobust vote margin, nochecks nowarnings
```

---

## Bandwidth Selection Methods

| Value | Description |
|-------|-------------|
| `"mserd"` | One common MSE-optimal bandwidth (default) |
| `"msetwo"` | Two separate MSE-optimal bandwidths |
| `"msesum"` | MSE-optimal based on sum criterion |
| `"msecomb1"` | min(mserd, msetwo) |
| `"msecomb2"` | median(mserd, msetwo_l, msetwo_r) |
| `"cerrd"` | CER-optimal, common |
| `"certwo"` | CER-optimal, separate |
| `"cersum"` | CER-optimal, sum criterion |
| `"cercomb1"` | min(cerrd, certwo) |
| `"cercomb2"` | median(cerrd, certwo_l, certwo_r) |

---

## Kernel Functions

| Value | Kernel | Formula |
|-------|--------|---------|
| `"tri"` | Triangular | K(u) = (1 - |u|) · 1(|u| ≤ 1) |
| `"epa"` | Epanechnikov | K(u) = 0.75(1 - u²) · 1(|u| ≤ 1) |
| `"uni"` | Uniform | K(u) = 0.5 · 1(|u| ≤ 1) |

---

## Complete Workflow Example

```stata
* Load data
use rdrobust_senate.dta, clear

* ─── Step 1: Visualize ───
rdplot vote margin, ///
    graph_options(title("RD Plot: Incumbency Advantage") ///
    xtitle("Democratic Margin at t") ///
    ytitle("Democratic Vote Share at t+1"))

* ─── Step 2: Bandwidth selection ───
rdbwselect vote margin, all
local bw_mse = e(h_mserd)
display "MSE-optimal bandwidth: `bw_mse'"

* ─── Step 3: Main estimation ───
rdrobust vote margin
local tau_robust = e(tau_bc)
local se_robust = e(se_tau_rb)
display "RD effect (robust): `tau_robust' (SE: `se_robust')"

* ─── Step 4: Sensitivity analysis ───
* Narrower bandwidth
rdrobust vote margin, h(`=`bw_mse' * 0.75')
* Wider bandwidth
rdrobust vote margin, h(`=`bw_mse' * 1.5')
* Different polynomial
rdrobust vote margin, p(2)
* Different kernel
rdrobust vote margin, kernel(epa)

* ─── Step 5: Tabulate results ───
rdrobust vote margin
matrix results = e(b)
matrix list results
ereturn list
```

---

## Cross-Language Parameter Mapping

| R Parameter | Python Parameter | Stata Option | Notes |
|-------------|-----------------|--------------|-------|
| `y` | `y` | 1st varname | Required |
| `x` | `x` | 2nd varname | Required |
| `c = NULL` | `c = None` | `c(0)` | Default 0 |
| `fuzzy = NULL` | `fuzzy = None` | `fuzzy(varname)` | Fuzzy RD |
| `subset = NULL` | `subset = None` | `[if] [in]` | Subsetting |
| `data = mydf` | `data = df` | *(in memory)* | Data source |
| `cluster = id` | `cluster = id` | `vce(cluster id)` | Clustering |
| `nnmatch = 3` | `nnmatch = 3` | *(not available)* | R/Python only |
| `sharpbw = FALSE` | `sharpbw = False` | *(not available)* | R/Python only |
| *(not available)* | *(not available)* | `nochecks` | Stata only |
| *(not available)* | *(not available)* | `nowarnings` | Stata only |
| *(not available)* | *(not available)* | `detail` | Stata only |
| *(not available)* | *(not available)* | `vleverage` | Stata only |

---

## References

- Calonico, S., M. D. Cattaneo, and R. Titiunik (2014). Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs. *Econometrica* 82(6): 2295–2326.
- Calonico, S., M. D. Cattaneo, and M. H. Farrell (2018). On the Effect of Bias Estimation on Coverage Accuracy in Nonparametric Inference. *JASA* 113(522): 767–779.
- Calonico, S., M. D. Cattaneo, M. H. Farrell, and R. Titiunik (2019). Regression Discontinuity Designs Using Covariates. *Review of Economics and Statistics* 101(3): 442–451.
- Calonico, S., M. D. Cattaneo, and M. H. Farrell (2020). Optimal Bandwidth Choice for Robust Bias-Corrected Inference in Regression Discontinuity Designs. *Econometrics Journal* 23(2): 192–210.
# Stata Language Reference: rdrobust

> Complete API reference, idioms, return objects, performance optimization, debugging, and post-estimation workflows for the Stata implementation of rdrobust.

---

## Installation & Setup

```stata
* Install from GitHub (latest)
net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace

* Companion packages
net install rddensity, from(https://raw.githubusercontent.com/rdpackages/rddensity/master/stata) replace
net install rdlocrand, from(https://raw.githubusercontent.com/rdpackages/rdlocrand/master/stata) replace
net install rdmulti, from(https://raw.githubusercontent.com/rdpackages/rdmulti/master/stata) replace

* Verify installation
which rdrobust
```

**Version requirements**: Stata ≥ 16; rdrobust ≥ 9.0.0 (for CR2/CR3)

---

## API Reference

### `rdrobust depvar runvar [if] [in], [options]`

Local polynomial RD estimation with robust bias-corrected confidence intervals.

| Option | Type | Default | Description | Notes |
|--------|------|---------|-------------|-------|
| `c(#)` | real | `0` | RD cutoff value | |
| `fuzzy(fuzzyvar [sharpbw])` | varname + flag | — | Treatment variable for Fuzzy RD | `sharpbw` sub-option for sharp BW |
| `deriv(#)` | integer | `0` | Derivative order | 0 = level; 1 = Kink |
| `p(#)` | integer | `1` | Polynomial order (estimation) | |
| `q(#)` | integer | `p+1` | Polynomial order (bias correction) | Must be > p |
| `h(# #)` | real(s) | auto | Main bandwidth | One or two values (left right) |
| `b(# #)` | real(s) | auto | Bias bandwidth | One or two values (left right) |
| `rho(#)` | real | `1` (if h set) | Ratio h/b | b = h/rho |
| `covs(varlist)` | varlist | — | Additional covariates | Standard Stata varlist |
| `covs_drop(pinv\|invsym\|off)` | keyword | `pinv` | Collinearity handling | `pinv`/`invsym`: drop; `off`: no check |
| `kernel(kernelfn)` | keyword | `triangular` | Kernel function | `tri`/`epa`/`uni` (abbreviated) |
| `weights(varname)` | varname | — | Observation weights | Multiplies kernel |
| `bwselect(method)` | keyword | `mserd` | Bandwidth selection | See BW Methods |
| `scaleregul(#)` | real | `1` | Regularization scaling | 0 removes it |
| `scalepar(#)` | real | `1` | Estimand scaling factor | |
| `masspoints(option)` | keyword | `adjust` | Mass points | `off`/`check`/`adjust` |
| `bwcheck(#)` | integer | — | Min unique obs | Enlarges BW |
| `bwrestrict(on\|off)` | keyword | `on` | Restrict BW to data range | |
| `stdvars(on\|off)` | keyword | `on` | Standardize for BW computation | |
| `precision(double\|single)` | keyword | `double` | Internal storage precision | Stata-only; saves memory |
| `vce(vcetype [opts])` | compound | `nn 3` | Variance estimation | See VCE Options |
| `level(#)` | real | `95` | Confidence level (%) | |
| `all` | flag | — | Report all 3 inference types | |
| `detail` | flag | — | Legacy output format | |

#### Bandwidth Selection Methods

| Method | Description |
|--------|-------------|
| `mserd` | Common MSE-optimal (default) |
| `msetwo` | Separate left/right MSE-optimal |
| `msesum` | MSE-optimal for sum |
| `msecomb1` | min(mserd, msesum) |
| `msecomb2` | median(msetwo, mserd, msesum) per side |
| `cerrd` | Common CER-optimal |
| `certwo` | Separate left/right CER-optimal |
| `cersum` | CER-optimal for sum |
| `cercomb1` | min(cerrd, cersum) |
| `cercomb2` | median(certwo, cerrd, cersum) per side |

#### VCE Options

| Syntax | Description | Notes |
|--------|-------------|-------|
| `vce(nn)` or `vce(nn #)` | Nearest-neighbor (default) | `#` = nnmatch (default 3) |
| `vce(hc0)` | HC0 White | — |
| `vce(hc1)` | HC1 finite-sample | — |
| `vce(hc2)` | HC2 leverage | — |
| `vce(hc3)` | HC3 jackknife | Most conservative |
| `vce(cluster clvar)` | CR1 cluster-robust | Alias for `vce(cr1 clvar)` |
| `vce(cr1 clvar)` | CR1 with d.f. correction | — |
| `vce(cr2 clvar)` | CR2 Bell-McCaffrey | Best for few clusters |
| `vce(cr3 clvar)` | CR3 Pustejovsky-Tipton | Most conservative |

---

### `rdbwselect depvar runvar [if] [in], [options]`

Data-driven bandwidth selection.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `c(#)` | real | `0` | Cutoff |
| `fuzzy(var [sharpbw])` | varname | — | Fuzzy treatment |
| `deriv(#)` | integer | `0` | Derivative order |
| `p(#)` | integer | `1` | Polynomial order |
| `q(#)` | integer | `p+1` | Bias polynomial |
| `covs(varlist)` | varlist | — | Covariates |
| `covs_drop(opt)` | keyword | `pinv` | Collinearity |
| `kernel(fn)` | keyword | `triangular` | Kernel |
| `weights(var)` | varname | — | Weights |
| `bwselect(method)` | keyword | `mserd` | BW method |
| `scaleregul(#)` | real | `1` | Regularization |
| `vce(type [opts])` | compound | `nn 3` | VCE |
| `masspoints(opt)` | keyword | `adjust` | Mass points |
| `bwcheck(#)` | integer | — | Min unique obs |
| `bwrestrict(on\|off)` | keyword | `on` | Restrict |
| `stdvars(on\|off)` | keyword | `on` | Standardize |
| `all` | flag | — | Report all methods |

---

### `rdplot depvar runvar [if] [in], [options]`

Data-driven RD plots.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `c(#)` | real | `0` | Cutoff |
| `p(#)` | integer | `4` | Global polynomial order |
| `nbins(# #)` | integers | auto | Manual bin count (left right) |
| `binselect(method)` | keyword | `esmv` | Bin selection |
| `scale(#)` | real | `1` | Bin count multiplier |
| `kernel(fn)` | keyword | `uniform` | Kernel |
| `weights(var)` | varname | — | Weights |
| `h(# #)` | reals | full support | Bandwidth |
| `covs(varlist)` | varlist | — | Covariates |
| `covs_eval(opt)` | keyword | `mean` | Covariate evaluation |
| `covs_drop(opt)` | keyword | `pinv` | Collinearity |
| `support(# #)` | reals | data range | Extended support |
| `masspoints(opt)` | keyword | `adjust` | Mass points |
| `hide` | flag | — | Suppress plot |
| `ci(#)` | real | — | CI level |
| `shade` | flag | — | Shaded CI |
| `graph_options(...)` | string | — | Pass-through Stata graph options |
| `genvars` | flag | — | Generate bin variables |
| `nograph` | flag | — | Same as `hide` |

---

## Stored Results (e-class)

### `rdrobust` Stored Results

After running `rdrobust`, results are stored in `e()`:

#### Scalars

| Macro | Description |
|-------|-------------|
| `e(N)` | Total number of observations |
| `e(N_l)` | Observations left of cutoff |
| `e(N_r)` | Observations right of cutoff |
| `e(N_h_l)` | Effective N within h (left) |
| `e(N_h_r)` | Effective N within h (right) |
| `e(N_b_l)` | Effective N within b (left) |
| `e(N_b_r)` | Effective N within b (right) |
| `e(c)` | Cutoff value |
| `e(p)` | Polynomial order (estimation) |
| `e(q)` | Polynomial order (bias) |
| `e(h_l)` | Estimation bandwidth (left) |
| `e(h_r)` | Estimation bandwidth (right) |
| `e(b_l)` | Bias bandwidth (left) |
| `e(b_r)` | Bias bandwidth (right) |
| `e(tau_cl)` | Conventional RD estimate |
| `e(tau_cl_l)` | Conventional left estimate |
| `e(tau_cl_r)` | Conventional right estimate |
| `e(tau_bc)` | Bias-corrected RD estimate |
| `e(tau_bc_l)` | Bias-corrected left estimate |
| `e(tau_bc_r)` | Bias-corrected right estimate |
| `e(se_tau_cl)` | Conventional SE |
| `e(se_tau_rb)` | Robust SE |
| `e(bias_l)` | Estimated bias (left) |
| `e(bias_r)` | Estimated bias (right) |
| `e(level)` | Confidence level |
| `e(ci_l_cl)` | Conventional CI lower bound |
| `e(ci_r_cl)` | Conventional CI upper bound |
| `e(ci_l_rb)` | Robust CI lower bound |
| `e(ci_r_rb)` | Robust CI upper bound |
| `e(pv_cl)` | Conventional p-value |
| `e(pv_bc)` | Bias-corrected p-value |
| `e(pv_rb)` | Robust p-value |
| `e(n_clust)` | Number of clusters (if clustering) |
| `e(tau_T_cl)` | First-stage conventional estimate (Fuzzy only) |
| `e(tau_T_bc)` | First-stage bias-corrected estimate (Fuzzy only) |
| `e(se_tau_T_cl)` | First-stage conventional SE (Fuzzy only) |
| `e(se_tau_T_rb)` | First-stage robust SE (Fuzzy only) |

#### Macros

| Macro | Description |
|-------|-------------|
| `e(cmd)` | `"rdrobust"` |
| `e(cmdline)` | Full command as typed |
| `e(title)` | Output title (Sharp/Fuzzy RD) |
| `e(depvar)` | Outcome variable name |
| `e(runningvar)` | Running variable name |
| `e(clustvar)` | Cluster variable name |
| `e(covs)` | Covariate names |
| `e(vce_select)` | VCE method (raw: "nn", "cr2", etc.) |
| `e(vce_type)` | VCE display label ("NN", "CR2", etc.) |
| `e(bwselect)` | Bandwidth method used |
| `e(kernel)` | Kernel used |
| `e(ci_rb)` | Formatted robust CI string `[# ; #]` |
| `e(precision)` | Storage precision used |

#### Matrices

| Matrix | Dimensions | Description |
|--------|-----------|-------------|
| `e(b)` | 1×3 | Coefficient vector: Conventional, Bias-corrected, Robust |
| `e(V)` | 3×3 | Block-diagonal variance matrix |
| `e(ci)` | 3×2 | CI matrix: rows=Conv/BC/Robust, cols=lower/upper |
| `e(bws)` | 2×2 | Bandwidth matrix: rows=h/b, cols=left/right |
| `e(beta_Y_p_l)` | (p+1)×1 | Left polynomial coefficients |
| `e(beta_Y_p_r)` | (p+1)×1 | Right polynomial coefficients |
| `e(beta_T_p_l)` | (p+1)×1 | First-stage left (Fuzzy only) |
| `e(beta_T_p_r)` | (p+1)×1 | First-stage right (Fuzzy only) |
| `e(coef_covs)` | k×1 | Covariate coefficients |
| `e(V_cl_l)` | matrix | Conventional V-Cov (left) |
| `e(V_cl_r)` | matrix | Conventional V-Cov (right) |
| `e(V_rb_l)` | matrix | Robust V-Cov (left) |
| `e(V_rb_r)` | matrix | Robust V-Cov (right) |

### Accessing Results

```stata
* After rdrobust:
rdrobust vote margin

* Scalars
display "Estimate: " e(tau_cl)
display "Robust SE: " e(se_tau_rb)
display "Robust p-value: " e(pv_rb)
display "Robust CI: [" e(ci_l_rb) " , " e(ci_r_rb) "]"
display "Bandwidth (left): " e(h_l)
display "Bandwidth (right): " e(h_r)
display "Effective N: " e(N_h_l) " (left), " e(N_h_r) " (right)"

* Matrices
matrix list e(bws)
matrix list e(b)
matrix list e(ci)

* Using _b[] and _se[] (for Stata's standard estimation interface)
display _b[Robust]      // tau_bc (the recommended estimate)
display _se[Robust]     // se_tau_rb
```

---

## Stata-Specific Idioms

### Factor Variable Notation (NOT supported in covs())

```stata
* WRONG: factor notation not supported inside covs()
rdrobust vote margin, covs(i.state)  // ERROR

* CORRECT: Generate dummies manually
tabulate state, generate(state_d)
rdrobust vote margin, covs(state_d*)

* Or use only continuous covariates
rdrobust vote margin, covs(age income education)
```

### if/in Qualifiers

```stata
* Subset using Stata's native if/in
rdrobust vote margin if year >= 2000
rdrobust vote margin in 1/500
rdrobust vote margin if state != "CA" & year >= 1990
```

### Post-Estimation Command Chain

```stata
* Standard Stata post-estimation workflow
rdrobust vote margin
estimates store rd_base

* Store results for comparison
rdrobust vote margin, covs(class termshouse)
estimates store rd_covs

* Compare (using estout/esttab if available)
estimates table rd_base rd_covs, stats(N)
```

### ereturn System Integration

```stata
* rdrobust is e-class: integrates with Stata's estimation ecosystem
rdrobust vote margin

* Predict (not directly supported, but can construct manually)
* Test linear restrictions
test _b[Robust] = 0

* Confidence intervals via ereturn
display "Formatted CI: " e(ci_rb)
```

### Loop Over Multiple Outcomes

```stata
local outcomes "vote turnout spending"
foreach var of local outcomes {
    quietly rdrobust `var' margin
    display "`var': tau = " %7.4f e(tau_cl) ///
            " , se_rb = " %6.4f e(se_tau_rb) ///
            " , p_rb = " %6.4f e(pv_rb)
}
```

### Loop Over Multiple Cutoffs

```stata
foreach cut in -2 -1 0 1 2 {
    quietly rdrobust outcome runvar, c(`cut')
    display "c = `cut': tau = " %7.4f e(tau_cl) " , p = " %6.4f e(pv_rb)
}
```

---

## Performance Optimization

### Large Datasets (n > 1,000,000)

```stata
* 1. Use precision(single) to reduce memory
rdrobust vote margin, precision(single)

* 2. Subset data first to reduce computation
preserve
keep if abs(margin) < 50  // Keep only observations near cutoff
rdrobust vote margin
restore

* 3. Use faster VCE (avoid NN for very large samples)
rdrobust vote margin, vce(hc1)

* 4. Set bwcheck to a reasonable number to avoid extreme BW expansion
rdrobust vote margin, bwcheck(20)
```

### Memory Management

```stata
* Check memory usage
memory

* If running low with massive datasets:
set maxvar 10000    // Reduce max variables
compress            // Compress data types

* For repeated estimation, preserve/restore
preserve
keep outcome runvar cluster_id covariates
rdrobust outcome runvar, vce(cluster cluster_id)
restore
```

### Parallel Estimation (Stata MP)

```stata
* Stata MP automatically parallelizes matrix operations
* rdrobust benefits from MP for large covariate matrices
* No user action needed — just run Stata/MP
```

---

## Debugging and Error Handling

### Common Error Messages

| Error | Cause | Fix |
|-------|-------|-----|
| `"option cluster not allowed"` | Using `cluster()` as separate option | Use `vce(cluster clvar)` or `vce(cr1 clvar)` |
| `"too few observations"` | Insufficient data within bandwidth | Increase `bwcheck()` or check data |
| `"varname not found"` | Variable doesn't exist in dataset | Check `describe`, ensure data loaded |
| `"factor variables not allowed"` | Using `i.var` in `covs()` | Generate dummies manually; use varlist |
| `"requires Stata 16"` | Running on older Stata | Upgrade Stata; or use older rdrobust version |
| `"matsize too small"` | Matrix dimensions exceed limit | `set matsize 11000` |
| `"bwselect invalid"` | Typo in bandwidth method | Check spelling: `mserd`, `cerrd`, etc. |

### Diagnostic Commands

```stata
* Check if estimation was successful
rdrobust vote margin
return list       // Show all stored results
ereturn list      // Same (e-class)

* Verify data before estimation
summarize vote margin, detail
count if margin < 0
count if margin >= 0
tab1 margin if abs(margin) < 0.1  // Check mass points near cutoff
```

### Version Information

```stata
which rdrobust
* Shows version and installation path

* Check for updates
adoupdate rdrobust, update
```

### Version Compatibility

| Feature | Minimum Version | Notes |
|---------|-----------------|-------|
| CR2/CR3 cluster VCE | 9.0.0 | Before: `vce(cluster)` = CR1 only |
| `precision()` option | 11.0.0 | Before: always double |
| `stdvars()` option | 9.0.0 | Before: no standardization |
| `masspoints()` option | 8.0.0 | Before: no handling |
| `e(bws)` matrix | 9.0.0 | Before: only scalar e(h_l), etc. |
| `detail`/`all` as display flags | 9.2.0+ | Before: different output format |
| Stata 16 requirement | 9.0.0 | Earlier versions ran on Stata 13+ |

---

## Post-Estimation Workflow

### Extracting Results for Papers

```stata
rdrobust vote margin, vce(cluster state)

* Store key results in local macros
local tau = e(tau_cl)
local se_rb = e(se_tau_rb)
local ci_l = e(ci_l_rb)
local ci_r = e(ci_r_rb)
local pval = e(pv_rb)
local h_l = e(h_l)
local h_r = e(h_r)
local n_l = e(N_h_l)
local n_r = e(N_h_r)

display "RD Estimate: " %7.4f `tau' " (SE = " %6.4f `se_rb' ")"
display "95% Robust CI: [" %7.4f `ci_l' " , " %7.4f `ci_r' "]"
display "p-value: " %6.4f `pval'
display "Bandwidth: h_l = " %6.2f `h_l' " , h_r = " %6.2f `h_r'
display "Effective N: " `n_l' " (left), " `n_r' " (right)"
```

### Export to LaTeX Tables

```stata
* Using estout/esttab (if installed)
ssc install estout

rdrobust vote margin
estimates store model1

rdrobust vote margin, covs(class termshouse termssenate)
estimates store model2

esttab model1 model2 using "rd_results.tex", replace ///
    cells(b(fmt(3)) se(fmt(3) par)) ///
    stats(N, fmt(0)) ///
    title("RD Estimates") ///
    label booktabs
```

### Manual Table Construction

```stata
* Create results matrix
matrix results = J(1, 6, .)
rdrobust vote margin
matrix results[1,1] = e(tau_cl)
matrix results[1,2] = e(se_tau_rb)
matrix results[1,3] = e(pv_rb)
matrix results[1,4] = e(ci_l_rb)
matrix results[1,5] = e(ci_r_rb)
matrix results[1,6] = e(N_h_l) + e(N_h_r)
matrix colnames results = "Estimate" "Rob.SE" "p-val" "CI_low" "CI_up" "N_eff"
matrix list results, format(%9.4f)
```

### RD Plot Customization

```stata
* Basic plot
rdplot vote margin, c(0)

* Publication-quality customization via graph_options
rdplot vote margin, c(0) binselect(esmv) ///
    graph_options(title("Incumbency Advantage in U.S. Senate") ///
                  xtitle("Vote Margin at Election t") ///
                  ytitle("Vote Share at Election t+2") ///
                  legend(off) ///
                  graphregion(color(white)) ///
                  plotregion(margin(small)))

* Save graph
graph export "rd_plot.pdf", replace as(pdf)
graph export "rd_plot.png", replace as(png) width(1200)
```

### Covariate Balance Table

```stata
* Generate balance table
local covs "class termshouse termssenate population"
local ncovs : word count `covs'
matrix balance = J(`ncovs', 3, .)
local i = 1
foreach var of local covs {
    quietly rdrobust `var' margin
    matrix balance[`i', 1] = e(tau_cl)
    matrix balance[`i', 2] = e(se_tau_rb)
    matrix balance[`i', 3] = e(pv_rb)
    local i = `i' + 1
}
matrix rownames balance = `covs'
matrix colnames balance = "RD_Effect" "Robust_SE" "Robust_pval"
matrix list balance, format(%9.4f)
```

---

## Advanced Usage Patterns

### Fuzzy RD with sharpbw

```stata
* Fuzzy RD: treatment probabilistic at cutoff
rdrobust outcome score, fuzzy(treated)

* With sharp bandwidth (for comparison)
rdrobust outcome score, fuzzy(treated sharpbw)
```

### Kink RD

```stata
* Kink RD: estimating derivative discontinuity
rdrobust outcome score, deriv(1)

* Fuzzy Kink RD
rdrobust outcome score, fuzzy(treated) deriv(1)
```

### Asymmetric Bandwidths

```stata
* Different bandwidths left and right
rdrobust vote margin, h(12 18) b(20 25)
```

### Sensitivity to BW Method

```stata
* Compare all BW selection methods
foreach method in mserd msetwo cerrd certwo {
    quietly rdrobust vote margin, bwselect(`method')
    display "`method': h_l = " %6.2f e(h_l) " , tau = " %7.4f e(tau_cl) ///
            " , p_rb = " %6.4f e(pv_rb)
}
```

### Cluster-Robust with Few Clusters

```stata
* CR2 recommended when clusters < 50
rdrobust vote margin, vce(cr2 state)

* CR3 for most conservative inference
rdrobust vote margin, vce(cr3 state)

* Compare CR1 vs CR2 vs CR3
foreach cr in cr1 cr2 cr3 {
    quietly rdrobust vote margin, vce(`cr' state)
    display "`cr': se = " %6.4f e(se_tau_rb) " , p = " %6.4f e(pv_rb)
}
```

### Program for Repeated Estimation

```stata
* Define reusable program
capture program drop rd_sensitivity
program define rd_sensitivity, eclass
    syntax varlist(min=2 max=2), [c(real 0) mult(numlist)]
    tokenize `varlist'
    local y `1'
    local x `2'
    
    quietly rdrobust `y' `x', c(`c')
    local h_opt = e(h_l)
    
    display _n "Bandwidth Sensitivity:"
    display "{hline 50}"
    foreach m of numlist `mult' {
        local h_test = `h_opt' * `m'
        quietly rdrobust `y' `x', c(`c') h(`h_test')
        display "mult=" %4.2f `m' ": h=" %6.2f `h_test' ///
                " tau=" %7.4f e(tau_cl) " p=" %6.4f e(pv_rb)
    }
end

* Usage:
rd_sensitivity vote margin, mult(0.5 0.75 1 1.25 1.5 2)
```
