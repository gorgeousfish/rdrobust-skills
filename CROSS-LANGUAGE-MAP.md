# Cross-Language Parameter & Object Mapping

## Package: rdrobust

> Authoritative reference for all cross-language parameter naming, default values, and return object access patterns. All downstream files (SKILL.md, lang/*.md, examples/) MUST use parameter names consistent with this table.

---

## Primary Function: `rdrobust`

### Parameter Mapping Table

| Functionality | R Parameter | Python Parameter | Stata Syntax | Difference Notes |
|--------------|-------------|-----------------|--------------|-----------------|
| Outcome variable | `y` | `y` | positional arg 1 (`depvar`) | Identical logic; Stata uses varname in memory |
| Running variable | `x` | `x` | positional arg 2 (`runvar`) | Identical logic; Stata uses varname in memory |
| Cutoff value | `c = NULL` (default 0) | `c = None` (default 0) | `c(#)` default 0 | Identical default; Stata option syntax |
| Fuzzy treatment | `fuzzy = NULL` | `fuzzy = None` | `fuzzy(fuzzyvar [sharpbw])` | Stata embeds `sharpbw` inside option |
| Derivative order | `deriv = NULL` (default 0) | `deriv = None` (default 0) | `deriv(#)` default 0 | Identical |
| Polynomial order (estimation) | `p = NULL` (default 1) | `p = None` (default 1) | `p(#)` default 1 | Identical |
| Polynomial order (bias) | `q = NULL` (default 2) | `q = None` (default 2) | `q(#)` default 2 | Identical |
| Main bandwidth | `h = NULL` | `h = None` | `h(# #)` | R/Python: scalar or length-2 vector; Stata: one or two numbers in option |
| Bias bandwidth | `b = NULL` | `b = None` | `b(# #)` | Same as `h` |
| Rho (b = h/rho) | `rho = NULL` | `rho = None` | `rho(#)` | Identical |
| Covariates | `covs = NULL` (formula/matrix/character) | `covs = None` (array/DataFrame/formula string) | `covs(varlist)` | **Format differs**: R uses `~ z1 + z2`; Python uses array/formula string; Stata uses varlist |
| Drop collinear covariates | `covs_drop = TRUE` | `covs_drop = True` | `covs_drop(pinv|invsym|off)` | R/Python: logical; Stata has three modes (`pinv` default) |
| Generalized inverse tolerance | `ginv.tol = 1e-20` | N/A | N/A | **R-only parameter** |
| Kernel function | `kernel = "tri"` | `kernel = "tri"` | `kernel(triangular)` | Abbreviations accepted in all; Stata uses full name by default |
| Observation weights | `weights = NULL` | `weights = None` | `weights(weightsvar)` | R/Python: numeric vector; Stata: variable name |
| Bandwidth selection | `bwselect = "mserd"` | `bwselect = "mserd"` | `bwselect(mserd)` | Identical options across all languages |
| VCE method | `vce = "nn"` | `vce = "nn"` | `vce(nn [nnmatch])` | Stata embeds nnmatch/clustervar in vce(); R/Python use separate args |
| Cluster variable | `cluster = NULL` | `cluster = None` | embedded in `vce(cluster clvar)` or `vce(cr1 clvar)` | **Major difference**: Stata embeds cluster var inside `vce()` option |
| NN match count | `nnmatch = 3` | `nnmatch = 3` | embedded in `vce(nn #)` | R/Python: separate arg; Stata: inside `vce()` |
| Confidence level | `level = 95` | `level = 95` | `level(#)` | Identical |
| Scale parameter | `scalepar = 1` | `scalepar = 1` | `scalepar(#)` | Identical |
| Regularization scale | `scaleregul = 1` | `scaleregul = 1` | `scaleregul(#)` | Identical |
| Sharp BW for fuzzy | `sharpbw = FALSE` | `sharpbw = False` | embedded in `fuzzy(var sharpbw)` | Stata embeds inside `fuzzy()` option |
| Subset selection | `subset = NULL` | `subset = None` | `if/in` qualifier | **Stata uses Stata's native `if/in`** syntax |
| Mass points handling | `masspoints = "adjust"` | `masspoints = "adjust"` | `masspoints(adjust)` | Identical options |
| BW check (min obs) | `bwcheck = NULL` | `bwcheck = None` | `bwcheck(#)` | Identical |
| BW restrict to range | `bwrestrict = TRUE` | `bwrestrict = True` | `bwrestrict(on)` | R/Python: logical; Stata: `on`/`off` |
| Standardize variables | `stdvars = TRUE` | `stdvars = True` | `stdvars(on)` | R/Python: logical; Stata: `on`/`off` |
| Data frame | `data = NULL` | `data = None` | N/A (data in memory) | **Stata has no `data` arg** — uses variables loaded in memory |
| Report all estimates | via `summary(est, all=TRUE)` | `all = None` (in function call) | `all` (flag) | ⚠️ **R moved `all` from rdrobust() to summary() in v4.0.0** |
| Detail output | via `summary(est, detail=TRUE)` | N/A | `detail` (flag) | **R: method on summary()**; Stata: display flag |
| Precision control | N/A | N/A | `precision(double|single)` | **Stata-only parameter** |
| Skip validation | N/A | N/A | `nochecks` (flag) | **Stata-only parameter** |
| Suppress warnings | N/A | N/A | `nowarnings` (flag) | **Stata-only parameter** |
| Leverage diagnostics | N/A | N/A | `vleverage` (flag) | **Stata-only parameter** |

---

### Return Object Mapping Table

| Element | R Access | Python Access | Stata Access | Notes |
|---------|----------|--------------|--------------|-------|
| Conventional estimate | `est$coef[1]` | `est.coef.iloc[0]` | `e(tau_cl)` | Row 1 in R = index 0 in Python |
| Bias-corrected estimate | `est$coef[2]` | `est.coef.iloc[1]` | `e(tau_bc)` | Same indexing pattern |
| Conventional SE | `est$se[1]` | `est.se.iloc[0]` | `e(se_tau_cl)` | — |
| Robust SE | `est$se[3]` | `est.se.iloc[2]` | `e(se_tau_rb)` | R row 3 = Python index 2 |
| Conventional CI | `est$ci[1,]` | `est.ci.iloc[0,:]` | `e(ci_l_cl)`, `e(ci_r_cl)` | Stata splits into lower/upper scalars |
| Robust CI | `est$ci[3,]` | `est.ci.iloc[2,:]` | `e(ci_l_rb)`, `e(ci_r_rb)` | Stata splits into lower/upper scalars |
| Conventional p-value | `est$pv[1]` | `est.pv.iloc[0]` | `e(pv_cl)` | — |
| Robust p-value | `est$pv[3]` | `est.pv.iloc[2]` | `e(pv_rb)` | — |
| Z-statistic (conventional) | `est$z[1]` | `est.z.iloc[0]` | derived from `e(tau_cl)/e(se_tau_cl)` | Stata does not store z directly |
| Z-statistic (robust) | `est$z[3]` | `est.z.iloc[2]` | derived | — |
| Bandwidth h (left) | `est$bws[1,1]` | `est.bws.iloc[0,0]` | `e(h_l)` | Matrix row 1 = estimation BW |
| Bandwidth h (right) | `est$bws[1,2]` | `est.bws.iloc[0,1]` | `e(h_r)` | — |
| Bandwidth b (left) | `est$bws[2,1]` | `est.bws.iloc[1,0]` | `e(b_l)` | Matrix row 2 = bias BW |
| Bandwidth b (right) | `est$bws[2,2]` | `est.bws.iloc[1,1]` | `e(b_r)` | — |
| N total (left) | `est$N[1]` | `est.N[0]` | `e(N_l)` | — |
| N total (right) | `est$N[2]` | `est.N[1]` | `e(N_r)` | — |
| N effective (left) | `est$N_h[1]` | `est.N_h[0]` | `e(N_h_l)` | Within bandwidth h |
| N effective (right) | `est$N_h[2]` | `est.N_h[1]` | `e(N_h_r)` | — |
| N bias (left) | `est$N_b[1]` | `est.N_b[0]` | `e(N_b_l)` | Within bandwidth b |
| N bias (right) | `est$N_b[2]` | `est.N_b[1]` | `e(N_b_r)` | — |
| Polynomial p | `est$p` | `est.p` | `e(p)` | — |
| Polynomial q | `est$q` | `est.q` | `e(q)` | — |
| Cutoff | `est$c` | `est.c` | `e(c)` | — |
| Kernel | `est$kernel` | `est.kernel` | `e(kernel)` | String |
| BW selection method | `est$bwselect` | `est.bwselect` | `e(bwselect)` | String |
| VCE method | `est$vce` | `est.vce` | `e(vce_select)` | — |
| Estimated bias (left) | `est$bias[1]` | `est.bias[0]` | `e(bias_l)` | — |
| Estimated bias (right) | `est$bias[2]` | `est.bias[1]` | `e(bias_r)` | — |
| Covariate coefficients | `est$coef_covs` | `est.coef_covs` | `e(coef_covs)` | Only when `covs` specified |
| V conventional (left) | `est$V_cl_l` | `est.V_cl_l` | `e(V_cl_l)` | Variance-covariance matrix |
| V conventional (right) | `est$V_cl_r` | `est.V_cl_r` | `e(V_cl_r)` | — |
| V robust (left) | `est$V_rb_l` | `est.V_rb_l` | `e(V_rb_l)` | — |
| V robust (right) | `est$V_rb_r` | `est.V_rb_r` | `e(V_rb_r)` | — |
| Number of clusters | `est$n_clust` | `est.n_clust` | `e(n_clust)` | Only with clustering |
| Mass points count | `est$M` | `est.M` | N/A (reported in output) | — |
| Model description | `est$rdmodel` | `est.rdmodel` | `e(title)` | R: string; Python: string; Stata: macro |
| First-stage coef (fuzzy) | `est$tau_T` | `est.tau_T` | `e(tau_T_cl)`, `e(tau_T_bc)` | Only in fuzzy RD |
| First-stage SE (fuzzy) | `est$se_T` | `est.se_T` | `e(se_tau_T_cl)`, `e(se_tau_T_rb)` | Only in fuzzy RD |

---

### Companion Function: `rdbwselect`

#### Parameter Mapping Table

| Functionality | R Parameter | Python Parameter | Stata Syntax | Notes |
|--------------|-------------|-----------------|--------------|-------|
| Report all BW methods | `all = NULL` | `all = None` | `all` (flag) | Identical logic |
| Print checks | N/A | `prchk = True` | N/A | **Python-only parameter** |
| Generalized inverse tolerance | `ginv.tol = 1e-20` | N/A | N/A | **R-only parameter** |
| Skip validation | N/A | N/A | `nochecks` (flag) | **Stata-only parameter** |
| Precision control | N/A | N/A | `precision(double|single)` | **Stata-only parameter** |
| Other parameters | Same as `rdrobust` (excluding `h`, `b`, `rho`, `level`, `scalepar`) | Same | Same | Subset of rdrobust parameters |

#### Return Object Mapping Table

| Return Element | R Access | Python Access | Stata Access | Notes |
|---------------|----------|--------------|--------------|-------|
| BW matrix | `bw$bws` | `bw[0]` (DataFrame) | `e(h_mserd)`, `e(b_mserd)` etc. | R: matrix with named rows; Python: tuple element 0; Stata: individual scalars |
| BW method string | `bw$bwselect` | `bw[1]` (string) | `e(bwselect)` | Python returns tuple `(DataFrame, string)` |
| Polynomial p | `bw$p` | — | `e(p)` | — |
| Polynomial q | `bw$q` | — | `e(q)` | — |
| Cutoff | `bw$c` | — | `e(c)` | — |
| Kernel | `bw$kernel` | — | `e(kernel)` | — |
| Sample size | `bw$N` | — | `e(N_l)`, `e(N_r)` | R: vector [left, right]; Stata: separate scalars |
| Effective N | `bw$N_h` | — | — | R only |
| Unique obs | `bw$M` | — | — | R only |
| VCE method | `bw$vce` | — | `e(vce_type)` | — |
| Mass points | `bw$masspoints` | — | — | R only |
| MSE-RD h | `bw$bws["h","mserd"]` | `bw[0].loc["mserd","h"]` | `e(h_mserd)` | Named access patterns differ |
| MSE-TWO h (left) | `bw$bws["h","msetwo_l"]` | via DataFrame | `e(h_msetwo_l)` | — |
| MSE-TWO h (right) | `bw$bws["h","msetwo_r"]` | via DataFrame | `e(h_msetwo_r)` | — |
| MSE-SUM h | `bw$bws["h","msesum"]` | via DataFrame | `e(h_msesum)` | — |
| CER-RD h | `bw$bws["h","cerrd"]` | via DataFrame | `e(h_cerrd)` | — |
| N clusters | — | — | `e(n_clust)` | Stata only (when clustering) |

---

### Companion Function: `rdplot`

#### Parameter Mapping Table

| Functionality | R Parameter | Python Parameter | Stata Syntax | Notes |
|--------------|-------------|-----------------|--------------|-------|
| Polynomial order | `p = 4` | `p = 4` | `p(#)` default 4 | Identical |
| Number of bins | `nbins = NULL` | `nbins = None` | `nbins(# #)` | — |
| Bin selection | `binselect = "esmv"` | `binselect = "esmv"` | `binselect(esmv)` | Identical options |
| Scale factor | `scale = NULL` | `scale = None` | `scale(#)` | — |
| Hide plot | `hide = FALSE` | `hide = False` | `hide` (flag) | — |
| Confidence intervals | `ci = NULL` | `ci = None` | `ci(#)` | Level as numeric |
| Shaded CI | `shade = FALSE` | `shade = False` | `shade` (flag) | — |
| Title | `title = NULL` | `title = None` | `graph_options(title(...))` | **Stata: embedded in graph options** |
| X-axis label | `x.label = NULL` | `x_label = None` | `graph_options(xtitle(...))` | ⚠️ **R uses `.`, Python uses `_`** |
| Y-axis label | `y.label = NULL` | `y_label = None` | `graph_options(ytitle(...))` | ⚠️ **R uses `.`, Python uses `_`** |
| X-axis limits | `x.lim = NULL` | `x_lim = None` | `graph_options(xscale(range(...)))` | ⚠️ **Naming convention differs** |
| Y-axis limits | `y.lim = NULL` | `y_lim = None` | `graph_options(yscale(range(...)))` | ⚠️ **Naming convention differs** |
| Dot color | `col.dots = NULL` | `col_dots = None` | `graph_options(mcolor(...))` | R uses `.`; Python uses `_` |
| Line color | `col.lines = NULL` | `col_lines = None` | `graph_options(lcolor(...))` | R uses `.`; Python uses `_` |
| Covariate evaluation | `covs_eval = "mean"` | `covs_eval = "mean"` | `covs_eval(mean)` | Identical |
| Support range | `support = NULL` | `support = None` | `support(# #)` | — |
| Generate variables | N/A | N/A | `genvars` (flag) | **Stata-only**: creates variables in dataset |
| Graph options pass-through | N/A | N/A | `graph_options(string asis)` | **Stata-only**: native graph customization |

#### Return Object Mapping Table

| Return Element | R Access | Python Access | Stata Access | Notes |
|---------------|----------|--------------|--------------|-------|
| Polynomial coefficients | `rd$coef` | `rd.coef` | `e(coef_l)`, `e(coef_r)` | R/Python: list [Left, Right]; Stata: matrices |
| Plot object | `rd$rdplot` | `rd.rdplot` | — (graph displayed) | R: ggplot2; Python: plotnine/matplotlib |
| Binned data | `rd$vars_bins` | `rd.vars_bins` | — (use `genvars`) | DataFrame of bin means/counts |
| Polynomial fit | `rd$vars_poly` | `rd.vars_poly` | — | DataFrame of fitted values |
| Bins selected (left) | `rd$J[1]` | `rd.J[0]` | `e(J_star_l)` | Index shift: R=1, Python=0 |
| Bins selected (right) | `rd$J[2]` | `rd.J[1]` | `e(J_star_r)` | Index shift |
| IMSE-optimal bins | `rd$J_IMSE` | `rd.J_IMSE` | — | — |
| Mimicking-variance bins | `rd$J_MV` | `rd.J_MV` | — | — |
| Scale factors | `rd$scale` | `rd.scale` | — | [left, right] |
| Average bin length | `rd$bin_avg` | `rd.bin_avg` | — | [left, right] |
| Median bin length | `rd$bin_med` | `rd.bin_med` | — | [left, right] |
| Polynomial order used | `rd$p` | `rd.p` | `e(p)` | — |
| Cutoff | `rd$c` | `rd.c` | `e(c)` | — |
| Bandwidth | `rd$h` | `rd.h` | — | [left, right] |
| Sample size | `rd$N` | `rd.N` | `e(N_l)`, `e(N_r)` | — |
| Effective sample | `rd$N_h` | `rd.N_h` | `e(N_h_l)`, `e(N_h_r)` | — |
| Bin selection method | `rd$binselect` | `rd.binselect` | `e(binselect)` | String |
| Kernel type | `rd$kernel` | `rd.kernel` | — | — |
| Covariate coefficients | `rd$coef_covs` | `rd.coef_covs` | `e(coef_covs)` | Only when `covs` specified |

---

## Data Input Format Differences

| Aspect | R | Python | Stata |
|--------|---|--------|-------|
| Data container | `data.frame` or numeric vector | `numpy.ndarray` or `pandas.Series` | Variable in memory (loaded via `use`) |
| Missing values | `NA` | `np.nan` | `.` |
| Variable reference | Column name or bare vector | Array/Series or column name string | Variable name in dataset |
| Formula interface | `~ z1 + z2 + factor(g)` | `"~ z1 + z2"` (string; requires `formulaic` or `patsy`) | Not supported (use varlist) |
| Factor expansion | `factor()` in formula, auto-expanded | Not natively supported for covariates | `i.varname` notation |
| Subsetting | `subset` argument (logical vector) | `subset` argument (boolean array) | `if/in` qualifier on command |
| Cluster specification | Separate `cluster` argument | Separate `cluster` argument | Inside `vce(cluster clvar)` |
| Data loading | `read.csv()` / `data()` | `pd.read_csv()` / built-in datasets | `use filename` |
| Built-in dataset | `data(rdrobust_RDsenate)` | `from rdrobust.datasets import rdrobust_RDsenate` | `use rdrobust_senate.dta` |
| Vector construction | `c(1, 2, 3)` | `np.array([1, 2, 3])` | N/A (variables are columns) |
| Two-sided bandwidth | `h = c(12, 15)` | `h = [12, 15]` or `h = np.array([12, 15])` | `h(12 15)` |

---

## Language-Specific Parameters (Exclusive to One Language)

| Parameter | Language | Function | Purpose |
|-----------|----------|----------|---------|
| `ginv.tol` | R only | rdrobust, rdbwselect, rdplot | Tolerance for generalized inverse (MASS::ginv) |
| `prchk` | Python only | rdbwselect | Print preliminary checks to console |
| `nochecks` | Stata only | rdrobust, rdbwselect, rdplot | Skip input validation for speed |
| `nowarnings` | Stata only | rdrobust | Suppress warning messages |
| `detail` | Stata only | rdrobust | Print detailed estimation output |
| `vleverage` | Stata only | rdrobust | Show leverage diagnostics |
| `precision` | Stata only | rdrobust, rdbwselect, rdplot | Control numeric storage (`double`/`single`) |
| `genvars` | Stata only | rdplot | Generate variables (bin means, etc.) in dataset |
| `graph_options` | Stata only | rdplot | Pass-through for native Stata graph syntax |

---

## Common "Gotcha" Differences

1. **Index origin**: R is 1-indexed (`est$coef[1]` = conventional), Python is 0-indexed (`est.coef.iloc[0]` = conventional), Stata uses named macros (`e(tau_cl)`). Mixing these up produces silently wrong results.

2. **`all` flag location (R v4.0.0 breaking change)**: In R ≥ 4.0.0, `all` and `detail` moved from `rdrobust()` to `summary()`. Calling `rdrobust(y, x, all=TRUE)` in R now produces a warning and is ignored. Correct: `summary(rdrobust(y, x), all = TRUE)`. Python and Stata still accept `all` in the main function call.

3. **Cluster variable specification**: R and Python take `cluster` as a separate argument alongside `vce = "nn"` (auto-switches to cluster-robust). Stata requires the cluster variable *inside* the `vce()` option: `vce(cluster clvar)` or `vce(cr1 clvar)`. Forgetting this in Stata produces "option cluster not allowed."

4. **Parameter naming convention**: R uses `.` separator for graph options (`x.label`, `y.lim`, `col.dots`). Python uses `_` separator (`x_label`, `y_lim`, `col_dots`). Stata uses `graph_options()` with embedded Stata graphics syntax. This affects `rdplot` primarily.

5. **Covariates format**: R accepts formula (`~ z1 + z2`), character vector, or matrix. Python accepts numpy array, DataFrame, formula string, or list of column names. Stata accepts only a varlist (`covs(z1 z2)`). The formula interface enables interactions and transformations in R natively; Python requires `formulaic`/`patsy`; Stata requires manual generation of interaction variables.

6. **Bandwidth output format**: R and Python return a 2×2 matrix for `bws` (rows: h/b; cols: left/right), accessed via matrix indexing. Stata stores individual scalars: `e(h_l)`, `e(h_r)`, `e(b_l)`, `e(b_r)`. This means R/Python code can iterate over the matrix, while Stata requires referencing each scalar by name.

7. **Missing values handling**: R uses `NA` (with `is.na()` for detection, `na.rm = TRUE` for functions). Python uses `np.nan` (with `np.isnan()` or `pd.isna()`). Stata uses `.` (system missing). All three languages handle NAs internally within rdrobust (dropping incomplete cases), but pre-processing differs significantly.

8. **Language-specific parameters**: `ginv.tol` is R-only (controls pseudo-inverse tolerance), `prchk` is Python-only (toggles diagnostic printing in rdbwselect), and `genvars` is Stata-only (generates bin-level variables in the dataset from rdplot). Attempting to use these in the wrong language raises an error.

9. **Default VCE with clustering**: All three languages auto-switch from `vce = "nn"` to cluster-robust when a cluster variable is provided. However, the available cluster-robust options (cr1, cr2, cr3) with CR2/CR3 leverage corrections are a relatively recent addition — ensure your package version supports them (R ≥ 2.1.0, Python ≥ 2.1.0, Stata ≥ 9.0.0).

10. **Return object structure**: R returns an S3 list (access via `$`). Python returns a custom `rdrobust` object (access via `.`). Stata stores results in `e()` macro system (access via `e(name)`). R and Python return matrices for `bws` and `ci`; Stata returns individual scalars for each bandwidth and CI endpoint.

11. **Bandwidth specification asymmetry**: When specifying `h = c(12, 15)` in R, the first value is for below-cutoff and second for above-cutoff. Python uses a list: `h = [12, 15]`. Stata: `h(12 15)`. All follow (left, right) ordering but container syntax differs.

12. **Print behavior**: R's `print(est)` shows a compact one-row robust result (v4.0.0+); `summary(est)` gives the same; `summary(est, all=TRUE)` shows the 3-row table. Python's `print(est)` shows the full table by default when `all=True`. Stata's default `rdrobust` output shows the robust line; use `all` for the 3-row table.

13. **Stata-exclusive `precision()` option**: Stata has a `precision(double|single)` option controlling internal temporary variable storage, absent in R/Python. This matters for very large datasets where memory is constrained.

14. **rdbwselect return type**: R returns an S3 list object (class `"rdbwselect"`). Python returns a **tuple** `(DataFrame, string)` — not an object with attributes. This means Python access is `bw[0]` for the bandwidth table and `bw[1]` for the method name, while R uses `bw$bws`, `bw$bwselect`.

---

## Cross-Language Code Equivalence Examples

### Minimal Sharp RD (Same Analysis, Three Languages)

**R:**
```r
library(rdrobust)
data(rdrobust_RDsenate)
out <- rdrobust(rdrobust_RDsenate$vote, rdrobust_RDsenate$margin, c = 0)
summary(out)
```

**Python:**
```python
from rdrobust import rdrobust
from rdrobust.datasets import rdrobust_RDsenate
data = rdrobust_RDsenate()
out = rdrobust(data['vote'].values, data['margin'].values, c=0)
print(out)
```

**Stata:**
```stata
use rdrobust_senate.dta, clear
rdrobust vote margin, c(0)
```
