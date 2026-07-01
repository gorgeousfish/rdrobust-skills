# rdplot() — Data-Driven RD Plots

## Overview

`rdplot()` generates statistically optimal regression discontinuity plots using data-driven bin selection. It implements the integrated mean squared error (IMSE)-optimal and mimicking variance (MV)-optimal binning procedures from Calonico, Cattaneo, and Titiunik (2015, *JASA*). The function partitions the running variable into optimally chosen bins, computes bin-level sample averages (or polynomial fits), and overlays a global polynomial fit to visualize the RD treatment effect.

**Key innovation**: Rather than choosing the number of bins by arbitrary rules (e.g., Sturges' rule, Scott's rule), `rdplot()` selects the number of bins based on a formal optimality criterion that minimizes the integrated mean squared error between the true regression function and its binned approximation.

**When to use**:
- As the first step in RD analysis to visualize the discontinuity
- To present RD evidence graphically in papers and presentations
- To inspect functional form and detect non-linearities away from the cutoff
- To complement formal estimation by `rdrobust()`

---

## Theoretical Foundation

### Core Paper

Calonico, S., Cattaneo, M. D., and Titiunik, R. (2015). "Optimal Data-Driven Regression Discontinuity Plots." *Journal of the American Statistical Association*, 110(512): 1753–1769.

### IMSE-Optimal Binning

The Integrated Mean Squared Error criterion selects the number of bins \(J\) to minimize:

\[
\text{IMSE}(J) = \int \text{MSE}(\hat{\mu}_J(x)) \, dx
\]

where \(\hat{\mu}_J(x)\) is the binned estimator (sample mean within each bin). The IMSE-optimal number of bins is:

\[
J_-^{\text{IMSE}} = \lceil \mathcal{C}_-^{\text{IMSE}} \cdot n^{1/3} \rceil, \qquad J_+^{\text{IMSE}} = \lceil \mathcal{C}_+^{\text{IMSE}} \cdot n^{1/3} \rceil
\]

where the constants \(\mathcal{C}_\pm^{\text{IMSE}}\) depend on the bin type (evenly-spaced or quantile-spaced), the second derivative of the regression function, and the conditional variance.

### Mimicking Variance (MV) Criterion

The MV criterion selects the number of bins so that the variability of the binned means mimics the variability of the raw data within each bin:

\[
J_-^{\text{MV}} = \left\lceil \mathcal{C}_-^{\text{MV}} \frac{n}{\log(n)^2} \right\rceil, \qquad J_+^{\text{MV}} = \left\lceil \mathcal{C}_+^{\text{MV}} \frac{n}{\log(n)^2} \right\rceil
\]

The MV method produces **more bins** than IMSE, better capturing data variability at the cost of slightly more visual noise.

---

## Key Distinction: rdplot ≠ rdrobust

**Critical**: The binning optimization in `rdplot()` and the bandwidth optimization in `rdrobust()` solve DIFFERENT problems and should never be conflated.

| Aspect | rdplot() | rdrobust() |
|--------|----------|-----------|
| **Objective** | Minimize IMSE of binned approximation | Minimize MSE (or CER) of local polynomial at cutoff |
| **Output** | Optimal number of bins \(J^*\) | Optimal bandwidth \(h^*\) |
| **Polynomial** | Global polynomial (order `p`, default 4) | Local polynomial (order `p`, default 1) |
| **Scope** | Entire support of running variable | Narrow window around cutoff |
| **Purpose** | Visualization | Point estimation and inference |
| **Default kernel** | Uniform (`"uni"`) | Triangular (`"tri"`) |
| **Default poly order** | 4 (global fit) | 1 (local linear) |

**Common mistake**: Using the number of bins from `rdplot()` to calibrate the bandwidth in `rdrobust()`. These are fundamentally different quantities optimized for different objectives.

---

## Binning Methods

The `binselect` parameter controls how bins are constructed:

| Method | Full Name | Bin Spacing | Optimization | Description |
|--------|-----------|-------------|--------------|-------------|
| `"es"` | Evenly-Spaced | Equal widths | IMSE-optimal | Bins have equal width along x-axis |
| `"qs"` | Quantile-Spaced | Equal counts | IMSE-optimal | Bins contain approximately equal numbers of observations |
| `"espr"` | ES Polynomial Regression | Equal widths | IMSE-optimal (polynomial) | Polynomial regression within bins, IMSE criterion |
| `"qspr"` | QS Polynomial Regression | Equal counts | IMSE-optimal (polynomial) | Polynomial regression within bins, IMSE criterion |
| `"esmv"` | ES Mimicking Variance | Equal widths | MV-optimal | **Default**; more bins, captures data variability |
| `"qsmv"` | QS Mimicking Variance | Equal counts | MV-optimal | Quantile-spaced variant of MV |

### When to Use Each Method

- **`"esmv"` (default)**: Good general-purpose choice. Produces enough bins to show data patterns clearly.
- **`"es"` / `"qs"`**: Fewer bins; smoother appearance; formal IMSE optimality.
- **`"qs"` / `"qsmv"`**: When the running variable has a highly skewed distribution (e.g., test scores clustered at certain values). Ensures each bin has roughly the same number of observations.
- **`"espr"` / `"qspr"`**: When within-bin polynomial regression is desired instead of simple means.

