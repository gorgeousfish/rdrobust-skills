# rdrobust — Python API Reference

> Robust Data-Driven Statistical Inference in Regression-Discontinuity Designs

---

## Installation

```bash
# From PyPI
pip install rdrobust

# From source
pip install git+https://github.com/rdpackages/rdrobust.git#subdirectory=Python/rdrobust
```

## Package Overview

| Field | Value |
|-------|-------|
| Package | rdrobust |
| Language | Python 3.x |
| Dependencies | numpy, pandas, scipy, plotnine |
| Repository | https://github.com/rdpackages/rdrobust |

The `rdrobust` Python package implements local-polynomial regression-discontinuity point estimators with robust bias-corrected confidence intervals, bandwidth selectors, and RD visualization tools. It mirrors the R implementation by Calonico, Cattaneo, Farrell, and Titiunik.

### Public API

```python
from rdrobust import rdrobust, rdbwselect, rdplot, rdrobust_RDsenate
```

| Function | Module | Purpose |
|----------|--------|---------|
| `rdrobust()` | `rdrobust.rdrobust` | Local-polynomial RD estimation with robust inference |
| `rdbwselect()` | `rdrobust.rdbwselect` | Data-driven bandwidth selection |
| `rdplot()` | `rdrobust.rdplot` | RD plots with binned scatter and polynomial fit |
| `rdrobust_RDsenate()` | `rdrobust.datasets` | Load built-in Senate dataset |

---

## Functions

### rdrobust()

Implements local-polynomial RD point estimators with robust bias-corrected confidence intervals. Supports Sharp, Fuzzy, and Kink RD designs.

#### Signature

```python
# File: Python/rdrobust/src/rdrobust/rdrobust.py, Lines 16–24
def rdrobust(y, x, c=None, fuzzy=None, deriv=None,
             p=None, q=None, h=None, b=None, rho=None,
             covs=None, covs_drop=True,
             kernel="tri", weights=None, bwselect="mserd",
             vce="nn", cluster=None, nnmatch=3, level=95,
             scalepar=1, scaleregul=1, sharpbw=False,
             all=None, subset=None, masspoints="adjust",
             bwcheck=None, bwrestrict=True, stdvars=True,
             data=None):
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `y` | numpy array | *required* | Dependent (outcome) variable [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L16] |
| `x` | numpy array | *required* | Running (score/forcing) variable [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L16] |
| `c` | float | `None` (→ 0) | RD cutoff point [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L16] |
| `fuzzy` | numpy array | `None` | Treatment status variable for Fuzzy RD [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L16] |
| `deriv` | int | `None` (→ 0) | Order of derivative. 0 = sharp/fuzzy, 1 = kink [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L16] |
| `p` | int | `None` (→ 1) | Polynomial order for point estimation [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L17] |
| `q` | int | `None` (→ p+1) | Polynomial order for bias estimation [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L17] |
| `h` | float or list(2) | `None` (auto) | Main bandwidth. Scalar = same both sides; list = [left, right] [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L17] |
| `b` | float or list(2) | `None` (auto) | Bias bandwidth for pilot estimator [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L17] |
| `rho` | float | `None` | Bandwidth ratio h/b; when h is set and rho/b omitted, defaults to rho=1 (so b=h). Must be > 0 if specified. [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L17] |
| `covs` | numpy array or DataFrame | `None` | Additional covariates matrix [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L18] |
| `covs_drop` | bool | `True` | Drop collinear covariates [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L18] |
| `kernel` | str | `"tri"` | Kernel: `"tri"` (triangular), `"epa"` (Epanechnikov), `"uni"` (uniform) [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L19] |
| `weights` | numpy array | `None` | Observation-specific weights [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L19] |
| `bwselect` | str | `"mserd"` | Bandwidth selection method. Options: `"mserd"`, `"msetwo"`, `"msesum"`, `"msecomb1"`, `"msecomb2"`, `"cerrd"`, `"certwo"`, `"cersum"`, `"cercomb1"`, `"cercomb2"` [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L19] |
| `vce` | str | `"nn"` | Variance estimator: `"nn"`, `"hc0"`, `"hc1"`, `"hc2"`, `"hc3"` [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L20] |
| `cluster` | numpy array | `None` | Cluster ID variable for clustered SEs [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L20] |
| `nnmatch` | int | `3` | Minimum number of neighbors for NN variance [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L20] |
| `level` | float | `95` | Confidence level (percent) [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L20] |
| `scalepar` | float | `1` | Scaling factor for the RD parameter [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L21] |
| `scaleregul` | float | `1` | Regularization scaling for bandwidth [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L21] |
| `sharpbw` | bool | `False` | Force sharp-RD bandwidth in fuzzy design [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L21] |
| `all` | bool | `None` | If True, report all estimation methods [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L22] |
| `subset` | numpy array (bool/index) | `None` | Subset of observations to use [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L22] |
| `masspoints` | str | `"adjust"` | Mass points: `"adjust"`, `"check"`, `"off"` [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L22] |
| `bwcheck` | int | `None` | Min unique observations in bandwidth [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L23] |
| `bwrestrict` | bool | `True` | Restrict bandwidth to range of x [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L23] |
| `stdvars` | bool | `True` | Standardize x, y for bandwidth selection [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L23] |
| `data` | pandas DataFrame | `None` | Optional DataFrame with y, x columns [verified: Python/rdrobust/src/rdrobust/rdrobust.py#L24] |

#### Return Object

Returns an `rdrobust_output` object (defined in `rdrobust.funs`) with the following attributes:

| Attribute | Type | Description |
|-----------|------|-------------|
| `.Estimate` | pandas DataFrame | Summary: tau.us, tau.bc, se.us, se.rb |
| `.bws` | pandas DataFrame (2×2) | Bandwidth matrix: rows = h, b; cols = left, right |
| `.coef` | pandas DataFrame (3×1) | Point estimates: Conventional, Bias-Corrected, Robust |
| `.se` | pandas DataFrame (3×1) | Standard errors for each method |
| `.z` | pandas DataFrame (3×1) | z-statistics |
| `.pv` | pandas DataFrame (3×1) | p-values |
| `.ci` | pandas DataFrame (3×2) | Confidence intervals [lower, upper] |
| `.beta_p_l` | numpy array | Left-side polynomial coefficients (outcome) |
| `.beta_p_r` | numpy array | Right-side polynomial coefficients (outcome) |
| `.beta_T_p_l` | numpy array | Left-side coefficients (first-stage, fuzzy) |
| `.beta_T_p_r` | numpy array | Right-side coefficients (first-stage, fuzzy) |
| `.V_cl_l` | numpy array | Conventional VCE matrix, left |
| `.V_cl_r` | numpy array | Conventional VCE matrix, right |
| `.V_rb_l` | numpy array | Robust VCE matrix, left |
| `.V_rb_r` | numpy array | Robust VCE matrix, right |
| `.N` | list(2) | Total sample size [left, right] |
| `.N_h` | list(2) | Effective sample size [left, right] |
| `.N_b` | list(2) | Bias-band sample size [left, right] |
| `.M` | list(2) | Unique observations [left, right] |
| `.tau_cl` | float | Conventional RD estimate |
| `.tau_bc` | float | Bias-corrected RD estimate |
| `.c` | float | Cutoff value used |
| `.p` | int | Polynomial order |
| `.q` | int | Bias polynomial order |
| `.bias` | list(2) | Estimated bias [left, right] |
| `.kernel` | str | Kernel type used |
| `.vce` | str | VCE method used |
| `.bwselect` | str | BW selection method |
| `.level` | float | Confidence level |
| `.masspoints` | str | Mass points option |
| `.rdmodel` | str | Model description string |
| `.n_clust` | int | Number of clusters |
| `.coef_covs` | numpy array | Covariate coefficients |
| `.tau_T` | float | First-stage estimate (fuzzy only) |
| `.se_T` | float | First-stage SE (fuzzy only) |
| `.z_T` | float | First-stage z-stat (fuzzy only) |
| `.pv_T` | float | First-stage p-value (fuzzy only) |
| `.ci_T` | numpy array | First-stage CI (fuzzy only) |

#### Usage Example

```python
import numpy as np
from rdrobust import rdrobust, rdrobust_RDsenate

