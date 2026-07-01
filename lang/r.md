# rdrobust — R API Reference

> Robust Data-Driven Statistical Inference in Regression-Discontinuity Designs

---

## Installation

```r
# From CRAN
install.packages("rdrobust")

# From GitHub (development version)
# install.packages("remotes")
remotes::install_github("rdpackages/rdrobust/R/rdrobust")
```

## Package Overview

| Field | Value |
|-------|-------|
| Package | rdrobust |
| Version | 4.1.0 |
| Date | 2026-05-22 |
| License | GPL-3 |
| Depends | R (>= 3.6.0) |
| Imports | ggplot2, MASS |
| Suggests | broom, gridExtra |
| URL | https://github.com/rdpackages/rdrobust |

The `rdrobust` package provides tools for data-driven graphical and analytical statistical inference in regression-discontinuity (RD) designs. It implements local-polynomial point estimators and robust bias-corrected confidence intervals developed in Calonico, Cattaneo and Titiunik (2014), Calonico, Cattaneo and Farrell (2018, 2020), and Calonico, Cattaneo, Farrell and Titiunik (2019).

### Exported Functions

| Function | Purpose |
|----------|---------|
| `rdrobust()` | Local-polynomial RD estimation with robust inference |
| `rdbwselect()` | Data-driven bandwidth selection |
| `rdplot()` | RD plots with binned scatter and polynomial fit |

---

## Functions

### rdrobust()

Implements local-polynomial regression-discontinuity point estimators with robust bias-corrected confidence intervals. Supports Sharp, Fuzzy, and Kink RD designs.

#### Signature

```r
# File: R/rdrobust/R/rdrobust.R, Lines 1–9
rdrobust(y, x, c = NULL, fuzzy = NULL, deriv = NULL,
         p = NULL, q = NULL, h = NULL, b = NULL, rho = NULL,
         covs = NULL, covs_drop = TRUE, ginv.tol = 1e-20,
         kernel = "tri", weights = NULL, bwselect = "mserd",
         vce = "nn", cluster = NULL, nnmatch = 3, level = 95,
         scalepar = 1, scaleregul = 1, sharpbw = FALSE,
         subset = NULL, masspoints = "adjust",
         bwcheck = NULL, bwrestrict = TRUE, stdvars = TRUE,
         data = NULL)
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `y` | numeric vector | *required* | Dependent (outcome) variable [verified: R/rdrobust/R/rdrobust.R#L1] |
| `x` | numeric vector | *required* | Running (score/forcing) variable [verified: R/rdrobust/R/rdrobust.R#L1] |
| `c` | numeric scalar | `NULL` (→ 0) | RD cutoff point [verified: R/rdrobust/R/rdrobust.R#L1] |
| `fuzzy` | numeric vector | `NULL` | Treatment status variable for Fuzzy RD [verified: R/rdrobust/R/rdrobust.R#L1] |
| `deriv` | integer | `NULL` (→ 0) | Order of derivative of the regression function to be estimated. 0 = sharp/fuzzy, 1 = kink [verified: R/rdrobust/R/rdrobust.R#L1] |
| `p` | integer | `NULL` (→ 1) | Order of the local polynomial for point estimation [verified: R/rdrobust/R/rdrobust.R#L2] |
| `q` | integer | `NULL` (→ p+1) | Order of the local polynomial for bias estimation [verified: R/rdrobust/R/rdrobust.R#L2] |
| `h` | numeric (scalar or vector of 2) | `NULL` (auto) | Main bandwidth. If scalar, same BW on both sides; if vector(2), separate left/right [verified: R/rdrobust/R/rdrobust.R#L2] |
| `b` | numeric (scalar or vector of 2) | `NULL` (auto) | Pilot bandwidth for bias estimation [verified: R/rdrobust/R/rdrobust.R#L2] |
| `rho` | numeric scalar | `NULL` | Bandwidth ratio h/b; when h is set and rho omitted, defaults to rho=1 (so b=h). Must be > 0 if specified. | [verified: R/rdrobust/R/rdrobust.R#L2] |
| `covs` | formula or matrix | `NULL` | Additional covariates to include in the local polynomial [verified: R/rdrobust/R/rdrobust.R#L3] |
| `covs_drop` | logical | `TRUE` | If TRUE, collinear covariates are dropped [verified: R/rdrobust/R/rdrobust.R#L3] |
| `ginv.tol` | numeric | `1e-20` | Tolerance for generalized inverse (MASS::ginv) [verified: R/rdrobust/R/rdrobust.R#L3] |
| `kernel` | character | `"tri"` | Kernel function: `"tri"` (triangular), `"epa"` (Epanechnikov), `"uni"` (uniform) [verified: R/rdrobust/R/rdrobust.R#L4] |
| `weights` | numeric vector | `NULL` | Observation-specific weights [verified: R/rdrobust/R/rdrobust.R#L4] |
| `bwselect` | character | `"mserd"` | Bandwidth selection procedure. Options: `"mserd"`, `"msetwo"`, `"msesum"`, `"msecomb1"`, `"msecomb2"`, `"cerrd"`, `"certwo"`, `"cersum"`, `"cercomb1"`, `"cercomb2"` [verified: R/rdrobust/R/rdrobust.R#L4] |
| `vce` | character | `"nn"` | Variance-covariance estimator: `"nn"` (nearest-neighbor), `"hc0"`, `"hc1"`, `"hc2"`, `"hc3"` [verified: R/rdrobust/R/rdrobust.R#L5] |
| `cluster` | vector | `NULL` | Cluster ID variable for clustered standard errors [verified: R/rdrobust/R/rdrobust.R#L5] |
| `nnmatch` | integer | `3` | Minimum number of neighbors for NN variance estimator [verified: R/rdrobust/R/rdrobust.R#L5] |
| `level` | numeric | `95` | Confidence level for intervals (in percent) [verified: R/rdrobust/R/rdrobust.R#L5] |
| `scalepar` | numeric | `1` | Scaling factor for the RD parameter of interest [verified: R/rdrobust/R/rdrobust.R#L6] |
| `scaleregul` | numeric | `1` | Scaling factor for regularization term in bandwidth selection [verified: R/rdrobust/R/rdrobust.R#L6] |
| `sharpbw` | logical | `FALSE` | If TRUE, forces use of sharp-RD bandwidth even in fuzzy design [verified: R/rdrobust/R/rdrobust.R#L6] |
| `subset` | logical vector | `NULL` | Subset of observations to use [verified: R/rdrobust/R/rdrobust.R#L7] |
| `masspoints` | character | `"adjust"` | Mass points handling: `"adjust"` (default), `"check"`, `"off"` [verified: R/rdrobust/R/rdrobust.R#L7] |
| `bwcheck` | integer | `NULL` | Minimum number of unique observations within bandwidth. If check fails, bandwidth is enlarged [verified: R/rdrobust/R/rdrobust.R#L8] |
| `bwrestrict` | logical | `TRUE` | If TRUE, restrict bandwidth to range of x [verified: R/rdrobust/R/rdrobust.R#L8] |
| `stdvars` | logical | `TRUE` | If TRUE, standardize x and y for bandwidth selection [verified: R/rdrobust/R/rdrobust.R#L8] |
| `data` | data.frame | `NULL` | Optional data frame containing the variables [verified: R/rdrobust/R/rdrobust.R#L9] |

#### Return Object

The function returns an object of class `"rdrobust"` (a named list) with the following elements:

| Element | Type | Description |
|---------|------|-------------|
| `$Estimate` | data.frame | Summary table: conventional, bias-corrected, and robust estimates/SEs |
| `$bws` | matrix | Bandwidth matrix (2×2): rows = h, b; cols = left, right |
| `$coef` | numeric(3) | Point estimates: Conventional, Bias-Corrected, Robust |
| `$se` | numeric(3) | Standard errors: Conventional, Bias-Corrected, Robust |
| `$z` | numeric(3) | z-statistics for each method |
| `$pv` | numeric(3) | p-values for each method |
| `$ci` | matrix(3×2) | Confidence intervals [lower, upper] for each method |
| `$beta_Y_p_l` | numeric | Left-side polynomial coefficients (outcome equation) |
| `$beta_Y_p_r` | numeric | Right-side polynomial coefficients (outcome equation) |
| `$beta_T_p_l` | numeric | Left-side polynomial coefficients (first-stage, fuzzy only) |
| `$beta_T_p_r` | numeric | Right-side polynomial coefficients (first-stage, fuzzy only) |
| `$V_cl_l` | matrix | Conventional variance-covariance matrix, left side |
| `$V_cl_r` | matrix | Conventional variance-covariance matrix, right side |
| `$V_rb_l` | matrix | Robust variance-covariance matrix, left side |
| `$V_rb_r` | matrix | Robust variance-covariance matrix, right side |
| `$N` | integer(2) | Total sample size [left, right] |
| `$N_h` | integer(2) | Effective sample size within h-bandwidth [left, right] |
| `$N_b` | integer(2) | Sample size within b-bandwidth [left, right] |
| `$M` | integer(2) | Number of unique observations [left, right] |
| `$tau_cl` | numeric | Conventional RD estimate |
| `$tau_bc` | numeric | Bias-corrected RD estimate |
| `$c` | numeric | Cutoff value used |
| `$p` | integer | Polynomial order for estimation |
| `$q` | integer | Polynomial order for bias correction |
| `$bias` | numeric(2) | Estimated bias [left, right] |
| `$kernel` | character | Kernel type used |
| `$vce` | character | VCE method used |
| `$bwselect` | character | Bandwidth selection method |
| `$level` | numeric | Confidence level |
| `$masspoints` | character | Mass points option |
| `$rdmodel` | character | RD model description string |
| `$n_clust` | integer | Number of clusters (if cluster supplied) |
| `$coef_covs` | numeric | Covariate coefficients (if covs supplied) |
| `$tau_T` | numeric | First-stage estimate (fuzzy only) |
| `$se_T` | numeric | First-stage standard error (fuzzy only) |
| `$z_T` | numeric | First-stage z-statistic (fuzzy only) |
| `$pv_T` | numeric | First-stage p-value (fuzzy only) |
| `$ci_T` | matrix | First-stage confidence interval (fuzzy only) |

#### Usage Example

```r
library(rdrobust)