---

## Parameters (Complete)

### Required

| Parameter | Type | Description |
|-----------|------|-------------|
| `y` | numeric vector/array | Dependent (outcome) variable |
| `x` | numeric vector/array | Running (forcing/score) variable |

### Core Plot Settings

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `c` | numeric scalar | 0 | RD cutoff value |
| `p` | integer | 4 | Order of the global polynomial fit displayed on the plot |
| `nbins` | integer or vector(2) | auto (data-driven) | Manual number of bins [left, right]. Overrides `binselect` |
| `binselect` | string | "esmv" | Bin selection method: `es`, `qs`, `espr`, `qspr`, `esmv`, `qsmv` |
| `scale` | numeric or vector(2) | 1 | Scaling factor for the number of bins (e.g., 2 doubles the bins) |

### Kernel & Bandwidth

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `kernel` | string | "uni" | Kernel for local polynomial: `tri`, `epa`, `uni`. Note: default differs from `rdrobust()` |
| `h` | numeric or vector(2) | NULL/None (full range) | Bandwidth restricting the displayed range of x |
| `weights` | numeric vector/varname | NULL/None | Observation weights |

### Covariates

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `covs` | matrix/formula/varlist | NULL/None | Additional covariates to partial out |
| `covs_eval` | string | "mean" | Covariate evaluation point: `"mean"` (at covariate means) or `"0"` (at zero) |
| `covs_drop` | logical/bool | TRUE/True | Drop collinear covariates |

### Display Options

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `hide` | logical/bool | FALSE/False | Suppress plot display (compute statistics only) |
| `ci` | numeric | NULL/None/0 | Confidence level for bin-mean CIs. 0 = no CI display |
| `shade` | logical/bool | FALSE/False | Shade CI region instead of error bars |
| `title` | string | NULL/None | Plot title |
| `x.label` / `x_label` | string | NULL/None | X-axis label |
| `y.label` / `y_label` | string | NULL/None | Y-axis label |
| `x.lim` / `x_lim` | numeric vector(2) | NULL/None | X-axis limits |
| `y.lim` / `y_lim` | numeric vector(2) | NULL/None | Y-axis limits |
| `col.dots` / `col_dots` | string | NULL/None | Color of scatter dots |
| `col.lines` / `col_lines` | string | NULL/None | Color of polynomial fit lines |

### Advanced

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `support` | numeric vector(2) | NULL/None | Support (domain) of running variable to use |
| `subset` | logical/index vector | NULL/None | Subset of observations |
| `masspoints` | string | "adjust" | Mass points handling: `adjust`, `check`, `off` |
| `data` | data.frame/DataFrame | NULL/None | Optional data frame (R/Python only) |

### Platform-Specific

| Parameter | Platform | Description |
|-----------|----------|-------------|
| `ginv.tol` | R only | Matrix inversion tolerance (default: 1e-20) |
| `genvars` | Stata only | Generate Stata variables with bin/plot data |
| `graph_options` | Stata only | Passthrough for Stata graph customization |
| `nochecks` | Stata only | Skip input validation |
| `PRECision` | Stata only | Numeric precision control |

---

## Usage Patterns

### Basic RD Plot

```r
# R
library(rdrobust)
rdplot(y, x, c = 0)
```

```python
# Python
from rdrobust import rdplot
rdplot(y, x, c = 0)
```

```stata
* Stata
rdplot y x, c(0)
```

### Custom Number of Bins

```r
# R — 20 bins on each side
rdplot(y, x, c = 0, nbins = c(20, 20))
```

```python
# Python
rdplot(y, x, c = 0, nbins = [20, 20])
```

```stata
* Stata
rdplot y x, c(0) nbins(20 20)
```

### Quantile-Spaced Binning (for Skewed X)

```r
# R
rdplot(y, x, c = 0, binselect = "qs")
```

```python
# Python
rdplot(y, x, c = 0, binselect = "qs")
```

```stata
* Stata
rdplot y x, c(0) binselect(qs)
```

### With Confidence Intervals

```r
# R — 95% CI on bin means
rdplot(y, x, c = 0, ci = 95)

# R — shaded CI region
rdplot(y, x, c = 0, ci = 95, shade = TRUE)
```

```python
# Python
rdplot(y, x, c = 0, ci = 95, shade = True)
```

```stata
* Stata
rdplot y x, c(0) ci(95) shade
```

### Restricting Display Range

```r
# R — show only observations within bandwidth h = 50
rdplot(y, x, c = 0, h = 50)
```

```python
# Python
rdplot(y, x, c = 0, h = 50)
```

```stata
* Stata
rdplot y x, c(0) h(50)
```

### Lower-Order Polynomial Fit

```r
# R — linear fit (p = 1) instead of quartic
rdplot(y, x, c = 0, p = 1)
```

```python
# Python
rdplot(y, x, c = 0, p = 1)
```

```stata
* Stata
rdplot y x, c(0) p(1)
```