# Load built-in dataset
data = rdrobust_RDsenate()
y = data.vote.values
x = data.margin.values

# Sharp RD estimation
rd = rdrobust(y, x)
print(rd)
# =============================================================================
#         Method     Coef. Std. Err.         z     P>|z|      CI Lower   CI Upper
# =============================================================================
#   Conventional     7.414     1.459     5.081     0.000         4.554     10.274
#   Bias-Corrected   7.640     1.459     5.236     0.000         4.780     10.500
#        Robust      7.640     1.697     4.502     0.000         4.314     10.966
# =============================================================================

# Access results
rd.coef        # array of 3 point estimates
rd.bws         # 2x2 bandwidth matrix
rd.N_h         # effective sample sizes

# Custom bandwidth and kernel
rd2 = rdrobust(y, x, h=10, kernel="epa", vce="hc1")

# With pandas DataFrame
import pandas as pd
df = pd.DataFrame({'vote': y, 'margin': x})
rd3 = rdrobust(y=None, x=None, data=df)
```

---

### rdbwselect()

Implements bandwidth selection procedures for local-polynomial RD estimation.

#### Signature

```python
# File: Python/rdrobust/src/rdrobust/rdbwselect.py, Lines 13–18
def rdbwselect(y, x, c=None, fuzzy=None, deriv=None, p=None, q=None,
               covs=None, covs_drop=True, kernel="tri", weights=None,
               bwselect="mserd", vce="nn", cluster=None, nnmatch=3,
               scaleregul=1, sharpbw=False, all=None, subset=None,
               masspoints="adjust", bwcheck=None, bwrestrict=True,
               stdvars=True, prchk=True, data=None):
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `y` | numpy array | *required* | Dependent (outcome) variable [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L13] |
| `x` | numpy array | *required* | Running variable [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L13] |
| `c` | float | `None` (→ 0) | RD cutoff point [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L13] |
| `fuzzy` | numpy array | `None` | Treatment status for Fuzzy RD [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L13] |
| `deriv` | int | `None` (→ 0) | Derivative order [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L13] |
| `p` | int | `None` (→ 1) | Polynomial order [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L13] |
| `q` | int | `None` (→ p+1) | Bias polynomial order [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L13] |
| `covs` | numpy array or DataFrame | `None` | Additional covariates [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L14] |
| `covs_drop` | bool | `True` | Drop collinear covariates [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L14] |
| `kernel` | str | `"tri"` | Kernel function: `"tri"`, `"epa"`, `"uni"` [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L14] |
| `weights` | numpy array | `None` | Observation weights [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L14] |
| `bwselect` | str | `"mserd"` | Bandwidth selection method [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L15] |
| `vce` | str | `"nn"` | Variance estimator [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L15] |
| `cluster` | numpy array | `None` | Cluster ID variable [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L15] |
| `nnmatch` | int | `3` | Min neighbors for NN variance [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L15] |
| `scaleregul` | float | `1` | Regularization scaling [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L16] |
| `sharpbw` | bool | `False` | Force sharp BW in fuzzy [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L16] |
| `all` | bool | `None` | Report all BW methods [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L16] |
| `subset` | numpy array | `None` | Subset of observations [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L16] |
| `masspoints` | str | `"adjust"` | Mass points handling [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L17] |
| `bwcheck` | int | `None` | Min unique obs in bandwidth [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L17] |
| `bwrestrict` | bool | `True` | Restrict BW to range of x [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L17] |
| `stdvars` | bool | `True` | Standardize x, y [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L18] |
| `prchk` | bool | `True` | Print checks during execution [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L18] |
| `data` | pandas DataFrame | `None` | Optional DataFrame [verified: Python/rdrobust/src/rdrobust/rdbwselect.py#L18] |

#### Return Object

Returns a tuple `(bws, bwselect)`:

| Index | Type | Description |
|-------|------|-------------|
| `[0]` | pandas DataFrame | Bandwidth results table (h_left, h_right, b_left, b_right) |
| `[1]` | str | Bandwidth selection method used |

#### Usage Example

```python
import numpy as np
from rdrobust import rdbwselect, rdrobust_RDsenate

# Load data
data = rdrobust_RDsenate()
y = data.vote.values
x = data.margin.values

# Default bandwidth selection
bw = rdbwselect(y, x)
print(bw[0])  # DataFrame of bandwidths
#         h_left   h_right    b_left   b_right
# mserd   17.71     17.71     28.04     28.04

print(bw[1])  # "mserd"

# All methods
bw_all = rdbwselect(y, x, all=True)
print(bw_all[0])

# Custom settings
bw2 = rdbwselect(y, x, kernel="epa", p=2, vce="hc1")
```

---

### rdplot()

Implements RD plots with binned scatter points and global polynomial fits using plotnine (ggplot2 for Python).

#### Signature

```python
# File: Python/rdrobust/src/rdrobust/rdplot.py, Lines 16–23
def rdplot(y, x, c=0, p=4, nbins=None, binselect="esmv", scale=None,
           kernel="uni", weights=None, h=None,
           covs=None, covs_eval="mean", covs_drop=True,
           support=None, subset=None, masspoints="adjust",
           hide=False, ci=None, shade=False,
           title=None, x_label=None, y_label=None, x_lim=None,
           y_lim=None, col_dots=None, col_lines=None,
           data=None):
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `y` | numpy array | *required* | Dependent (outcome) variable [verified: Python/rdrobust/src/rdrobust/rdplot.py#L16] |
| `x` | numpy array | *required* | Running variable [verified: Python/rdrobust/src/rdrobust/rdplot.py#L16] |
| `c` | float | `0` | RD cutoff point [verified: Python/rdrobust/src/rdrobust/rdplot.py#L16] |
| `p` | int | `4` | Global polynomial order for fit [verified: Python/rdrobust/src/rdrobust/rdplot.py#L16] |
| `nbins` | int or list(2) | `None` (auto) | Number of bins [left, right] [verified: Python/rdrobust/src/rdrobust/rdplot.py#L16] |
| `binselect` | str | `"esmv"` | Bin selection: `"es"`, `"espr"`, `"esmv"`, `"qs"`, `"qspr"`, `"qsmv"` [verified: Python/rdrobust/src/rdrobust/rdplot.py#L16] |
| `scale` | float or list(2) | `None` (→ 1) | Bin-number scaling factor [verified: Python/rdrobust/src/rdrobust/rdplot.py#L16] |
| `kernel` | str | `"uni"` | Kernel: `"tri"`, `"epa"`, `"uni"` [verified: Python/rdrobust/src/rdrobust/rdplot.py#L17] |
| `weights` | numpy array | `None` | Observation weights [verified: Python/rdrobust/src/rdrobust/rdplot.py#L17] |
| `h` | float or list(2) | `None` | Bandwidth for polynomial fit [verified: Python/rdrobust/src/rdrobust/rdplot.py#L17] |
| `covs` | numpy array or DataFrame | `None` | Additional covariates [verified: Python/rdrobust/src/rdrobust/rdplot.py#L18] |
| `covs_eval` | str | `"mean"` | Covariate evaluation: `"mean"` or `"0"` [verified: Python/rdrobust/src/rdrobust/rdplot.py#L18] |
| `covs_drop` | bool | `True` | Drop collinear covariates [verified: Python/rdrobust/src/rdrobust/rdplot.py#L18] |
| `support` | list(2) | `None` | Support (range) of running variable [verified: Python/rdrobust/src/rdrobust/rdplot.py#L19] |
| `subset` | numpy array | `None` | Subset of observations [verified: Python/rdrobust/src/rdrobust/rdplot.py#L19] |
| `masspoints` | str | `"adjust"` | Mass points: `"adjust"`, `"check"`, `"off"` [verified: Python/rdrobust/src/rdrobust/rdplot.py#L19] |
| `hide` | bool | `False` | Suppress plot display [verified: Python/rdrobust/src/rdrobust/rdplot.py#L20] |
| `ci` | float | `None` (→ 0) | CI level for bin means (0 = none) [verified: Python/rdrobust/src/rdrobust/rdplot.py#L20] |
| `shade` | bool | `False` | Shade CI region [verified: Python/rdrobust/src/rdrobust/rdplot.py#L20] |
| `title` | str | `None` | Plot title [verified: Python/rdrobust/src/rdrobust/rdplot.py#L21] |
| `x_label` | str | `None` | X-axis label [verified: Python/rdrobust/src/rdrobust/rdplot.py#L21] |
| `y_label` | str | `None` | Y-axis label [verified: Python/rdrobust/src/rdrobust/rdplot.py#L21] |
| `x_lim` | list(2) | `None` | X-axis limits [verified: Python/rdrobust/src/rdrobust/rdplot.py#L21] |
| `y_lim` | list(2) | `None` | Y-axis limits [verified: Python/rdrobust/src/rdrobust/rdplot.py#L22] |
| `col_dots` | str | `None` | Color for scatter dots [verified: Python/rdrobust/src/rdrobust/rdplot.py#L22] |
| `col_lines` | str | `None` | Color for polynomial lines [verified: Python/rdrobust/src/rdrobust/rdplot.py#L22] |
| `data` | pandas DataFrame | `None` | Optional DataFrame [verified: Python/rdrobust/src/rdrobust/rdplot.py#L23] |

#### Return Object

Returns an `rdplot_output` object (defined in `rdrobust.funs`) with the following attributes:

| Attribute | Type | Description |
|-----------|------|-------------|
| `.rdplot` | plotnine ggplot | The RD plot object |
| `.coef` | dict | Polynomial coefficients {Left, Right} |
| `.vars_bins` | pandas DataFrame | Binned statistics (midpoints, means, SEs) |
| `.vars_poly` | pandas DataFrame | Polynomial fit values |
| `.J` | list(2) | Number of bins [left, right] |
| `.J_IMSE` | list(2) | IMSE-optimal bins |
| `.J_MV` | list(2) | Mimicking-variance bins |
| `.scale` | list(2) | Scale factors [left, right] |
| `.rscale` | list(2) | Relative scale to IMSE-optimal |
| `.bin_avg` | list(2) | Average bin length [left, right] |
| `.bin_med` | list(2) | Median bin length [left, right] |
| `.p` | int | Polynomial order |
| `.c` | float | Cutoff value |
| `.h` | list(2) | Bandwidth [left, right] |
| `.N` | list(2) | Sample size [left, right] |
| `.N_h` | list(2) | Effective sample size [left, right] |
| `.binselect` | str | Bin selection method |
| `.kernel` | str | Kernel type |
| `.coef_covs` | numpy array | Covariate coefficients |

#### Usage Example

```python
import numpy as np
from rdrobust import rdplot, rdrobust_RDsenate

# Load data
data = rdrobust_RDsenate()
y = data.vote.values
x = data.margin.values

# Basic RD plot
rdp = rdplot(y, x)

# Customized plot
rdp2 = rdplot(y, x, p=3, nbins=[20, 20],
              title="RD Plot: US Senate Elections",
              x_label="Vote Margin",
              y_label="Vote Share (Next Election)")

# With confidence intervals
rdp3 = rdplot(y, x, ci=95, shade=True)

# Access plotnine object
rdp.rdplot.save("rd_plot.pdf")

# Extract binned data
print(rdp.vars_bins.head())

# Hide plot, return data only
rdp_data = rdplot(y, x, hide=True)
print(f"Bins: Left={rdp_data.J[0]}, Right={rdp_data.J[1]}")
```

---

## Naming Conventions (R vs Python)

| Aspect | R | Python |
|--------|---|--------|
| Parameter separator | `.` (e.g., `x.label`) | `_` (e.g., `x_label`) |
| Missing values | `NULL` | `None` |
| Booleans | `TRUE` / `FALSE` | `True` / `False` |
| Return object | Named list (S3 class) | Class instance (attributes) |
| Access pattern | `result$element` | `result.element` |
| Plot library | ggplot2 | plotnine |
| Matrix type | R matrix | numpy ndarray |
| DataFrame | data.frame | pandas DataFrame |

---

## Bandwidth Selection Methods

| Value | Description |
|-------|-------------|
| `"mserd"` | One common MSE-optimal bandwidth (default) |
| `"msetwo"` | Two separate MSE-optimal bandwidths (left/right) |
| `"msesum"` | MSE-optimal based on sum criterion |
| `"msecomb1"` | min(mserd, msetwo) |
| `"msecomb2"` | median(mserd, msetwo_l, msetwo_r) |
| `"cerrd"` | Coverage Error Rate optimal, common |
| `"certwo"` | CER-optimal, separate left/right |
| `"cersum"` | CER-optimal based on sum criterion |
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

```python
import numpy as np
import pandas as pd
from rdrobust import rdrobust, rdbwselect, rdplot, rdrobust_RDsenate

# Load data
data = rdrobust_RDsenate()
y = data.vote.values
x = data.margin.values

# Step 1: Visualize
rdp = rdplot(y, x,
             title="RD Plot: US Senate Incumbency Advantage",
             x_label="Democratic Vote Margin (t)",
             y_label="Democratic Vote Share (t+1)")

# Step 2: Bandwidth selection
bw = rdbwselect(y, x, all=True)
print(bw[0])

# Step 3: Estimate treatment effect
rd = rdrobust(y, x)
print(rd)

# Step 4: Sensitivity
rd_narrow = rdrobust(y, x, h=rd.bws[0, 0] * 0.75)
rd_wide = rdrobust(y, x, h=rd.bws[0, 0] * 1.5)
rd_p2 = rdrobust(y, x, p=2)
rd_epa = rdrobust(y, x, kernel="epa")

# Step 5: Results
print(f"RD Estimate (robust): {rd.coef[2]:.3f}")
print(f"95% CI (robust): [{rd.ci[2, 0]:.3f}, {rd.ci[2, 1]:.3f}]")
print(f"Bandwidth (h): left={rd.bws[0, 0]:.2f}, right={rd.bws[0, 1]:.2f}")
print(f"Effective N: left={rd.N_h[0]}, right={rd.N_h[1]}")
```

---

## References

- Calonico, S., M. D. Cattaneo, and R. Titiunik (2014). Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs. *Econometrica* 82(6): 2295–2326.
- Calonico, S., M. D. Cattaneo, and M. H. Farrell (2018). On the Effect of Bias Estimation on Coverage Accuracy in Nonparametric Inference. *JASA* 113(522): 767–779.
- Calonico, S., M. D. Cattaneo, M. H. Farrell, and R. Titiunik (2019). Regression Discontinuity Designs Using Covariates. *Review of Economics and Statistics* 101(3): 442–451.
- Calonico, S., M. D. Cattaneo, and M. H. Farrell (2020). Optimal Bandwidth Choice for Robust Bias-Corrected Inference in Regression Discontinuity Designs. *Econometrics Journal* 23(2): 192–210.
# Python Language Reference: rdrobust

> Complete API reference, idioms, return objects, performance optimization, debugging, and post-estimation workflows for the Python implementation of rdrobust.

---

## Installation & Setup

```bash
# PyPI (stable)
pip install rdrobust

# Development version
pip install git+https://github.com/rdpackages/rdrobust.git#subdirectory=Python/rdrobust

# Companion packages
pip install rddensity     # Density tests
pip install rdlocrand     # Local randomization inference
```

**Version requirements**: Python ≥ 3.7; rdrobust ≥ 2.2.0 (for CR2/CR3, formula covs, `data =` argument)

**Dependencies**: `numpy`, `pandas`, `scipy`, `matplotlib` (for rdplot)

```python
import numpy as np
import pandas as pd
from rdrobust import rdrobust, rdbwselect, rdplot
```

---

## API Reference

### `rdrobust(y, x, ...)`

Local polynomial RD estimation with robust bias-corrected confidence intervals.

| Parameter | Type | Default | Description | Notes |
|-----------|------|---------|-------------|-------|
| `y` | array-like | required | Outcome variable | numpy array, pandas Series, or column name (with `data`) |
| `x` | array-like | required | Running variable | Same types as `y` |
| `c` | float | `None` (→ 0) | RD cutoff value | |
| `fuzzy` | array-like | `None` | Treatment indicator for Fuzzy RD | Binary 0/1 |
| `deriv` | int | `None` (→ 0) | Derivative order | 0 = level; 1 = Kink |
| `p` | int | `None` (→ 1) | Polynomial order for point estimation | |
| `q` | int | `None` (→ p+1) | Polynomial order for bias correction | Must be > p |
| `h` | float or list[2] | `None` | Main bandwidth | Scalar or [left, right] |
| `b` | float or list[2] | `None` | Bias bandwidth | Scalar or [left, right] |
| `rho` | float | `None` | Ratio h/b | If h set but b not: rho = 1 |
| `covs` | array/DataFrame/formula str/list | `None` | Additional covariates | See Covariates section |
| `covs_drop` | bool | `True` | Drop collinear covariates | |
| `kernel` | str | `"tri"` | Kernel function | `"tri"`, `"epa"`, `"uni"` |
| `weights` | array-like | `None` | Observation weights | Multiplies kernel |
| `bwselect` | str | `"mserd"` | Bandwidth selection method | See BW Methods table |
| `vce` | str | `"nn"` | Variance estimation method | See VCE Methods table |
| `cluster` | array-like | `None` | Cluster ID variable | Enables cluster-robust VCE |
| `nnmatch` | int | `3` | Min neighbors for NN variance | Only with `vce="nn"` |
| `level` | float | `95` | Confidence level (%) | Range: (0, 100) |
| `scalepar` | float | `1` | Scaling factor for RD parameter | |
| `scaleregul` | float | `1` | Regularization scaling | 0 removes regularization |
| `sharpbw` | bool | `False` | Use sharp BW for fuzzy | |
| `all` | bool | `None` | Report all 3 inference procedures | If True: Conventional + BC + Robust |
| `subset` | array-like (bool) | `None` | Subset selection | Boolean mask |
| `masspoints` | str | `"adjust"` | Mass points handling | `"off"`, `"check"`, `"adjust"` |
| `bwcheck` | int | `None` | Min unique obs in bandwidth | |
| `bwrestrict` | bool | `True` | Restrict BW to range of x | |
| `stdvars` | bool | `True` | Standardize x, y for BW computation | |
| `data` | DataFrame | `None` | pandas DataFrame for variable lookup | Enables column-name syntax |

#### Bandwidth Selection Methods

| Value | Description |
|-------|-------------|
| `"mserd"` | Common MSE-optimal (default) |
| `"msetwo"` | Separate left/right MSE-optimal |
| `"msesum"` | MSE-optimal for sum of estimates |
| `"msecomb1"` | min(mserd, msesum) |
| `"msecomb2"` | median(msetwo, mserd, msesum) per side |
| `"cerrd"` | Common CER-optimal |
| `"certwo"` | Separate left/right CER-optimal |
| `"cersum"` | CER-optimal for sum |
| `"cercomb1"` | min(cerrd, cersum) |
| `"cercomb2"` | median(certwo, cerrd, cersum) per side |

#### VCE Methods

| Value | Description | Requirements |
|-------|-------------|--------------|
| `"nn"` | Nearest-neighbor heteroskedasticity-robust | Default |
| `"hc0"` | HC0 (White) | — |
| `"hc1"` | HC1 (finite-sample corrected) | — |
| `"hc2"` | HC2 (leverage adjusted) | — |
| `"hc3"` | HC3 (jackknife-like) | Most conservative |
| `"cr1"` | Cluster-robust CR1 | Requires `cluster` |
| `"cr2"` | Cluster-robust CR2 (Bell-McCaffrey) | Requires `cluster` |
| `"cr3"` | Cluster-robust CR3 (Pustejovsky-Tipton) | Requires `cluster` |

---

### `rdbwselect(y, x, ...)`

Data-driven bandwidth selection for local polynomial RD estimators.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `y` | array-like | required | Outcome variable |
| `x` | array-like | required | Running variable |
| `c` | float | `None` (→ 0) | Cutoff |
| `fuzzy` | array-like | `None` | Treatment indicator |
| `deriv` | int | `None` (→ 0) | Derivative order |
| `p` | int | `None` (→ 1) | Polynomial order |
| `q` | int | `None` (→ p+1) | Bias polynomial order |
| `covs` | array/DataFrame/str/list | `None` | Covariates |
| `covs_drop` | bool | `True` | Drop collinear |
| `kernel` | str | `"tri"` | Kernel |
| `weights` | array-like | `None` | Weights |
| `bwselect` | str | `"mserd"` | BW method |
| `vce` | str | `"nn"` | VCE method |
| `cluster` | array-like | `None` | Cluster ID |
| `nnmatch` | int | `3` | NN matches |
| `scaleregul` | float | `1` | Regularization |
| `sharpbw` | bool | `False` | Sharp BW for fuzzy |
| `all` | bool | `None` | Report all methods |
| `subset` | array-like | `None` | Subset |
| `masspoints` | str | `"adjust"` | Mass points |
| `bwcheck` | int | `None` | Min unique obs |
| `bwrestrict` | bool | `True` | Restrict to range |
| `stdvars` | bool | `True` | Standardize |
| `data` | DataFrame | `None` | Data frame |

---

### `rdplot(y, x, ...)`

Data-driven RD plots with optimal bin selection.

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `y` | array-like | required | Outcome variable |
| `x` | array-like | required | Running variable |
| `c` | float | `0` | Cutoff |
| `p` | int | `4` | Global polynomial order |
| `nbins` | int or list[2] | `None` | Manual bin count |
| `binselect` | str | `"esmv"` | Bin selection method |
| `scale` | float | `None` | Bin count multiplier |
| `kernel` | str | `"uni"` | Kernel function |
| `weights` | array-like | `None` | Weights |
| `h` | float or list[2] | `None` | Bandwidth |
| `covs` | array/DataFrame/str/list | `None` | Covariates |
| `covs_eval` | str | `"mean"` | Covariate evaluation point |
| `covs_drop` | bool | `True` | Drop collinear |
| `support` | list[2] | `None` | Extended support range |
| `subset` | array-like | `None` | Subset |
| `masspoints` | str | `"adjust"` | Mass points |
| `hide` | bool | `False` | Suppress plot |
| `ci` | float | `None` | CI level |
| `shade` | bool | `False` | Shaded CI |
| `title` | str | `None` | Plot title |
| `x_label` | str | `None` | X-axis label |
| `y_label` | str | `None` | Y-axis label |
| `x_lim` | list[2] | `None` | X-axis limits |
| `y_lim` | list[2] | `None` | Y-axis limits |
| `col_dots` | str | `None` | Dot color |
| `col_lines` | str | `None` | Line color |
| `data` | DataFrame | `None` | Data frame |

---

## Return Object Structure

### `rdrobust` Return Object

The function returns a custom object with the following attributes:

| Attribute | Type | Access | Description |
|-----------|------|--------|-------------|
| `N` | ndarray[2] | `est.N` | Total sample size [left, right] |
| `N_h` | ndarray[2] | `est.N_h` | Effective N within h [left, right] |
| `N_b` | ndarray[2] | `est.N_b` | Effective N within b [left, right] |
| `M` | ndarray[2] | `est.M` | Unique observations per side |
| `c` | float | `est.c` | Cutoff value |
| `p` | int | `est.p` | Polynomial order (estimation) |
| `q` | int | `est.q` | Polynomial order (bias) |
| `bws` | DataFrame[2×2] | `est.bws` | Bandwidths: rows=(h,b), cols=(left,right) |
| `tau_cl` | ndarray[2] | `est.tau_cl` | Conventional left/right estimates |
| `tau_bc` | ndarray[2] | `est.tau_bc` | Bias-corrected left/right estimates |
| `coef` | DataFrame[3×1] | `est.coef` | RD estimates: rows 0,1,2 = conv, bc, robust |
| `se` | DataFrame[3×1] | `est.se` | Standard errors |
| `z` | DataFrame[3×1] | `est.z` | Z-statistics |
| `pv` | DataFrame[3×1] | `est.pv` | P-values |
| `ci` | DataFrame[3×2] | `est.ci` | CIs: rows=(conv,bc,robust), cols=(lower,upper) |
| `bias` | ndarray[2] | `est.bias` | Estimated bias [left, right] |
| `beta_Y_p_l` | ndarray | `est.beta_Y_p_l` | Left polynomial coefficients |
| `beta_Y_p_r` | ndarray | `est.beta_Y_p_r` | Right polynomial coefficients |
| `coef_covs` | ndarray | `est.coef_covs` | Covariate coefficients |
| `V_cl_l` | ndarray | `est.V_cl_l` | Conventional V-Cov, left |
| `V_cl_r` | ndarray | `est.V_cl_r` | Conventional V-Cov, right |
| `V_rb_l` | ndarray | `est.V_rb_l` | Robust V-Cov, left |
| `V_rb_r` | ndarray | `est.V_rb_r` | Robust V-Cov, right |
| `kernel` | str | `est.kernel` | Kernel used |
| `vce` | str | `est.vce` | VCE method |
| `bwselect` | str | `est.bwselect` | BW method |
| `level` | float | `est.level` | Confidence level |
| `masspoints` | str | `est.masspoints` | Mass points option |
| `n_clust` | ndarray[2] | `est.n_clust` | Clusters per side |

### Accessing Results (Critical Index Mapping)

```python
# IMPORTANT: Python is 0-indexed
est = rdrobust(y, x)

# Point estimates
conventional_est = est.coef.iloc[0]    # Index 0 = Conventional
biascorrected_est = est.coef.iloc[1]   # Index 1 = Bias-corrected
robust_est = est.coef.iloc[2]          # Index 2 = Robust (same value as BC)

# Standard errors
conventional_se = est.se.iloc[0]
robust_se = est.se.iloc[2]             # USE THIS for inference

# Confidence intervals
robust_ci_lower = est.ci.iloc[2, 0]    # Row 2, Col 0
robust_ci_upper = est.ci.iloc[2, 1]    # Row 2, Col 1

# P-values
robust_pval = est.pv.iloc[2]           # USE THIS

# Bandwidths
h_left = est.bws.iloc[0, 0]           # Row 0 = h; Col 0 = left
h_right = est.bws.iloc[0, 1]          # Row 0 = h; Col 1 = right
b_left = est.bws.iloc[1, 0]           # Row 1 = b; Col 0 = left
b_right = est.bws.iloc[1, 1]          # Row 1 = b; Col 1 = right
```

---

## Python-Specific Idioms

### DataFrame Integration

```python
import pandas as pd
from rdrobust import rdrobust

# Load data
df = pd.read_csv("rdrobust_senate.csv")

# Method 1: Direct array passing
est = rdrobust(y = df['vote'].values, x = df['margin'].values)

# Method 2: Using data= argument (v2.2.0+)
est = rdrobust(y = 'vote', x = 'margin', data = df)

# Method 3: With column-name covariates
est = rdrobust(y = 'vote', x = 'margin',
               covs = ['class', 'termshouse', 'termssenate'],
               data = df)
```

### Formula Covariates (requires formulaic or patsy)

```python
# Formula string (v2.2.0+)
est = rdrobust(y = 'vote', x = 'margin',
               covs = "~ class + termshouse + I(termssenate**2)",
               data = df)
# Note: requires `formulaic` (preferred) or `patsy` installed
```

### NumPy Array Operations

```python
import numpy as np

# Generate data
np.random.seed(42)
n = 1000
x = np.random.uniform(-1, 1, n)
y = 5 + 3*x + 2*(x >= 0) + np.random.normal(0, 1, n)

# Estimate
est = rdrobust(y = y, x = x, c = 0)
print(est)

# Access specific results
print(f"Robust estimate: {est.coef.iloc[2]:.4f}")
print(f"Robust SE: {est.se.iloc[2]:.4f}")
print(f"Robust p-value: {est.pv.iloc[2]:.4f}")
print(f"Bandwidth (left): {est.bws.iloc[0, 0]:.4f}")
```

### Handling Missing Values

```python
# rdrobust does NOT handle NaN gracefully — clean data first
mask = ~(np.isnan(y) | np.isnan(x))
est = rdrobust(y = y[mask], x = x[mask])

# With DataFrame
df_clean = df.dropna(subset=['vote', 'margin'])
est = rdrobust(y = df_clean['vote'].values, x = df_clean['margin'].values)
```

### Subsetting

```python
# Boolean mask
subset_mask = df['year'].values >= 2000
est = rdrobust(y = df['vote'].values, x = df['margin'].values,
               subset = subset_mask)

# Or filter DataFrame first
df_sub = df[df['year'] >= 2000]
est = rdrobust(y = df_sub['vote'].values, x = df_sub['margin'].values)
```

---

## Performance Optimization

### Large Samples (n > 100,000)

```python
# 1. Use numpy arrays directly (avoid pandas overhead in inner loop)
y_arr = df['outcome'].values.astype(np.float64)
x_arr = df['runvar'].values.astype(np.float64)
est = rdrobust(y = y_arr, x = x_arr)

# 2. Pre-compute bandwidth for repeated estimation
bw = rdbwselect(y = y_arr, x = x_arr)
h_opt = [bw.bws.iloc[0, 0], bw.bws.iloc[0, 1]]
# Use fixed h in loop
for outcome_col in ['y1', 'y2', 'y3']:
    est_i = rdrobust(y = df[outcome_col].values, x = x_arr, h = h_opt)

# 3. Use vce="hc0" for speed (avoids NN distance computation)
est_fast = rdrobust(y = y_arr, x = x_arr, vce = "hc0")

# 4. Reduce covariate matrix size
# Only include covariates that matter for efficiency
```

### Memory Efficiency

```python
# For very large datasets, process in chunks for bandwidth selection:
# Step 1: Compute bandwidth on random subsample
np.random.seed(0)
idx = np.random.choice(len(y_arr), size=min(50000, len(y_arr)), replace=False)
bw = rdbwselect(y = y_arr[idx], x = x_arr[idx])

# Step 2: Use computed bandwidth on full sample
est = rdrobust(y = y_arr, x = x_arr,
               h = [bw.bws.iloc[0,0], bw.bws.iloc[0,1]])
```

### Parallel Processing (for simulations)

```python
from concurrent.futures import ProcessPoolExecutor
import numpy as np

def run_rd_simulation(seed):
    np.random.seed(seed)
    n = 500
    x = np.random.uniform(-1, 1, n)
    y = 2*(x >= 0) + np.random.normal(0, 1, n)
    est = rdrobust(y = y, x = x)
    return est.coef.iloc[2]  # Robust estimate

with ProcessPoolExecutor(max_workers=4) as executor:
    results = list(executor.map(run_rd_simulation, range(1000)))

print(f"Mean estimate: {np.mean(results):.4f}")
print(f"SD: {np.std(results):.4f}")
```

---

## Debugging and Error Handling

### Common Error Messages

| Error | Cause | Fix |
|-------|-------|-----|
| `ValueError: y and x must have the same length` | Mismatched array lengths | Check `len(y) == len(x)` |
| `ValueError: fuzzy must be binary` | Non-0/1 treatment variable | Convert: `fuzzy = (treat > 0).astype(float)` |
| `Insufficient observations` | Too few obs within bandwidth | Use `masspoints="adjust"` or increase `bwcheck` |
| `LinAlgError: Singular matrix` | Collinear covariates | Set `covs_drop=True` or remove redundant covs |
| `TypeError: cannot convert to float` | String/categorical in numeric field | Convert: `y = pd.to_numeric(df['y'], errors='coerce').values` |
| `ModuleNotFoundError: formulaic` | Formula covariates without parser | `pip install formulaic` |

### Type Coercion Requirements

```python
# rdrobust expects float64 arrays — common coercion patterns:
y = np.asarray(y, dtype=np.float64)
x = np.asarray(x, dtype=np.float64)

# From pandas (handles NaN correctly)
y = df['outcome'].to_numpy(dtype=np.float64, na_value=np.nan)

# Boolean subset must be numpy array
subset = np.asarray(df['flag'].values, dtype=bool)
```

### Version Compatibility

| Feature | Minimum Version | Notes |
|---------|-----------------|-------|
| `data=` argument | 2.2.0 | Before: arrays only |
| Formula covariates | 2.2.0 | Requires `formulaic` or `patsy` |
| CR2/CR3 cluster VCE | 2.1.0 | Before: cr1 only |
| `masspoints` option | 1.0.0 | — |
| `stdvars` option | 2.0.0 | — |

---

## Post-Estimation Workflow

### Extracting Results for Reporting

```python
est = rdrobust(y = df['vote'].values, x = df['margin'].values)

# Key results
tau = est.coef.iloc[2]           # Robust point estimate
se = est.se.iloc[2]              # Robust SE
ci_lower = est.ci.iloc[2, 0]    # Robust CI lower
ci_upper = est.ci.iloc[2, 1]    # Robust CI upper
pval = est.pv.iloc[2]           # Robust p-value
h_l = est.bws.iloc[0, 0]       # Bandwidth left
h_r = est.bws.iloc[0, 1]       # Bandwidth right
n_l = est.N_h[0]               # Effective N left
n_r = est.N_h[1]               # Effective N right

print(f"RD Estimate: {tau:.4f} (SE = {se:.4f})")
print(f"95% Robust CI: [{ci_lower:.4f}, {ci_upper:.4f}]")
print(f"p-value: {pval:.4f}")
print(f"Bandwidth: h_l = {h_l:.2f}, h_r = {h_r:.2f}")
print(f"Effective N: {int(n_l)} (left), {int(n_r)} (right)")
```

### Creating Results DataFrame

```python
results = pd.DataFrame({
    'Method': ['Conventional', 'Bias-Corrected', 'Robust'],
    'Estimate': [est.coef.iloc[i] for i in range(3)],
    'SE': [est.se.iloc[i] for i in range(3)],
    'z': [est.z.iloc[i] for i in range(3)],
    'p-value': [est.pv.iloc[i] for i in range(3)],
    'CI Lower': [est.ci.iloc[i, 0] for i in range(3)],
    'CI Upper': [est.ci.iloc[i, 1] for i in range(3)]
})
print(results.to_string(index=False))
```

### Integration with Matplotlib

```python
import matplotlib.pyplot as plt

# Custom RD plot using rdplot data
plt_obj = rdplot(y = df['vote'].values, x = df['margin'].values,
                 hide = True)  # Suppress default plot

# Access bin data and poly data from the returned object
# Then create custom publication plot:
fig, ax = plt.subplots(figsize=(8, 5))
ax.axvline(x=0, color='gray', linestyle='--', linewidth=0.8)
ax.set_xlabel("Vote Margin (t)")
ax.set_ylabel("Vote Share (t+2)")
ax.set_title("Regression Discontinuity: Senate Incumbency")
plt.tight_layout()
plt.savefig("rd_plot.pdf", dpi=300)
```

### Export to LaTeX

```python
# Simple LaTeX table
latex_str = results.to_latex(index=False, float_format="%.4f")
with open("rd_table.tex", "w") as f:
    f.write(latex_str)
```

### Sensitivity Analysis Loop

```python
# Bandwidth sensitivity
base_est = rdrobust(y = y, x = x)
h_opt = base_est.bws.iloc[0, 0]

multipliers = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
sensitivity = []
for m in multipliers:
    h_test = h_opt * m
    est_m = rdrobust(y = y, x = x, h = h_test)
    sensitivity.append({
        'h_mult': m,
        'h': h_test,
        'estimate': est_m.coef.iloc[2],
        'se': est_m.se.iloc[2],
        'pval': est_m.pv.iloc[2],
        'ci_lower': est_m.ci.iloc[2, 0],
        'ci_upper': est_m.ci.iloc[2, 1]
    })

sens_df = pd.DataFrame(sensitivity)
print(sens_df.to_string(index=False))
```

---

## Advanced Usage Patterns

### Fuzzy RD

```python
# Fuzzy RD: treatment determined probabilistically at cutoff
est_fuzzy = rdrobust(y = df['outcome'].values,
                     x = df['score'].values,
                     fuzzy = df['treated'].values)
print(est_fuzzy)

# First-stage diagnostic
est_fs = rdrobust(y = df['treated'].values, x = df['score'].values)
print(f"First stage: {est_fs.coef.iloc[0]:.4f} (p = {est_fs.pv.iloc[2]:.4f})")
```

### Clustering

```python
est_clust = rdrobust(y = df['vote'].values,
                     x = df['margin'].values,
                     cluster = df['state'].values,
                     vce = "cr2")
print(est_clust)
```

### Multiple Outcomes

```python
outcomes = ['vote', 'turnout', 'campaign_spending']
for outcome in outcomes:
    est = rdrobust(y = df[outcome].values, x = df['margin'].values)
    print(f"{outcome}: tau = {est.coef.iloc[2]:.4f}, "
          f"p = {est.pv.iloc[2]:.4f}")
```

### Built-in Dataset

```python
from rdrobust.datasets import rdrobust_RDsenate

# Load built-in senate data
data = rdrobust_RDsenate()
est = rdrobust(y = data['vote'].values, x = data['margin'].values)
print(est)
```

### Covariate Balance Test

```python
covariates = ['class', 'termshouse', 'termssenate']
balance = []
for cov in covariates:
    est_cov = rdrobust(y = df[cov].values, x = df['margin'].values)
    balance.append({
        'Covariate': cov,
        'RD Effect': est_cov.coef.iloc[0],
        'Robust p-val': est_cov.pv.iloc[2]
    })
print(pd.DataFrame(balance).to_string(index=False))
```