# Load built-in Senate dataset
data(rdrobust_RDsenate)
y <- rdrobust_RDsenate$vote
x <- rdrobust_RDsenate$margin

# Sharp RD estimation with default settings
rd <- rdrobust(y, x)
summary(rd)
# =============================================================================
#         Method     Coef. Std. Err.         z     P>|z|      CI Lower   CI Upper
# =============================================================================
#   Conventional     7.414     1.459     5.081     0.000         4.554     10.274
#   Bias-Corrected   7.640     1.459     5.236     0.000         4.780     10.500
#        Robust      7.640     1.697     4.502     0.000         4.314     10.966
# =============================================================================

# Access specific elements
rd$coef        # Point estimates
rd$bws         # Bandwidths used
rd$N_h         # Effective sample sizes

# With custom bandwidth and kernel
rd2 <- rdrobust(y, x, h = 10, kernel = "epa", vce = "hc1")

# Fuzzy RD (with treatment variable)
# rd_fuzzy <- rdrobust(y, x, fuzzy = treatment_var)

# Using data argument with formula-style covariates
# rd3 <- rdrobust(vote ~ margin | covs_formula, data = mydata)
```

---

### rdbwselect()

Implements bandwidth selection procedures for local-polynomial RD estimation. Returns optimal bandwidths under MSE or CER criteria.

#### Signature

```r
# File: R/rdrobust/R/rdbwselect.R, Lines 1–8
rdbwselect(y, x, c = NULL, fuzzy = NULL, deriv = NULL, p = NULL, q = NULL,
           covs = NULL, covs_drop = TRUE, ginv.tol = 1e-20,
           kernel = "tri", weights = NULL, bwselect = "mserd",
           vce = "nn", cluster = NULL,
           nnmatch = 3, scaleregul = 1, sharpbw = FALSE,
           all = NULL, subset = NULL, masspoints = "adjust",
           bwcheck = NULL, bwrestrict = TRUE, stdvars = TRUE,
           data = NULL)
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `y` | numeric vector | *required* | Dependent (outcome) variable [verified: R/rdrobust/R/rdbwselect.R#L1] |
| `x` | numeric vector | *required* | Running variable [verified: R/rdrobust/R/rdbwselect.R#L1] |
| `c` | numeric scalar | `NULL` (→ 0) | RD cutoff point [verified: R/rdrobust/R/rdbwselect.R#L1] |
| `fuzzy` | numeric vector | `NULL` | Treatment status for Fuzzy RD [verified: R/rdrobust/R/rdbwselect.R#L1] |
| `deriv` | integer | `NULL` (→ 0) | Derivative order for estimation [verified: R/rdrobust/R/rdbwselect.R#L1] |
| `p` | integer | `NULL` (→ 1) | Polynomial order for point estimation [verified: R/rdrobust/R/rdbwselect.R#L1] |
| `q` | integer | `NULL` (→ p+1) | Polynomial order for bias estimation [verified: R/rdrobust/R/rdbwselect.R#L1] |
| `covs` | formula or matrix | `NULL` | Additional covariates [verified: R/rdrobust/R/rdbwselect.R#L2] |
| `covs_drop` | logical | `TRUE` | Drop collinear covariates [verified: R/rdrobust/R/rdbwselect.R#L2] |
| `ginv.tol` | numeric | `1e-20` | Tolerance for generalized inverse [verified: R/rdrobust/R/rdbwselect.R#L2] |
| `kernel` | character | `"tri"` | Kernel function: `"tri"`, `"epa"`, `"uni"` [verified: R/rdrobust/R/rdbwselect.R#L3] |
| `weights` | numeric vector | `NULL` | Observation weights [verified: R/rdrobust/R/rdbwselect.R#L3] |
| `bwselect` | character | `"mserd"` | Bandwidth selection method [verified: R/rdrobust/R/rdbwselect.R#L3] |
| `vce` | character | `"nn"` | Variance estimator [verified: R/rdrobust/R/rdbwselect.R#L4] |
| `cluster` | vector | `NULL` | Cluster ID variable [verified: R/rdrobust/R/rdbwselect.R#L4] |
| `nnmatch` | integer | `3` | Min neighbors for NN variance [verified: R/rdrobust/R/rdbwselect.R#L5] |
| `scaleregul` | numeric | `1` | Regularization scaling factor [verified: R/rdrobust/R/rdbwselect.R#L5] |
| `sharpbw` | logical | `FALSE` | Force sharp BW in fuzzy design [verified: R/rdrobust/R/rdbwselect.R#L5] |
| `all` | logical | `NULL` | If TRUE, report all BW selection methods [verified: R/rdrobust/R/rdbwselect.R#L6] |
| `subset` | logical vector | `NULL` | Subset of observations [verified: R/rdrobust/R/rdbwselect.R#L6] |
| `masspoints` | character | `"adjust"` | Mass points handling: `"adjust"`, `"check"`, `"off"` [verified: R/rdrobust/R/rdbwselect.R#L6] |
| `bwcheck` | integer | `NULL` | Min unique observations within bandwidth [verified: R/rdrobust/R/rdbwselect.R#L7] |
| `bwrestrict` | logical | `TRUE` | Restrict bandwidth to range of x [verified: R/rdrobust/R/rdbwselect.R#L7] |
| `stdvars` | logical | `TRUE` | Standardize x, y for BW selection [verified: R/rdrobust/R/rdbwselect.R#L7] |
| `data` | data.frame | `NULL` | Optional data frame [verified: R/rdrobust/R/rdbwselect.R#L8] |

#### Return Object

Returns an object of class `"rdbwselect"` (a named list):

| Element | Type | Description |
|---------|------|-------------|
| `$bws` | matrix | Bandwidth matrix: rows = methods, cols = h_left, h_right, b_left, b_right |
| `$bwselect` | character | Bandwidth selection method |
| `$kernel` | character | Kernel function used |
| `$p` | integer | Polynomial order |
| `$q` | integer | Bias polynomial order |
| `$c` | numeric | Cutoff value |
| `$N` | integer(2) | Total sample size [left, right] |
| `$N_h` | integer(2) | Effective sample size [left, right] |
| `$M` | integer(2) | Unique observations [left, right] |
| `$vce` | character | VCE method used |
| `$masspoints` | character | Mass points option |

#### Usage Example

```r
library(rdrobust)
data(rdrobust_RDsenate)
y <- rdrobust_RDsenate$vote
x <- rdrobust_RDsenate$margin

# Default bandwidth selection (MSE-RD optimal)
bw <- rdbwselect(y, x)
summary(bw)
# =============================================================================
#         BW est. (h)    BW bias (b)
#    Left  Right   Left  Right
# mserd  17.71  17.71  28.04  28.04
# =============================================================================

# Report all bandwidth selection methods
bw_all <- rdbwselect(y, x, all = TRUE)
summary(bw_all)

# Custom options
bw2 <- rdbwselect(y, x, kernel = "epa", vce = "hc1", p = 2)
```

---

### rdplot()

Implements RD plots with binned scatter points and global polynomial fits. Produces publication-quality graphs using ggplot2.

#### Signature

```r
# File: R/rdrobust/R/rdplot.R, Lines 1–8
rdplot(y, x, c = 0, p = 4, nbins = NULL, binselect = "esmv", scale = NULL,
       kernel = "uni", weights = NULL, h = NULL,
       covs = NULL, covs_eval = "mean", covs_drop = TRUE, ginv.tol = 1e-20,
       support = NULL, subset = NULL, masspoints = "adjust",
       hide = FALSE, ci = NULL, shade = FALSE,
       title = NULL, x.label = NULL, y.label = NULL, x.lim = NULL, y.lim = NULL,
       col.dots = NULL, col.lines = NULL,
       data = NULL)
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `y` | numeric vector | *required* | Dependent (outcome) variable [verified: R/rdrobust/R/rdplot.R#L1] |
| `x` | numeric vector | *required* | Running variable [verified: R/rdrobust/R/rdplot.R#L1] |
| `c` | numeric scalar | `0` | RD cutoff point [verified: R/rdrobust/R/rdplot.R#L1] |
| `p` | integer | `4` | Polynomial order for the global fit [verified: R/rdrobust/R/rdplot.R#L1] |
| `nbins` | integer or vector(2) | `NULL` (auto) | Number of bins [left, right]. If scalar, same both sides [verified: R/rdrobust/R/rdplot.R#L1] |
| `binselect` | character | `"esmv"` | Bin selection method: `"es"`, `"espr"`, `"esmv"`, `"qs"`, `"qspr"`, `"qsmv"` [verified: R/rdrobust/R/rdplot.R#L1] |
| `scale` | numeric (scalar or vector of 2) | `NULL` (→ 1) | Scaling factor for number of bins [verified: R/rdrobust/R/rdplot.R#L1] |
| `kernel` | character | `"uni"` | Kernel function: `"tri"`, `"epa"`, `"uni"` [verified: R/rdrobust/R/rdplot.R#L2] |
| `weights` | numeric vector | `NULL` | Observation weights [verified: R/rdrobust/R/rdplot.R#L2] |
| `h` | numeric (scalar or vector of 2) | `NULL` (full range) | Bandwidth for polynomial fit [verified: R/rdrobust/R/rdplot.R#L2] |
| `covs` | formula or matrix | `NULL` | Additional covariates [verified: R/rdrobust/R/rdplot.R#L3] |
| `covs_eval` | character | `"mean"` | Covariate evaluation point: `"mean"` or `"0"` [verified: R/rdrobust/R/rdplot.R#L3] |
| `covs_drop` | logical | `TRUE` | Drop collinear covariates [verified: R/rdrobust/R/rdplot.R#L3] |
| `ginv.tol` | numeric | `1e-20` | Tolerance for generalized inverse [verified: R/rdrobust/R/rdplot.R#L3] |
| `support` | numeric vector(2) | `NULL` | Support (range) of running variable [verified: R/rdrobust/R/rdplot.R#L4] |
| `subset` | logical vector | `NULL` | Subset of observations to use [verified: R/rdrobust/R/rdplot.R#L4] |
| `masspoints` | character | `"adjust"` | Mass points handling: `"adjust"`, `"check"`, `"off"` [verified: R/rdrobust/R/rdplot.R#L4] |
| `hide` | logical | `FALSE` | If TRUE, suppress plot display (return object only) [verified: R/rdrobust/R/rdplot.R#L5] |
| `ci` | numeric | `NULL` (→ 0) | Confidence level for bin-mean CIs (0 = no CIs) [verified: R/rdrobust/R/rdplot.R#L5] |
| `shade` | logical | `FALSE` | If TRUE, shade the CI region [verified: R/rdrobust/R/rdplot.R#L5] |
| `title` | character | `NULL` | Plot title [verified: R/rdrobust/R/rdplot.R#L6] |
| `x.label` | character | `NULL` | X-axis label [verified: R/rdrobust/R/rdplot.R#L6] |
| `y.label` | character | `NULL` | Y-axis label [verified: R/rdrobust/R/rdplot.R#L6] |
| `x.lim` | numeric vector(2) | `NULL` | X-axis limits [verified: R/rdrobust/R/rdplot.R#L6] |
| `y.lim` | numeric vector(2) | `NULL` | Y-axis limits [verified: R/rdrobust/R/rdplot.R#L6] |
| `col.dots` | character | `NULL` | Color for scatter dots [verified: R/rdrobust/R/rdplot.R#L7] |
| `col.lines` | character | `NULL` | Color for polynomial lines [verified: R/rdrobust/R/rdplot.R#L7] |
| `data` | data.frame | `NULL` | Optional data frame [verified: R/rdrobust/R/rdplot.R#L8] |

#### Return Object

Returns an object of class `"rdplot"` (a named list):

| Element | Type | Description |
|---------|------|-------------|
| `$rdplot` | ggplot | The RD plot object (ggplot2) |
| `$coef` | list | Polynomial coefficients [Left, Right] |
| `$vars_bins` | data.frame | Binned statistics (bin midpoints, means, SEs) |
| `$vars_poly` | data.frame | Polynomial fit values for plotting |
| `$J` | integer(2) | Number of bins selected [left, right] |
| `$J_IMSE` | integer(2) | IMSE-optimal number of bins |
| `$J_MV` | integer(2) | Mimicking-variance number of bins |
| `$scale` | numeric(2) | Scale factors used [left, right] |
| `$rscale` | numeric(2) | Relative scale to IMSE-optimal |
| `$bin_avg` | numeric(2) | Average bin length [left, right] |
| `$bin_med` | numeric(2) | Median bin length [left, right] |
| `$p` | integer | Polynomial order used |
| `$c` | numeric | Cutoff value |
| `$h` | numeric(2) | Bandwidth [left, right] |
| `$N` | integer(2) | Total sample size [left, right] |
| `$N_h` | integer(2) | Effective sample size [left, right] |
| `$binselect` | character | Bin selection method used |
| `$kernel` | character | Kernel type used |
| `$coef_covs` | numeric | Covariate coefficients (if covs supplied) |

#### Usage Example

```r
library(rdrobust)
data(rdrobust_RDsenate)
y <- rdrobust_RDsenate$vote
x <- rdrobust_RDsenate$margin

# Basic RD plot
rdp <- rdplot(y, x)

# Customize appearance
rdp2 <- rdplot(y, x, p = 3, nbins = c(20, 20),
               title = "RD Plot: US Senate Elections",
               x.label = "Vote Margin (Running Variable)",
               y.label = "Vote Share (Next Election)")

# With confidence intervals
rdp3 <- rdplot(y, x, ci = 95, shade = TRUE)

# Access ggplot object for further customization
rdp$rdplot + ggplot2::theme_minimal()

# Extract binned data
head(rdp$vars_bins)

# Hide plot, return data only
rdp_data <- rdplot(y, x, hide = TRUE)
```

---

## S3 Methods

### Methods for class `"rdrobust"`

| Method | Signature | Description |
|--------|-----------|-------------|
| `print` | `print.rdrobust(x, ...)` | Compact tabular output [verified: R/rdrobust/R/rdrobust.R#L954] |
| `summary` | `summary.rdrobust(object, ..., detail = FALSE, all = FALSE)` | Detailed estimation summary with optional all-methods output [verified: R/rdrobust/R/rdrobust.R#L959] |
| `plot` | `plot.rdrobust(x, ...)` | Coefficient/CI plot | 
| `coef` | `coef.rdrobust(object, ...)` | Extract coefficients vector [verified: R/rdrobust/R/rdrobust.R#L1197] |
| `vcov` | `vcov.rdrobust(object, ...)` | Extract variance-covariance matrix [verified: R/rdrobust/R/rdrobust.R#L1203] |

### Methods for class `"rdbwselect"`

| Method | Signature | Description |
|--------|-----------|-------------|
| `print` | `print.rdbwselect(x, ...)` | Compact bandwidth table [verified: R/rdrobust/R/rdbwselect.R#L588] |
| `summary` | `summary.rdbwselect(object, ...)` | Detailed bandwidth output [verified: R/rdrobust/R/rdbwselect.R#L593] |

### Methods for class `"rdplot"`

| Method | Signature | Description |
|--------|-----------|-------------|
| `print` | `print.rdplot(x, ...)` | Print summary of bin/poly info [verified: R/rdrobust/R/rdplot.R#L625] |
| `summary` | `summary.rdplot(object, ...)` | Detailed plot statistics [verified: R/rdrobust/R/rdplot.R#L632] |
| `coef` | `coef.rdplot(object, ...)` | Extract polynomial coefficients [verified: R/rdrobust/R/rdplot.R#L656] |

### broom Tidiers

| Method | Description |
|--------|-------------|
| `broom::tidy.rdrobust()` | Returns a tibble of estimates (term, estimate, std.error, statistic, p.value, conf.low, conf.high) |
| `broom::glance.rdrobust()` | Returns a one-row tibble of model-level summaries |
| `broom::tidy.rdbwselect()` | Returns a tibble of bandwidth results |
| `broom::glance.rdbwselect()` | Returns model-level bandwidth summary |
| `broom::glance.rdplot()` | Returns plot-level summary statistics |

---

## Bandwidth Selection Methods

The `bwselect` argument controls which data-driven bandwidth selection procedure is used:

| Value | Full Name | Description |
|-------|-----------|-------------|
| `"mserd"` | MSE-optimal (common) | One common MSE-optimal bandwidth for both sides |
| `"msetwo"` | MSE-optimal (two) | Two separate MSE-optimal bandwidths (left/right) |
| `"msesum"` | MSE-optimal (sum) | MSE-optimal based on sum of left/right MSE |
| `"msecomb1"` | MSE combination 1 | min(mserd, msetwo) |
| `"msecomb2"` | MSE combination 2 | median(mserd, msetwo_l, msetwo_r) |
| `"cerrd"` | CER-optimal (common) | Coverage Error Rate optimal, common |
| `"certwo"` | CER-optimal (two) | CER-optimal, separate left/right |
| `"cersum"` | CER-optimal (sum) | CER-optimal based on sum criterion |
| `"cercomb1"` | CER combination 1 | min(cerrd, certwo) |
| `"cercomb2"` | CER combination 2 | median(cerrd, certwo_l, certwo_r) |

---

## Kernel Functions

| Value | Kernel | Formula |
|-------|--------|---------|
| `"tri"` | Triangular | K(u) = (1 - |u|) · 1(|u| ≤ 1) |
| `"epa"` | Epanechnikov | K(u) = 0.75(1 - u²) · 1(|u| ≤ 1) |
| `"uni"` | Uniform | K(u) = 0.5 · 1(|u| ≤ 1) |

---

## Complete Workflow Example

```r
library(rdrobust)
data(rdrobust_RDsenate)
y <- rdrobust_RDsenate$vote
x <- rdrobust_RDsenate$margin

# Step 1: Visualize the data
rdp <- rdplot(y, x, 
              title = "RD Plot: US Senate Incumbency Advantage",
              x.label = "Democratic Vote Margin (t)",
              y.label = "Democratic Vote Share (t+1)")

# Step 2: Select bandwidth
bw <- rdbwselect(y, x, all = TRUE)
summary(bw)

# Step 3: Estimate the RD treatment effect
rd <- rdrobust(y, x)
summary(rd)

# Step 4: Sensitivity analysis
# Different bandwidths
rd_narrow <- rdrobust(y, x, h = rd$bws[1,1] * 0.75)
rd_wide   <- rdrobust(y, x, h = rd$bws[1,1] * 1.5)

# Different polynomial orders
rd_p2 <- rdrobust(y, x, p = 2)

# Different kernels
rd_epa <- rdrobust(y, x, kernel = "epa")
rd_uni <- rdrobust(y, x, kernel = "uni")

# Step 5: Extract key results
cat("RD Estimate (robust):", rd$coef[3], "\n")
cat("95% CI (robust):", rd$ci[3,], "\n")
cat("Bandwidth (h):", rd$bws[1,], "\n")
cat("Effective N:", rd$N_h, "\n")
```

---

## References

- Calonico, S., M. D. Cattaneo, and R. Titiunik (2014). Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs. *Econometrica* 82(6): 2295–2326.
- Calonico, S., M. D. Cattaneo, and M. H. Farrell (2018). On the Effect of Bias Estimation on Coverage Accuracy in Nonparametric Inference. *Journal of the American Statistical Association* 113(522): 767–779.
- Calonico, S., M. D. Cattaneo, M. H. Farrell, and R. Titiunik (2019). Regression Discontinuity Designs Using Covariates. *Review of Economics and Statistics* 101(3): 442–451.
- Calonico, S., M. D. Cattaneo, and M. H. Farrell (2020). Optimal Bandwidth Choice for Robust Bias-Corrected Inference in Regression Discontinuity Designs. *Econometrics Journal* 23(2): 192–210.
# R Language Reference: rdrobust

> Complete API reference, idioms, return objects, performance optimization, debugging, and post-estimation workflows for the R implementation of rdrobust.

---

## Installation & Setup

```r
# CRAN (stable)
install.packages("rdrobust")

# Development version
# devtools::install_github("rdpackages/rdrobust/R/rdrobust")

# Load
library(rdrobust)

# Companion packages
install.packages("rddensity")   # Density tests
install.packages("rdlocrand")   # Local randomization inference
install.packages("rdmulti")     # Multi-cutoff/multi-score RD
```

**Version requirements**: R ≥ 3.5.0; rdrobust ≥ 2.2.0 (for CR2/CR3, formula covs, `data =` argument)

---

## API Reference

### `rdrobust(y, x, ...)`

Local polynomial RD estimation with robust bias-corrected confidence intervals.

| Parameter | Type | Default | Description | Notes |
|-----------|------|---------|-------------|-------|
| `y` | numeric vector | required | Outcome (dependent) variable | Must be same length as `x` |
| `x` | numeric vector | required | Running variable (score/forcing variable) | Centered at cutoff or specify `c` |
| `c` | numeric | `NULL` (→ 0) | RD cutoff value | Explicitly set even if 0 |
| `fuzzy` | numeric vector | `NULL` | Treatment indicator for Fuzzy RD | Binary 0/1; enables IV estimation |
| `deriv` | integer | `NULL` (→ 0) | Derivative order to estimate | 0 = level (Sharp/Fuzzy); 1 = Kink |
| `p` | integer | `NULL` (→ 1) | Polynomial order for point estimation | Higher orders risk overfitting |
| `q` | integer | `NULL` (→ p+1) | Polynomial order for bias correction | Must be > p |
| `h` | numeric (scalar or length-2) | `NULL` | Main bandwidth | If length 2: (left, right); auto if NULL |
| `b` | numeric (scalar or length-2) | `NULL` | Bias bandwidth | If length 2: (left, right); auto if NULL |
| `rho` | numeric | `NULL` | Ratio h/b | If h set but b not: rho = 1 (b = h) |
| `covs` | formula / character / matrix | `NULL` | Additional covariates | Formula: `~ z1 + z2`; character: `c("z1","z2")`; matrix: direct |
| `covs_drop` | logical | `TRUE` | Drop collinear covariates | Uses generalized inverse |
| `ginv.tol` | numeric | `1e-20` | Tolerance for generalized inverse | R-only parameter |
| `kernel` | character | `"tri"` | Kernel function | Options: `"tri"`, `"epa"`, `"uni"` (or full names) |
| `weights` | numeric vector | `NULL` | Observation weights | Multiplies kernel function |
| `bwselect` | character | `"mserd"` | Bandwidth selection method | See Bandwidth Methods table |
| `vce` | character | `"nn"` | Variance estimation method | See VCE Methods table |
| `cluster` | numeric/factor vector | `NULL` | Cluster ID variable | Requires `vce` ∈ {`"cr1"`,`"cr2"`,`"cr3"`} or auto-switch |
| `nnmatch` | integer | `3` | Minimum neighbors for NN variance | Only with `vce = "nn"` |
| `level` | numeric | `95` | Confidence level (%) | Range: (0, 100) |
| `scalepar` | numeric | `1` | Scaling factor for RD parameter | For known multiplicative factors |
| `scaleregul` | numeric | `1` | Regularization scaling | 0 removes regularization |
| `sharpbw` | logical | `FALSE` | Use sharp BW for fuzzy estimation | Auto-selected if perfect compliance on one side |
| `subset` | logical vector | `NULL` | Subset selection | `TRUE` elements included |
| `masspoints` | character | `"adjust"` | Mass points handling | Options: `"off"`, `"check"`, `"adjust"` |
| `bwcheck` | integer | `NULL` | Minimum unique obs in bandwidth | Enlarges BW if needed |
| `bwrestrict` | logical | `TRUE` | Restrict BW to range of x | Prevents extrapolation |
| `stdvars` | logical | `TRUE` | Standardize x, y for BW computation | Avoids numerical instability |
| `data` | data.frame | `NULL` | Data frame for variable lookup | Enables bare-name syntax |

#### Bandwidth Selection Methods

| Value | Full Name | Description |
|-------|-----------|-------------|
| `"mserd"` | MSE-RD | Common MSE-optimal (default) |
| `"msetwo"` | MSE-Two | Separate left/right MSE-optimal |
| `"msesum"` | MSE-Sum | MSE-optimal for sum of estimates |
| `"msecomb1"` | MSE-Comb1 | min(mserd, msesum) |
| `"msecomb2"` | MSE-Comb2 | median(msetwo, mserd, msesum) per side |
| `"cerrd"` | CER-RD | Common CER-optimal |
| `"certwo"` | CER-Two | Separate left/right CER-optimal |
| `"cersum"` | CER-Sum | CER-optimal for sum |
| `"cercomb1"` | CER-Comb1 | min(cerrd, cersum) |
| `"cercomb2"` | CER-Comb2 | median(certwo, cerrd, cersum) per side |

#### VCE Methods

| Value | Description | Requirements |
|-------|-------------|--------------|
| `"nn"` | Nearest-neighbor heteroskedasticity-robust | Default; uses `nnmatch` |
| `"hc0"` | HC0 (White) | — |
| `"hc1"` | HC1 (finite-sample corrected) | — |
| `"hc2"` | HC2 (leverage adjusted) | — |
| `"hc3"` | HC3 (jackknife-like) | Most conservative |
| `"cr1"` | Cluster-robust CR1 (d.f. correction) | Requires `cluster` |
| `"cr2"` | Cluster-robust CR2 (Bell-McCaffrey) | Requires `cluster`; best for few clusters |
| `"cr3"` | Cluster-robust CR3 (Pustejovsky-Tipton) | Requires `cluster`; most conservative |

### Variance-Covariance Estimation Methods

| `vce` Value | Method | When to Use |
|-------------|--------|-------------|
| `"nn"` (default) | Nearest-neighbor | Default; data-driven; robust to heteroskedasticity |
| `"hc0"` | White robust (HC0) | Standard heteroskedasticity-robust; no finite-sample correction |
| `"hc1"` | HC1 | With degrees-of-freedom correction (n-1)/(n-k) |
| `"hc2"` | HC2 | Leverage-adjusted; recommended for moderate samples |
| `"hc3"` | HC3 | Jackknife-like; most conservative for small samples |

#### Cluster-Robust Options (requires `cluster` argument)

| `vce` Value | Method | When to Use |
|-------------|--------|-------------|
| `"cr1"` | Standard CRV1 | Default cluster-robust; adequate when # clusters > 50 |
| `"cr2"` | Bell-McCaffrey CR2 | Bias-reduced; recommended when # clusters < 50 |
| `"cr3"` | Pustejovsky-Tipton CR3 | Jackknife; most conservative, use with very few clusters (< 20) |
| `"nn"` with `cluster` | NN within clusters | Nearest-neighbor adapted for clustered data |

**Note on CR2/CR3** (available in rdrobust ≥ 2.1):
- Use `vce = "cr2"` with `cluster` for Bell-McCaffrey CR2 (bias-reduced); recommended when # clusters < 50
- Use `vce = "cr3"` with `cluster` for CR3 (jackknife); most conservative, use with very few clusters (< 20)

```r
# Standard clustering (> 50 clusters)
est <- rdrobust(y, x, c = 0, cluster = state_id)

# Few clusters (< 50): use CR2
est_cr2 <- rdrobust(y, x, c = 0, cluster = state_id, vce = "cr2")

# Very few clusters (< 20): use CR3
est_cr3 <- rdrobust(y, x, c = 0, cluster = state_id, vce = "cr3")
```

---

### `rdbwselect(y, x, ...)`

Data-driven bandwidth selection for local polynomial RD estimators.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `y` | numeric vector | required | Outcome variable |
| `x` | numeric vector | required | Running variable |
| `c` | numeric | `NULL` (→ 0) | Cutoff |
| `fuzzy` | numeric vector | `NULL` | Treatment indicator |
| `deriv` | integer | `NULL` (→ 0) | Derivative order |
| `p` | integer | `NULL` (→ 1) | Polynomial order |
| `q` | integer | `NULL` (→ p+1) | Bias polynomial order |
| `covs` | formula / char / matrix | `NULL` | Covariates |
| `covs_drop` | logical | `TRUE` | Drop collinear |
| `ginv.tol` | numeric | `1e-20` | Inverse tolerance |
| `kernel` | character | `"tri"` | Kernel |
| `weights` | numeric vector | `NULL` | Weights |
| `bwselect` | character | `"mserd"` | BW method |
| `vce` | character | `"nn"` | VCE method |
| `cluster` | vector | `NULL` | Cluster ID |
| `nnmatch` | integer | `3` | NN matches |
| `scaleregul` | numeric | `1` | Regularization |
| `sharpbw` | logical | `FALSE` | Sharp BW for fuzzy |
| `all` | logical | `NULL` | Report all methods |
| `subset` | logical vector | `NULL` | Subset |
| `masspoints` | character | `"adjust"` | Mass points |
| `bwcheck` | integer | `NULL` | Min unique obs |
| `bwrestrict` | logical | `TRUE` | Restrict to range |
| `stdvars` | logical | `TRUE` | Standardize |
| `data` | data.frame | `NULL` | Data frame |

---

### `rdplot(y, x, ...)`

Data-driven RD plots with optimal bin selection.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `y` | numeric vector | required | Outcome variable |
| `x` | numeric vector | required | Running variable |
| `c` | numeric | `0` | Cutoff |
| `p` | integer | `4` | Global polynomial order for fitted curve |
| `nbins` | integer or length-2 | `NULL` | Manual number of bins (left, right) |
| `binselect` | character | `"esmv"` | Bin selection method |
| `scale` | numeric | `NULL` | Scaling multiplier for number of bins |
| `kernel` | character | `"uni"` | Kernel function |
| `weights` | numeric vector | `NULL` | Observation weights |
| `h` | numeric (scalar/length-2) | `NULL` | Bandwidth (default: full support) |
| `covs` | formula / char / matrix | `NULL` | Covariates for polynomial fit |
| `covs_eval` | character | `"mean"` | Evaluation point for covariates |
| `covs_drop` | logical | `TRUE` | Drop collinear covariates |
| `ginv.tol` | numeric | `1e-20` | Inverse tolerance |
| `support` | numeric (length-2) | `NULL` | Extended support for bins |
| `subset` | logical vector | `NULL` | Subset selection |
| `masspoints` | character | `"adjust"` | Mass points handling |
| `hide` | logical | `FALSE` | Suppress plot display |
| `ci` | numeric | `NULL` | CI level (e.g., 95) |
| `shade` | logical | `FALSE` | Use shading instead of CI bars |
| `title` | character | `NULL` | Plot title |
| `x.label` | character | `NULL` | X-axis label |
| `y.label` | character | `NULL` | Y-axis label |
| `x.lim` | numeric (length-2) | `NULL` | X-axis limits |
| `y.lim` | numeric (length-2) | `NULL` | Y-axis limits |
| `col.dots` | character | `NULL` | Color for dots |
| `col.lines` | character | `NULL` | Color for fitted lines |
| `data` | data.frame | `NULL` | Data frame |

#### Bin Selection Methods

| Value | Description |
|-------|-------------|
| `"es"` | IMSE-optimal evenly-spaced (spacings estimators) |
| `"espr"` | IMSE-optimal evenly-spaced (polynomial regression) |
| `"esmv"` | Mimicking variance evenly-spaced (default) |
| `"esmvpr"` | Mimicking variance evenly-spaced (poly regression) |
| `"qs"` | IMSE-optimal quantile-spaced |
| `"qspr"` | IMSE-optimal quantile-spaced (poly regression) |
| `"qsmv"` | Mimicking variance quantile-spaced |
| `"qsmvpr"` | Mimicking variance quantile-spaced (poly regression) |

---

## Return Object Structure

### `rdrobust` Return: S3 list of class `"rdrobust"`

| Element | Type | Access | Description |
|---------|------|--------|-------------|
| `N` | integer[2] | `est$N` | Total sample size (left, right) |
| `N_h` | integer[2] | `est$N_h` | Effective sample size within h (left, right) |
| `N_b` | integer[2] | `est$N_b` | Effective sample size within b (left, right) |
| `M` | integer[2] | `est$M` | Unique observations per side (when masspoints ≠ "off") |
| `c` | numeric | `est$c` | Cutoff value used |
| `p` | integer | `est$p` | Polynomial order for estimation |
| `q` | integer | `est$q` | Polynomial order for bias correction |
| `bws` | matrix[2×2] | `est$bws` | Bandwidths: rows = (h, b); cols = (left, right) |
| `tau_cl` | numeric[2] | `est$tau_cl` | Conventional left and right estimates |
| `tau_bc` | numeric[2] | `est$tau_bc` | Bias-corrected left and right estimates |
| `coef` | numeric[3] | `est$coef` | RD estimates: [1]=conventional, [2]=bias-corrected, [3]=robust |
| `se` | numeric[3] | `est$se` | Standard errors: [1]=conventional, [2]=bc, [3]=robust |
| `z` | numeric[3] | `est$z` | Z-statistics |
| `pv` | numeric[3] | `est$pv` | P-values |
| `ci` | matrix[3×2] | `est$ci` | CIs: rows = (conv, bc, robust); cols = (lower, upper) |
| `bias` | numeric[2] | `est$bias` | Estimated bias (left, right) |
| `beta_Y_p_l` | numeric | `est$beta_Y_p_l` | Polynomial coefficients, left |
| `beta_Y_p_r` | numeric | `est$beta_Y_p_r` | Polynomial coefficients, right |
| `beta_T_p_l` | numeric | `est$beta_T_p_l` | First-stage coefficients, left (fuzzy only) |
| `beta_T_p_r` | numeric | `est$beta_T_p_r` | First-stage coefficients, right (fuzzy only) |
| `coef_covs` | numeric | `est$coef_covs` | Covariate coefficients (when covs specified) |
| `V_cl_l` | matrix | `est$V_cl_l` | Conventional V-Cov, left |
| `V_cl_r` | matrix | `est$V_cl_r` | Conventional V-Cov, right |
| `V_rb_l` | matrix | `est$V_rb_l` | Robust V-Cov, left |
| `V_rb_r` | matrix | `est$V_rb_r` | Robust V-Cov, right |
| `kernel` | character | `est$kernel` | Kernel used |
| `vce` | character | `est$vce` | VCE method used |
| `bwselect` | character | `est$bwselect` | Bandwidth method used |
| `level` | numeric | `est$level` | Confidence level |
| `masspoints` | character | `est$masspoints` | Mass points option |
| `rdmodel` | character | `est$rdmodel` | Model description string |
| `n_clust` | integer[2] | `est$n_clust` | Clusters per side (when clustering) |

### S3 Methods for `rdrobust` Objects

| Method | Usage | What It Shows |
|--------|-------|---------------|
| `print(est)` | `print(est)` | Compact one-row robust result (v4.0.0+) |
| `summary(est)` | `summary(est)` | Same as print (robust row only) |
| `summary(est, all=TRUE)` | Full table | Three rows: Conventional / Bias-corrected / Robust |
| `summary(est, detail=TRUE)` | Two-row table | Conventional + Robust |
| `coef(est)` | `coef(est)` | Named coefficient vector |
| `vcov(est)` | `vcov(est)` | Variance-covariance matrix |
| `confint(est)` | `confint(est)` | Confidence intervals |

### `rdbwselect` Return: S3 list of class `"rdbwselect"`

| Element | Type | Access | Description |
|---------|------|--------|-------------|
| `N` | integer[2] | `bw$N` | Sample sizes (left, right) |
| `N_h` | integer[2] | `bw$N_h` | Effective N within selected h |
| `M` | integer[2] | `bw$M` | Unique observations per side |
| `c` | numeric | `bw$c` | Cutoff |
| `p` | integer | `bw$p` | Polynomial order |
| `q` | integer | `bw$q` | Bias polynomial order |
| `bws` | matrix | `bw$bws` | BW matrix: columns = (h_l, h_r, b_l, b_r); rows = methods |
| `bwselect` | character | `bw$bwselect` | Method name(s) |
| `kernel` | character | `bw$kernel` | Kernel used |
| `vce` | character | `bw$vce` | VCE method |
| `masspoints` | character | `bw$masspoints` | Mass points option |

### `rdplot` Return: S3 list of class `"rdplot"`

| Element | Type | Access | Description |
|---------|------|--------|-------------|
| `rdplot` | ggplot object | `plt$rdplot` | The plot object (for further customization) |
| `vars_bins` | data.frame | `plt$vars_bins` | Bin data (means, CI bounds) |
| `vars_poly` | data.frame | `plt$vars_poly` | Polynomial fit data |
| `N` | integer[2] | `plt$N` | Sample sizes |
| `J` | integer[2] | `plt$J` | Number of bins selected (left, right) |
| `coef` | matrix | `plt$coef` | Global polynomial coefficients |
| `p` | integer | `plt$p` | Polynomial order used |
| `h` | numeric[2] | `plt$h` | Bandwidths used |

---

## R-Specific Idioms

### Formula Interface for Covariates (v2.2.0+)

```r
# Formula: auto-expands factors, interactions, transformations
est <- rdrobust(y = vote, x = margin,
                covs = ~ age + income + factor(state) + I(age^2),
                data = senate_data)

# Character vector (programmatic)
cov_names <- c("age", "income", "education")
est <- rdrobust(y = vote, x = margin, covs = cov_names, data = senate_data)

# Legacy matrix interface (backward compatible)
covs_matrix <- cbind(data$age, data$income, data$education)
est <- rdrobust(y = data$vote, x = data$margin, covs = covs_matrix)
```

### Pipe Integration

```r
# With base R pipe (4.1+)
library(rdrobust)
result <- read.csv("senate.csv") |>
  (\(d) rdrobust(y = d$vote, x = d$margin))()

# With data = argument (cleaner)
result <- rdrobust(y = vote, x = margin, data = read.csv("senate.csv"))
```

### Tidyverse-Style Extraction

```r
library(broom)  # If broom methods available, or manual:
# Extract tidy results
tidy_rd <- data.frame(
  term = c("Conventional", "Bias-corrected", "Robust"),
  estimate = est$coef,
  std.error = est$se,
  statistic = est$z,
  p.value = est$pv,
  conf.low = est$ci[,1],
  conf.high = est$ci[,2]
)
```

### ggplot2 Customization of rdplot

```r
# rdplot returns a ggplot object — customize freely
plt <- rdplot(y = vote, x = margin, data = df, hide = FALSE)

# Further customization
plt$rdplot + 
  ggplot2::theme_minimal() +
  ggplot2::geom_vline(xintercept = 0, linetype = "dashed", color = "red") +
  ggplot2::annotate("text", x = 5, y = 55, label = "Treatment side")
```

---

## Performance Optimization

### Large Samples (n > 100,000)

```r
# 1. Use subset to reduce computation if only need specific subpopulation
est <- rdrobust(y, x, subset = (year >= 2000))

# 2. For repeated estimation (e.g., permutation inference), pre-compute bandwidth:
bw <- rdbwselect(y, x)
h_val <- bw$bws[1, 1:2]  # Use fixed bandwidth across iterations
est <- rdrobust(y, x, h = h_val)

# 3. Avoid covariates if not needed for the specific robustness check
# Covariates increase computation (matrix inversion per side)

# 4. Use vce = "hc0" instead of "nn" for speed (NN requires distance computation)
est_fast <- rdrobust(y, x, vce = "hc0")
```

### Memory Management

```r
# For very wide covariate matrices, consider:
# - Dropping unused covariates before passing
# - Using sparse matrix representations manually
# - Running on a subset first to verify, then full sample
```

### Parallel Computation (for multiple-cutoff / simulation)

```r
library(parallel)
cutoffs <- c(-2, -1, 0, 1, 2)
results <- mclapply(cutoffs, function(cc) {
  rdrobust(y = data$outcome, x = data$runvar, c = cc)
}, mc.cores = detectCores() - 1)
```

---

## Debugging and Error Handling

### Common Error Messages

| Error | Cause | Fix |
|-------|-------|-----|
| `"Insufficient number of unique observations"` | Too few distinct running-variable values within bandwidth | Use `masspoints = "adjust"` or increase `bwcheck` |
| `"Collinear covariates detected"` | Covariates are linearly dependent | `covs_drop = TRUE` handles this automatically; or remove redundant covariates |
| `"Bandwidth is larger than the range of x"` | Extremely small sample or very large computed BW | Set `bwrestrict = TRUE` (default) |
| `"fuzzy variable must be binary"` | Fuzzy variable contains non-0/1 values | Ensure binary treatment indicator |
| `"p must be >= 0"` / `"q must be > p"` | Invalid polynomial order specification | Check: p ≥ 0 and q > p (default: p=1, q=2) |
| Warning: `"all/detail moved to summary()"` | Using `all=TRUE` in rdrobust() in v4.0.0+ | Move to `summary(est, all = TRUE)` |

### Silent Failures to Watch

1. **Bandwidth too narrow**: If `N_h` is very small (< 20), estimates may be noisy — check `est$N_h`
2. **Implicit mass-point adjustment**: When `masspoints = "adjust"` enlarges the bandwidth silently — compare `h` requested vs `h` actually used (in `est$bws`)
3. **Perfect collinearity with covariates**: Dropped covariates are not reported prominently — inspect `est$coef_covs` dimensions

### Version Compatibility

| Feature | Minimum Version | Notes |
|---------|-----------------|-------|
| `data =` argument | 2.2.0 | Before: must pass vectors directly |
| Formula covariates `~ z1 + z2` | 2.2.0 | Before: matrix only |
| CR2/CR3 cluster VCE | 2.1.0 | Before: only cr1 / equivalent `nn` with cluster |
| `masspoints` option | 1.0.0 | Before: no mass-point handling |
| `summary(est, all=TRUE)` | 4.0.0 | Before: `all` was in rdrobust() |
| `stdvars` option | 2.0.0 | Before: no standardization |

---

## Post-Estimation Workflow

### Extracting Results for Reporting

```r
est <- rdrobust(y = vote, x = margin, data = senate)

# Key results for paper
tau_robust <- est$coef[3]           # Robust point estimate (= bias-corrected)
se_robust  <- est$se[3]             # Robust SE
ci_robust  <- est$ci[3, ]           # Robust 95% CI
pval_robust <- est$pv[3]            # Robust p-value
h_left <- est$bws[1, 1]            # Estimation bandwidth (left)
h_right <- est$bws[1, 2]           # Estimation bandwidth (right)
n_eff <- est$N_h                    # Effective sample sizes

cat(sprintf("RD Estimate: %.3f (SE = %.3f)\n", tau_robust, se_robust))
cat(sprintf("95%% Robust CI: [%.3f, %.3f]\n", ci_robust[1], ci_robust[2]))
cat(sprintf("p-value: %.4f\n", pval_robust))
cat(sprintf("Bandwidth: h_l = %.2f, h_r = %.2f\n", h_left, h_right))
cat(sprintf("Effective N: %d (left), %d (right)\n", n_eff[1], n_eff[2]))
```

### Integration with Table Packages

```r
# modelsummary
library(modelsummary)
modelsummary(est)  # If supported

# Manual LaTeX table
cat(sprintf("\\begin{tabular}{lcccc}
\\hline
& Estimate & SE & CI Lower & CI Upper \\\\
\\hline
Robust & %.3f & %.3f & %.3f & %.3f \\\\
\\hline
\\end{tabular}", est$coef[3], est$se[3], est$ci[3,1], est$ci[3,2]))
```

### Combining with ggplot2 for Publication Plots

```r
library(ggplot2)

# Extract rdplot data for custom plotting
plt <- rdplot(y = vote, x = margin, data = senate, hide = TRUE)
bin_data <- plt$vars_bins
poly_data <- plt$vars_poly

# Custom publication-quality plot
ggplot() +
  geom_point(data = bin_data, aes(x = rdplot_mean_x, y = rdplot_mean_y),
             shape = 21, fill = "gray70", size = 2) +
  geom_line(data = poly_data[poly_data$rdplot_x < 0, ],
            aes(x = rdplot_x, y = rdplot_y), color = "navy", linewidth = 1) +
  geom_line(data = poly_data[poly_data$rdplot_x >= 0, ],
            aes(x = rdplot_x, y = rdplot_y), color = "navy", linewidth = 1) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  labs(x = "Vote Margin (t)", y = "Vote Share (t+2)",
       title = "Regression Discontinuity Plot") +
  theme_classic()
```

### Exporting Results

```r
# To CSV
results_df <- data.frame(
  Method = c("Conventional", "Bias-Corrected", "Robust"),
  Estimate = est$coef,
  SE = est$se,
  z = est$z,
  pvalue = est$pv,
  CI_lower = est$ci[,1],
  CI_upper = est$ci[,2]
)
write.csv(results_df, "rd_results.csv", row.names = FALSE)
```

---

## Advanced Usage Patterns

### Multiple RD Estimates with Covariates

```r
# Without covariates (baseline)
est_base <- rdrobust(y = vote, x = margin, data = senate)

# With covariates (efficiency gain)
est_covs <- rdrobust(y = vote, x = margin,
                     covs = ~ class + termshouse + termssenate,
                     data = senate)

# Compare CI lengths
ci_len_base <- diff(est_base$ci[3,])
ci_len_covs <- diff(est_covs$ci[3,])
cat(sprintf("CI length reduction: %.1f%%\n", (1 - ci_len_covs/ci_len_base) * 100))
```

### Fuzzy RD with First-Stage Diagnostics

```r
# Fuzzy RD estimation
est_fuzzy <- rdrobust(y = outcome, x = score, fuzzy = treatment, data = df)
summary(est_fuzzy, all = TRUE)

# First-stage strength check
est_fs <- rdrobust(y = treatment, x = score, data = df)
cat(sprintf("First stage jump: %.3f (p = %.4f)\n", est_fs$coef[1], est_fs$pv[3]))
# Rule of thumb: first-stage t-stat > 3.2 for reliable fuzzy RD
```

### Asymmetric Bandwidths

```r
# Different bandwidths left and right
est_asym <- rdrobust(y = vote, x = margin, h = c(12, 18), b = c(20, 25))
# Useful when data density is asymmetric around cutoff
```

### Clustering by State

```r
est_clust <- rdrobust(y = vote, x = margin, cluster = state,
                      vce = "cr2", data = senate)
summary(est_clust)
# CR2 is recommended when number of clusters is small (< 50)
```

---

### Publication-Quality Tables in R

```r
# Method 1: Manual construction (always works)
est <- rdrobust(y, x, c = 0)
rd_table <- data.frame(
  Method    = c("Conventional", "Bias-Corrected", "Robust"),
  Estimate  = round(est$coef, 3),
  SE        = round(est$se, 3),
  z         = round(est$z, 3),
  p_value   = round(est$pv, 4),
  CI_lower  = round(est$ci[,1], 3),
  CI_upper  = round(est$ci[,2], 3)
)
print(rd_table)

# Method 2: Export to LaTeX (requires knitr or xtable)
library(knitr)
kable(rd_table, format = "latex", caption = "RD Estimates")

# Method 3: Using modelsummary (if installed)
# library(modelsummary)
# modelsummary::datasummary_df(rd_table, output = "latex")
```

**Recommended reporting**: Always report the **Robust** row (row 3) as your main result. Include conventional estimates for comparison if space permits.