### Customized Labels and Colors

```r
# R
rdplot(y, x, c = 0,
       title = "RD Effect on Test Scores",
       x.label = "Running Variable (Distance to Cutoff)",
       y.label = "Outcome",
       col.dots = "darkgray",
       col.lines = "blue")
```

```python
# Python
rdplot(y, x, c = 0,
       title = "RD Effect on Test Scores",
       x_label = "Running Variable (Distance to Cutoff)",
       y_label = "Outcome",
       col_dots = "darkgray",
       col_lines = "blue")
```

### Suppress Plot, Retrieve Data Only

```r
# R
out <- rdplot(y, x, c = 0, hide = TRUE)
# Access binned statistics
head(out$vars_bins)
```

```python
# Python
out = rdplot(y, x, c = 0, hide = True)
print(out.vars_bins)
```

```stata
* Stata — generate variables without displaying
rdplot y x, c(0) hide genvars
```

---

## Return Object Interpretation

| Element | R Access | Python Access | Stata Access | Description |
|---------|----------|--------------|--------------|-------------|
| Plot object | `$rdplot` | `.rdplot` | (displayed) | ggplot2 / plotnine object |
| Binned data | `$vars_bins` | `.vars_bins` | (via `genvars`) | DataFrame with bin endpoints, means, counts |
| Polynomial fit | `$vars_poly` | `.vars_poly` | — | DataFrame with polynomial curve values |
| Polynomial coefs | `$coef` | `.coef` | `e(coef_l)`, `e(coef_r)` | Global polynomial coefficients [Left, Right] |
| Bins selected | `$J` | `.J` | `e(J_star_l)`, `e(J_star_r)` | Optimal number of bins [left, right] |
| IMSE-optimal bins | `$J_IMSE` | `.J_IMSE` | — | IMSE-optimal bin count |
| MV-optimal bins | `$J_MV` | `.J_MV` | — | Mimicking-variance bin count |
| Scale factors | `$scale` | `.scale` | — | Applied scaling [left, right] |
| Bin average length | `$bin_avg` | `.bin_avg` | — | Average bin width [left, right] |
| Bin median length | `$bin_med` | `.bin_med` | — | Median bin width [left, right] |
| Polynomial order | `$p` | `.p` | `e(p)` | Global polynomial order used |
| Cutoff | `$c` | `.c` | `e(c)` | Cutoff value |
| Bandwidth | `$h` | `.h` | — | Display bandwidth [left, right] |
| Sample size | `$N` | `.N` | `e(N_l)`, `e(N_r)` | Total observations [left, right] |
| Effective N | `$N_h` | `.N_h` | `e(N_h_l)`, `e(N_h_r)` | Observations in display range |
| Bin method | `$binselect` | `.binselect` | `e(binselect)` | Bin selection method used |

### Reading the Plot

The output plot displays:
1. **Dots**: Bin-level sample means (y-axis) plotted at bin midpoints (x-axis)
2. **Lines**: Global polynomial fit (order `p`) computed separately on each side of the cutoff
3. **Vertical line**: Location of the cutoff `c`
4. **Jump at cutoff**: Visual estimate of the treatment effect

**What to look for**:
- A visible discontinuity (jump) at the cutoff suggests a treatment effect
- Smooth polynomial fits on each side validate the continuity assumption away from the cutoff
- Scatter of dots around the fitted line indicates the noise level
- Unusual patterns (e.g., non-monotonicity) may suggest model misspecification

---

## Common Mistakes

1. **Using rdplot bin count to set rdrobust bandwidth**: The IMSE-optimal number of bins is for VISUALIZATION. It has no direct relationship to the MSE-optimal bandwidth for estimation. These are different optimizations targeting different objectives.

2. **Not showing enough of the running variable range**: Restricting `h` too aggressively hides evidence about functional form away from the cutoff. Show enough range to assess smoothness.

3. **Using too high a polynomial order**: The default `p = 4` provides a flexible global fit. However, very high polynomial orders can produce Runge-phenomenon oscillations. Use `p = 1` or `p = 2` for simpler displays.

4. **Ignoring the global polynomial nature**: `rdplot()` fits a GLOBAL polynomial on each side (not local). This is why `p = 4` is the default—it provides flexibility across the entire support. This differs from `rdrobust()` which uses a LOCAL polynomial.

5. **Over-interpreting the visual jump**: The plotted discontinuity is based on the global polynomial fit, not the bias-corrected local estimate from `rdrobust()`. Always complement with formal inference.

---

## References

- Calonico, S., Cattaneo, M. D., and Titiunik, R. (2015). "Optimal Data-Driven Regression Discontinuity Plots." *Journal of the American Statistical Association*, 110(512): 1753–1769.
- Cattaneo, M. D., Idrobo, N., and Titiunik, R. (2020). *A Practical Introduction to Regression Discontinuity Designs: Foundations.* Cambridge Elements, Sections 3.1–3.2.

---

*See also*: [rdrobust.md](rdrobust.md) for estimation and inference | [rdbwselect.md](rdbwselect.md) for bandwidth selection
