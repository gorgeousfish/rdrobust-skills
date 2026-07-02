# CODE-ANALYSIS: rdrobust Package

> Auto-generated API reference with verified source line numbers.
> Base paths:
> - R: `rdrobust/input/R/rdrobust/`
> - Python: `rdrobust/input/Python/rdrobust/src/rdrobust/`
> - Stata: `rdrobust/input/stata/`

---

## VERIFIED-SIGNATURES

### rdrobust()

#### R Signature
```r
# File: R/rdrobust.R, Lines 1–9
rdrobust = function(y, x, c = NULL, fuzzy = NULL, deriv = NULL,
                    p = NULL, q = NULL, h = NULL, b = NULL, rho = NULL,
                    covs = NULL, covs_drop = TRUE, ginv.tol = 1e-20,
                    kernel = "tri", weights = NULL, bwselect = "mserd",
                    vce = "nn", cluster = NULL, nnmatch = 3, level = 95,
                    scalepar = 1, scaleregul = 1, sharpbw = FALSE,
                    subset = NULL, masspoints = "adjust",
                    bwcheck = NULL, bwrestrict = TRUE, stdvars = TRUE,
                    data = NULL)
```

#### Python Signature
```python
# File: rdrobust.py, Lines 16–24
def rdrobust(y, x, c = None, fuzzy = None, deriv = None,
             p = None, q = None, h = None, b = None, rho = None,
             covs = None, covs_drop = True,
             kernel = "tri", weights = None, bwselect = "mserd",
             vce = "nn", cluster = None, nnmatch = 3, level = 95,
             scalepar = 1, scaleregul = 1, sharpbw = False,
             all = None, subset = None, masspoints = "adjust",
             bwcheck = None, bwrestrict = True, stdvars = True,
             data = None):
```

#### Stata Syntax
```stata
* File: rdrobust.ado, Line 10
syntax anything [if] [in] [, c(real 0) fuzzy(string) deriv(real 0) p(string) q(real 0) h(string) b(string) rho(real 0) covs(string) covs_drop(string) kernel(string) weights(string) bwselect(string) vce(string) level(real 95) all scalepar(real 1) scaleregul(real 1) nochecks nowarnings masspoints(string) bwcheck(real 0) bwrestrict(string) stdvars(string) detail vleverage PRECision(string)]
```

#### Parameter Table: rdrobust()

| Parameter | R | Python | Stata | Type | Default | R Line | Py Line | Stata Line | Description |
|-----------|---|--------|-------|------|---------|--------|---------|------------|-------------|
| y | `y` | `y` | `anything` (1st var) | numeric vector/array | *required* | 1 | 16 | 10 | Dependent variable |
| x | `x` | `x` | `anything` (2nd var) | numeric vector/array | *required* | 1 | 16 | 10 | Running variable (score/forcing) |
| c | `c` | `c` | `c(real 0)` | numeric scalar | NULL/None/0 | 1 | 16 | 10 | RD cutoff; default 0 |
| fuzzy | `fuzzy` | `fuzzy` | `fuzzy(string)` | numeric vector/varname | NULL/None | 1 | 16 | 10 | Treatment status for fuzzy RD |
| deriv | `deriv` | `deriv` | `deriv(real 0)` | integer | NULL/None/0 | 1 | 16 | 10 | Derivative order (0=level, 1=kink) |
| p | `p` | `p` | `p(string)` | integer | NULL/None/1 | 2 | 17 | 10 | Polynomial order for point estimator |
| q | `q` | `q` | `q(real 0)` | integer | NULL/None/p+1 | 2 | 17 | 10 | Polynomial order for bias correction |
| h | `h` | `h` | `h(string)` | numeric scalar/vector(2) | NULL/None/auto | 2 | 17 | 10 | Main bandwidth |
| b | `b` | `b` | `b(string)` | numeric scalar/vector(2) | NULL/None/auto | 2 | 17 | 10 | Bias bandwidth |
| rho | `rho` | `rho` | `rho(real 0)` | numeric scalar | NULL/None/0 | 2 | 17 | 10 | Ratio h/b |
| covs | `covs` | `covs` | `covs(string)` | formula/matrix/varlist | NULL/None | 3 | 18 | 10 | Additional covariates |
| covs_drop | `covs_drop` | `covs_drop` | `covs_drop(string)` | logical/bool | TRUE/True | 3 | 18 | 10 | Drop collinear covariates |
| ginv.tol | `ginv.tol` | — | — | numeric | 1e-20 | 3 | — | — | Tolerance for matrix inversion (R only) |
| kernel | `kernel` | `kernel` | `kernel(string)` | character/string | "tri" | 4 | 19 | 10 | Kernel function: tri/epa/uni |
| weights | `weights` | `weights` | `weights(string)` | numeric vector/varname | NULL/None | 4 | 19 | 10 | Observation weights |
| bwselect | `bwselect` | `bwselect` | `bwselect(string)` | character/string | "mserd" | 4 | 19 | 10 | Bandwidth selection procedure |
| vce | `vce` | `vce` | `vce(string)` | character/string | "nn" | 5 | 20 | 10 | Variance-covariance estimator |
| cluster | `cluster` | `cluster` | — (via vce) | vector/varname | NULL/None | 5 | 20 | 10 | Cluster ID variable |
| nnmatch | `nnmatch` | `nnmatch` | — | integer | 3 | 5 | 20 | — | Min neighbors for NN variance |
| level | `level` | `level` | `level(real 95)` | numeric | 95 | 5 | 20 | 10 | Confidence level (%) |
| scalepar | `scalepar` | `scalepar` | `scalepar(real 1)` | numeric | 1 | 6 | 21 | 10 | Scaling factor for RD parameter |
| scaleregul | `scaleregul` | `scaleregul` | `scaleregul(real 1)` | numeric | 1 | 6 | 21 | 10 | Regularization scaling for BW |
| sharpbw | `sharpbw` | `sharpbw` | — | logical/bool | FALSE/False | 6 | 21 | — | Use sharp BW in fuzzy design |
| all | — | `all` | `all` | logical/bool/flag | —/None | — | 22 | 10 | Show all estimation methods |
| subset | `subset` | `subset` | `[if] [in]` | logical/index vector | NULL/None | 7 | 22 | 10 | Subset of observations |
| masspoints | `masspoints` | `masspoints` | `masspoints(string)` | character/string | "adjust" | 7 | 22 | 10 | Mass points handling: adjust/check/off |
| bwcheck | `bwcheck` | `bwcheck` | `bwcheck(real 0)` | integer | NULL/None/0 | 8 | 23 | 10 | Min unique obs in bandwidth |
| bwrestrict | `bwrestrict` | `bwrestrict` | `bwrestrict(string)` | logical/bool | TRUE/True | 8 | 23 | 10 | Restrict BW to range of x |
| stdvars | `stdvars` | `stdvars` | `stdvars(string)` | logical/bool | TRUE/True | 8 | 23 | 10 | Standardize x,y for BW selection |
| data | `data` | `data` | — | data.frame/DataFrame | NULL/None | 9 | 24 | — | Optional data frame |
| nochecks | — | — | `nochecks` | flag | — | — | — | 10 | Skip input validation (Stata only) |
| nowarnings | — | — | `nowarnings` | flag | — | — | — | 10 | Suppress warnings (Stata only) |
| detail | — | — | `detail` | flag | — | — | — | 10 | Print detailed output (Stata only) |
| vleverage | — | — | `vleverage` | flag | — | — | — | 10 | Show leverage diagnostics (Stata only) |
| precision | — | — | `PRECision(string)` | string | — | — | — | 10 | Numeric precision (Stata only) |

#### Return Object: rdrobust()

| Element | R Access | Python Access | Stata Access | Description |
|---------|----------|--------------|--------------|-------------|
| Estimate | `$Estimate` | `.Estimate` | — | DataFrame: tau.us, tau.bc, se.us, se.rb |
| bws | `$bws` | `.bws` | `e(bws)` matrix; `e(h_l)`,`e(h_r)`,`e(b_l)`,`e(b_r)` | Bandwidth matrix (h,b × left,right) |
| coef | `$coef` | `.coef` | `e(b)` | Coefficients: Conventional, Bias-Corrected, Robust |
| se | `$se` | `.se` | `e(se_tau_cl)`,`e(se_tau_rb)` | Standard errors |
| z | `$z` | `.z` | — (compute from tau/se) | z-statistics |
| pv | `$pv` | `.pv` | `e(pv_cl)`,`e(pv_bc)`,`e(pv_rb)` | p-values |
| ci | `$ci` | `.ci` | `e(ci)` matrix; `e(ci_l_cl)`,`e(ci_r_cl)`,`e(ci_l_rb)`,`e(ci_r_rb)` | Confidence intervals |
| beta_Y_p_l | `$beta_Y_p_l` | `.beta_p_l` | `e(beta_Y_p_l)` | Left-side polynomial coefficients (outcome) |
| beta_Y_p_r | `$beta_Y_p_r` | `.beta_p_r` | `e(beta_Y_p_r)` | Right-side polynomial coefficients (outcome) |
| beta_T_p_l | `$beta_T_p_l` | `.beta_T_p_l` | `e(beta_T_p_l)` | Left-side poly coefficients (first stage, fuzzy) |
| beta_T_p_r | `$beta_T_p_r` | `.beta_T_p_r` | `e(beta_T_p_r)` | Right-side poly coefficients (first stage, fuzzy) |
| V_cl_l | `$V_cl_l` | `.V_cl_l` | `e(V_cl_l)` | Conventional VCE matrix, left |
| V_cl_r | `$V_cl_r` | `.V_cl_r` | `e(V_cl_r)` | Conventional VCE matrix, right |
| V_rb_l | `$V_rb_l` | `.V_rb_l` | `e(V_rb_l)` | Robust VCE matrix, left |
| V_rb_r | `$V_rb_r` | `.V_rb_r` | `e(V_rb_r)` | Robust VCE matrix, right |
| N | `$N` | `.N` | `e(N_l)`,`e(N_r)` | Total sample size [left, right] |
| N_h | `$N_h` | `.N_h` | `e(N_h_l)`,`e(N_h_r)` | Effective sample size [left, right] |
| N_b | `$N_b` | `.N_b` | `e(N_b_l)`,`e(N_b_r)` | Bias-band sample size [left, right] |
| M | `$M` | `.M` | — | Unique observations [left, right] |
| tau_cl | `$tau_cl` | `.tau_cl` | `e(tau_cl)`,`e(tau_cl_l)`,`e(tau_cl_r)` | Conventional estimates [left, right] |
| tau_bc | `$tau_bc` | `.tau_bc` | `e(tau_bc)`,`e(tau_bc_l)`,`e(tau_bc_r)` | Bias-corrected estimates [left, right] |
| c | `$c` | `.c` | `e(c)` | Cutoff value |
| p | `$p` | `.p` | `e(p)` | Polynomial order |
| q | `$q` | `.q` | `e(q)` | Bias polynomial order |
| bias | `$bias` | `.bias` | `e(bias_l)`,`e(bias_r)` | Estimated bias [left, right] |
| kernel | `$kernel` | `.kernel` | `e(kernel)` | Kernel type used |
| vce | `$vce` | `.vce` | `e(vce_type)` | VCE method used |
| bwselect | `$bwselect` | `.bwselect` | `e(bwselect)` | BW selection method |
| level | `$level` | `.level` | `e(level)` | Confidence level |
| masspoints | `$masspoints` | `.masspoints` | — | Mass points option |
| rdmodel | `$rdmodel` | `.rdmodel` | `e(title)` | Model description string |
| n_clust | `$n_clust` | `.n_clust` | `e(n_clust)` | Number of clusters |
| coef_covs | `$coef_covs` | `.coef_covs` | `e(coef_covs)` | Covariate coefficients |
| tau_T | `$tau_T` | `.tau_T` | `e(tau_T_cl)`,`e(tau_T_bc)` | First-stage coef (fuzzy only) |
| se_T | `$se_T` | `.se_T` | `e(se_tau_T_cl)`,`e(se_tau_T_rb)` | First-stage SE (fuzzy only) |
| z_T | `$z_T` | `.z_T` | — | First-stage z-stat (fuzzy only) |
| pv_T | `$pv_T` | `.pv_T` | — | First-stage p-value (fuzzy only) |
| ci_T | `$ci_T` | `.ci_T` | — | First-stage CI (fuzzy only) |

---

### rdbwselect()

#### R Signature
```r
# File: R/rdbwselect.R, Lines 1–8
rdbwselect = function(y, x, c = NULL, fuzzy = NULL, deriv = NULL, p = NULL, q = NULL,
                      covs = NULL,  covs_drop = TRUE, ginv.tol = 1e-20,
                      kernel = "tri", weights = NULL, bwselect = "mserd",
                      vce = "nn", cluster = NULL,
                      nnmatch = 3,  scaleregul = 1, sharpbw = FALSE,
                      all = NULL, subset = NULL, masspoints = "adjust",
                      bwcheck = NULL, bwrestrict = TRUE, stdvars = TRUE,
                      data = NULL)
```

#### Python Signature
```python
# File: rdbwselect.py, Lines 13–18
def rdbwselect(y, x, c = None, fuzzy = None, deriv = None, p = None, q = None,
               covs = None, covs_drop = True, kernel = "tri", weights = None,
               bwselect = "mserd", vce = "nn", cluster = None, nnmatch = 3,
               scaleregul = 1, sharpbw = False, all = None, subset = None,
               masspoints = "adjust", bwcheck = None, bwrestrict = True,
               stdvars = True, prchk = True, data = None):
```

#### Stata Syntax
```stata
* File: rdbwselect.ado, Line 10
syntax anything [if] [in] [, c(real 0) fuzzy(string) deriv(real 0) p(string) q(real 0) covs(string) covs_drop(string) kernel(string) weights(string) bwselect(string) vce(string) scaleregul(real 1) all nochecks masspoints(string) bwcheck(real 0) bwrestrict(string) stdvars(string) PRECision(string)]
```

#### Parameter Table: rdbwselect()

| Parameter | R | Python | Stata | Type | Default | R Line | Py Line | Stata Line | Description |
|-----------|---|--------|-------|------|---------|--------|---------|------------|-------------|
| y | `y` | `y` | `anything` (1st var) | numeric vector/array | *required* | 1 | 13 | 10 | Dependent variable |
| x | `x` | `x` | `anything` (2nd var) | numeric vector/array | *required* | 1 | 13 | 10 | Running variable |
| c | `c` | `c` | `c(real 0)` | numeric scalar | NULL/None/0 | 1 | 13 | 10 | RD cutoff |
| fuzzy | `fuzzy` | `fuzzy` | `fuzzy(string)` | numeric vector/varname | NULL/None | 1 | 13 | 10 | Treatment status for fuzzy RD |
| deriv | `deriv` | `deriv` | `deriv(real 0)` | integer | NULL/None/0 | 1 | 13 | 10 | Derivative order |
| p | `p` | `p` | `p(string)` | integer | NULL/None/1 | 1 | 13 | 10 | Polynomial order |
| q | `q` | `q` | `q(real 0)` | integer | NULL/None/p+1 | 1 | 13 | 10 | Bias polynomial order |
| covs | `covs` | `covs` | `covs(string)` | formula/matrix/varlist | NULL/None | 2 | 14 | 10 | Additional covariates |
| covs_drop | `covs_drop` | `covs_drop` | `covs_drop(string)` | logical/bool | TRUE/True | 2 | 14 | 10 | Drop collinear covariates |
| ginv.tol | `ginv.tol` | — | — | numeric | 1e-20 | 2 | — | — | Matrix inversion tolerance (R only) |
| kernel | `kernel` | `kernel` | `kernel(string)` | character/string | "tri" | 3 | 14 | 10 | Kernel: tri/epa/uni |
| weights | `weights` | `weights` | `weights(string)` | numeric vector/varname | NULL/None | 3 | 14 | 10 | Observation weights |
| bwselect | `bwselect` | `bwselect` | `bwselect(string)` | character/string | "mserd" | 3 | 15 | 10 | BW selection procedure |
| vce | `vce` | `vce` | `vce(string)` | character/string | "nn" | 4 | 15 | 10 | Variance estimator |
| cluster | `cluster` | `cluster` | — (via vce) | vector/varname | NULL/None | 4 | 15 | 10 | Cluster ID variable |
| nnmatch | `nnmatch` | `nnmatch` | — | integer | 3 | 5 | 15 | — | Min neighbors for NN |
| scaleregul | `scaleregul` | `scaleregul` | `scaleregul(real 1)` | numeric | 1 | 5 | 16 | 10 | Regularization scaling |
| sharpbw | `sharpbw` | `sharpbw` | — | logical/bool | FALSE/False | 5 | 16 | — | Use sharp BW in fuzzy |
| all | `all` | `all` | `all` | logical/bool/flag | NULL/None | 6 | 16 | 10 | Report all BW methods |
| subset | `subset` | `subset` | `[if] [in]` | logical/index vector | NULL/None | 6 | 16 | 10 | Subset of observations |
| masspoints | `masspoints` | `masspoints` | `masspoints(string)` | character/string | "adjust" | 6 | 17 | 10 | Mass points handling |
| bwcheck | `bwcheck` | `bwcheck` | `bwcheck(real 0)` | integer | NULL/None/0 | 7 | 17 | 10 | Min unique obs in BW |
| bwrestrict | `bwrestrict` | `bwrestrict` | `bwrestrict(string)` | logical/bool | TRUE/True | 7 | 17 | 10 | Restrict BW to range of x |
| stdvars | `stdvars` | `stdvars` | `stdvars(string)` | logical/bool | TRUE/True | 7 | 18 | 10 | Standardize x,y |
| data | `data` | `data` | — | data.frame/DataFrame | NULL/None | 8 | 18 | — | Optional data frame |
| prchk | — | `prchk` | — | bool | —/True | — | 18 | — | Print checks (Python only) |
| nochecks | — | — | `nochecks` | flag | — | — | — | 10 | Skip validation (Stata only) |
| precision | — | — | `PRECision(string)` | string | — | — | — | 10 | Numeric precision (Stata only) |

#### Return Object: rdbwselect()

| Element | R Access | Python Access | Stata Access | Description |
|---------|----------|--------------|--------------|-------------|
| bws | `$bws` | `[0]` (DataFrame) | `e(mat_h)`,`e(mat_b)` | Bandwidth matrix |
| bwselect | `$bwselect` | `[1]` (string) | `e(bwselect)` | BW method selected |
| kernel | `$kernel` | — | `e(kernel)` | Kernel type |
| p | `$p` | — | `e(p)` | Polynomial order |
| q | `$q` | — | `e(q)` | Bias polynomial order |
| c | `$c` | — | `e(c)` | Cutoff value |
| N | `$N` | — | `e(N_l)`,`e(N_r)` | Sample size [left, right] |
| N_h | `$N_h` | — | — | Effective sample size [left, right] |
| M | `$M` | — | — | Unique observations [left, right] |
| vce | `$vce` | — | `e(vce_type)` | VCE method |
| masspoints | `$masspoints` | — | — | Mass points option |
| h_mserd | — | — | `e(h_mserd)` | MSE-RD optimal h |
| b_mserd | — | — | `e(b_mserd)` | MSE-RD optimal b |
| h_msetwo_l/r | — | — | `e(h_msetwo_l)`,`e(h_msetwo_r)` | MSE-TWO optimal h |
| h_msesum | — | — | `e(h_msesum)` | MSE-SUM optimal h |
| h_cerrd | — | — | `e(h_cerrd)` | CER-RD optimal h |
| n_clust | — | — | `e(n_clust)` | Number of clusters |

> **Note:** Python `rdbwselect()` returns a tuple `(bws_DataFrame, bwselect_string)`. R returns a list object of class `"rdbwselect"`. Stata stores results in `e()`.

---

### rdplot()

#### R Signature
```r
# File: R/rdplot.R, Lines 1–8
rdplot = function(y, x, c = 0, p = 4, nbins = NULL, binselect = "esmv", scale = NULL,
                  kernel = "uni", weights = NULL, h = NULL,
                  covs = NULL,  covs_eval = "mean", covs_drop = TRUE, ginv.tol = 1e-20,
                  support = NULL, subset = NULL, masspoints = "adjust",
                  hide = FALSE, ci = NULL, shade = FALSE,
                  title = NULL, x.label = NULL, y.label = NULL, x.lim = NULL, y.lim = NULL,
                  col.dots = NULL, col.lines = NULL,
                  data = NULL)
```

#### Python Signature
```python
# File: rdplot.py, Lines 16–23
def rdplot(y, x, c = 0, p = 4, nbins = None, binselect = "esmv", scale = None,
                  kernel = "uni", weights = None, h = None,
                  covs = None,  covs_eval = "mean", covs_drop = True,
                  support = None, subset = None, masspoints = "adjust",
                  hide = False, ci = None, shade = False,
                  title = None, x_label = None, y_label = None, x_lim = None,
                  y_lim = None, col_dots = None, col_lines = None,
                  data = None):
```

#### Stata Syntax
```stata
* File: rdplot.ado, Line 10
syntax anything [if] [, c(real 0) p(integer 4) nbins(string) covs(string) covs_eval(string) covs_drop(string) binselect(string) scale(string) kernel(string) weights(string) h(string) support(string) masspoints(string) genvars hide ci(real 0) shade graph_options(string asis) nochecks PRECision(string) *]
```

#### Parameter Table: rdplot()

| Parameter | R | Python | Stata | Type | Default | R Line | Py Line | Stata Line | Description |
|-----------|---|--------|-------|------|---------|--------|---------|------------|-------------|
| y | `y` | `y` | `anything` (1st var) | numeric vector/array | *required* | 1 | 16 | 10 | Dependent variable |
| x | `x` | `x` | `anything` (2nd var) | numeric vector/array | *required* | 1 | 16 | 10 | Running variable |
| c | `c` | `c` | `c(real 0)` | numeric scalar | 0 | 1 | 16 | 10 | RD cutoff |
| p | `p` | `p` | `p(integer 4)` | integer | 4 | 1 | 16 | 10 | Global polynomial order |
| nbins | `nbins` | `nbins` | `nbins(string)` | integer/vector(2) | NULL/None/auto | 1 | 16 | 10 | Number of bins [left, right] |
| binselect | `binselect` | `binselect` | `binselect(string)` | character/string | "esmv" | 1 | 16 | 10 | Bin selection: es/espr/esmv/qs/qspr/qsmv |
| scale | `scale` | `scale` | `scale(string)` | numeric scalar/vector(2) | NULL/None/1 | 1 | 16 | 10 | Bin number scaling factor |
| kernel | `kernel` | `kernel` | `kernel(string)` | character/string | "uni" | 2 | 17 | 10 | Kernel: tri/epa/uni |
| weights | `weights` | `weights` | `weights(string)` | numeric vector/varname | NULL/None | 2 | 17 | 10 | Observation weights |
| h | `h` | `h` | `h(string)` | numeric scalar/vector(2) | NULL/None/range | 2 | 17 | 10 | Bandwidth for polynomial fit |
| covs | `covs` | `covs` | `covs(string)` | formula/matrix/varlist | NULL/None | 3 | 18 | 10 | Additional covariates |
| covs_eval | `covs_eval` | `covs_eval` | `covs_eval(string)` | character/string | "mean" | 3 | 18 | 10 | Covariate evaluation: mean/0 |
| covs_drop | `covs_drop` | `covs_drop` | `covs_drop(string)` | logical/bool | TRUE/True | 3 | 18 | 10 | Drop collinear covariates |
| ginv.tol | `ginv.tol` | — | — | numeric | 1e-20 | 3 | — | — | Matrix inversion tolerance (R only) |
| support | `support` | `support` | `support(string)` | numeric vector(2) | NULL/None | 4 | 19 | 10 | Support of running variable |
| subset | `subset` | `subset` | `[if] [in]` | logical/index vector | NULL/None | 4 | 19 | 10 | Subset of observations |
| masspoints | `masspoints` | `masspoints` | `masspoints(string)` | character/string | "adjust" | 4 | 19 | 10 | Mass points handling |
| hide | `hide` | `hide` | `hide` | logical/bool/flag | FALSE/False | 5 | 20 | 10 | Suppress plot display |
| ci | `ci` | `ci` | `ci(real 0)` | numeric (level) | NULL/None/0 | 5 | 20 | 10 | CI level for bin means (0=none) |
| shade | `shade` | `shade` | `shade` | logical/bool/flag | FALSE/False | 5 | 20 | 10 | Shade CI region |
| title | `title` | `title` | — (via graph_options) | character/string | NULL/None | 6 | 21 | — | Plot title |
| x.label / x_label | `x.label` | `x_label` | — (via graph_options) | character/string | NULL/None | 6 | 21 | — | X-axis label |
| y.label / y_label | `y.label` | `y_label` | — (via graph_options) | character/string | NULL/None | 6 | 21 | — | Y-axis label |
| x.lim / x_lim | `x.lim` | `x_lim` | — (via graph_options) | numeric vector(2) | NULL/None | 6 | 21 | — | X-axis limits |
| y.lim / y_lim | `y.lim` | `y_lim` | — (via graph_options) | numeric vector(2) | NULL/None | 6 | 22 | — | Y-axis limits |
| col.dots / col_dots | `col.dots` | `col_dots` | — (via graph_options) | character/string | NULL/None | 7 | 22 | — | Dot color |
| col.lines / col_lines | `col.lines` | `col_lines` | — (via graph_options) | character/string | NULL/None | 7 | 22 | — | Line color |
| data | `data` | `data` | — | data.frame/DataFrame | NULL/None | 8 | 23 | — | Optional data frame |
| genvars | — | — | `genvars` | flag | — | — | — | 10 | Generate Stata variables (Stata only) |
| graph_options | — | — | `graph_options(string asis)` | string | — | — | — | 10 | Stata graph options passthrough |
| nochecks | — | — | `nochecks` | flag | — | — | — | 10 | Skip validation (Stata only) |
| precision | — | — | `PRECision(string)` | string | — | — | — | 10 | Numeric precision (Stata only) |

#### Return Object: rdplot()

| Element | R Access | Python Access | Stata Access | Description |
|---------|----------|--------------|--------------|-------------|
| coef | `$coef` | `.coef` | `e(coef_l)`,`e(coef_r)` | Polynomial coefficients [Left, Right] |
| rdplot | `$rdplot` | `.rdplot` | — (graph displayed) | ggplot2/plotnine plot object |
| vars_bins | `$vars_bins` | `.vars_bins` | — | DataFrame of binned statistics |
| vars_poly | `$vars_poly` | `.vars_poly` | — | DataFrame of polynomial fit values |
| J | `$J` | `.J` | `e(J_star_l)`,`e(J_star_r)` | Number of bins selected [left, right] |
| J_IMSE | `$J_IMSE` | `.J_IMSE` | — | IMSE-optimal number of bins |
| J_MV | `$J_MV` | `.J_MV` | — | Mimicking-variance number of bins |
| scale | `$scale` | `.scale` | — | Scale factors [left, right] |
| rscale | `$rscale` | `.rscale` | — | Relative scale to IMSE-optimal |
| bin_avg | `$bin_avg` | `.bin_avg` | — | Average bin length [left, right] |
| bin_med | `$bin_med` | `.bin_med` | — | Median bin length [left, right] |
| p | `$p` | `.p` | `e(p)` | Polynomial order used |
| c | `$c` | `.c` | `e(c)` | Cutoff value |
| h | `$h` | `.h` | — | Bandwidth [left, right] |
| N | `$N` | `.N` | `e(N_l)`,`e(N_r)` | Sample size [left, right] |
| N_h | `$N_h` | `.N_h` | `e(N_h_l)`,`e(N_h_r)` | Effective sample size [left, right] |
| binselect | `$binselect` | `.binselect` | `e(binselect)` | Bin selection method |
| kernel | `$kernel` | `.kernel` | — | Kernel type |
| coef_covs | `$coef_covs` | `.coef_covs` | `e(coef_covs)` | Covariate coefficients |

---

## Cross-Language Mapping Summary

### Naming Conventions

| Convention | R | Python | Stata |
|------------|---|--------|-------|
| Separator in params | `.` (e.g. `x.label`) | `_` (e.g. `x_label`) | — |
| Boolean values | `TRUE`/`FALSE` | `True`/`False` | flag (presence/absence) |
| NULL/None | `NULL` | `None` | `""` or 0 |
| Subsetting | `subset` vector | `subset` vector | `[if] [in]` |
| Data input | `data` argument | `data` argument | Variables in memory |

### Parameter Availability Matrix

| Parameter | rdrobust | rdbwselect | rdplot | Notes |
|-----------|----------|------------|--------|-------|
| y, x | R/Py/St | R/Py/St | R/Py/St | Core inputs |
| c | R/Py/St | R/Py/St | R/Py/St | Cutoff |
| fuzzy | R/Py/St | R/Py/St | — | Not in rdplot |
| deriv | R/Py/St | R/Py/St | — | Not in rdplot |
| p | R/Py/St | R/Py/St | R/Py/St | Different defaults: 1 (rdrobust/rdbwselect) vs 4 (rdplot) |
| q | R/Py/St | R/Py/St | — | Not in rdplot |
| h | R/Py/St | — | R/Py/St | Not in rdbwselect (it computes h) |
| b | R/Py/St | — | — | Only in rdrobust |
| rho | R/Py/St | — | — | Only in rdrobust |
| covs | R/Py/St | R/Py/St | R/Py/St | All functions |
| covs_drop | R/Py/St | R/Py/St | R/Py/St | All functions |
| covs_eval | — | — | R/Py/St | Only in rdplot |
| ginv.tol | R only | — | — | R internal tolerance |
| kernel | R/Py/St | R/Py/St | R/Py/St | Default "tri" in rdrobust/rdbwselect; "uni" in rdplot |
| weights | R/Py/St | R/Py/St | R/Py/St | All functions |
| bwselect | R/Py/St | R/Py/St | — | Not in rdplot |
| vce | R/Py/St | R/Py/St | — | Not in rdplot |
| cluster | R/Py/St | R/Py/St | — | Not in rdplot |
| nnmatch | R/Py | R/Py | — | Not in Stata |
| level | R/Py/St | — | — | Only in rdrobust |
| scalepar | R/Py/St | — | — | Only in rdrobust |
| scaleregul | R/Py/St | R/Py/St | — | Not in rdplot |
| sharpbw | R/Py | R/Py | — | Not in Stata |
| all | Py/St | R/Py/St | — | R moved to summary() |
| subset | R/Py/St | R/Py/St | R/Py/St | Stata uses [if]/[in] |
| masspoints | R/Py/St | R/Py/St | R/Py/St | All functions |
| bwcheck | R/Py/St | R/Py/St | — | Not in rdplot |
| bwrestrict | R/Py/St | R/Py/St | — | Not in rdplot |
| stdvars | R/Py/St | R/Py/St | — | Not in rdplot |
| data | R/Py | R/Py | — | Stata uses variables in memory |
| nbins | — | — | R/Py/St | Only in rdplot |
| binselect | — | — | R/Py/St | Only in rdplot |
| scale | — | — | R/Py/St | Only in rdplot |
| support | — | — | R/Py/St | Only in rdplot |
| hide | — | — | R/Py/St | Only in rdplot |
| ci | — | — | R/Py/St | Only in rdplot |
| shade | — | — | R/Py/St | Only in rdplot |
| title | — | — | R/Py | Only in rdplot (Stata via graph_options) |
| x.label/x_label | — | — | R/Py | Only in rdplot |
| y.label/y_label | — | — | R/Py | Only in rdplot |
| x.lim/x_lim | — | — | R/Py | Only in rdplot |
| y.lim/y_lim | — | — | R/Py | Only in rdplot |
| col.dots/col_dots | — | — | R/Py | Only in rdplot |
| col.lines/col_lines | — | — | R/Py | Only in rdplot |

### Exported Functions (Public API)

| Function | R (NAMESPACE) | Python (__init__.py) | Stata (.ado) |
|----------|---------------|---------------------|--------------|
| rdrobust | `export(rdrobust)` | `from rdrobust.rdrobust import rdrobust` | `rdrobust.ado` |
| rdbwselect | `export(rdbwselect)` | `from rdrobust.rdbwselect import rdbwselect` | `rdbwselect.ado` |
| rdplot | `export(rdplot)` | `from rdrobust.rdplot import rdplot` | `rdplot.ado` |
| plot_rdrobust | — | `from rdrobust.rdplot_rdrobust import plot_rdrobust` | `rdrobustplot.ado` |
| rdrobust_RDsenate | (data, not function) | `from rdrobust import rdrobust_RDsenate` | `rdrobust_senate.dta` |

---

## Source File Index

| Language | File | Path | Key Content |
|----------|------|------|-------------|
| R | rdrobust.R | `R/rdrobust/R/rdrobust.R` (1252 lines) | rdrobust(), print/summary/coef/vcov methods |
| R | rdbwselect.R | `R/rdrobust/R/rdbwselect.R` (644 lines) | rdbwselect(), print/summary methods |
| R | rdplot.R | `R/rdrobust/R/rdplot.R` (681 lines) | rdplot(), print/summary methods |
| R | functions.R | `R/rdrobust/R/functions.R` | Internal helpers (kernels, BW, VCE) |
| R | NAMESPACE | `R/rdrobust/NAMESPACE` (30 lines) | Exports and S3 methods |
| Python | rdrobust.py | `Python/rdrobust/src/rdrobust/rdrobust.py` (1117 lines) | rdrobust() |
| Python | rdbwselect.py | `Python/rdrobust/src/rdrobust/rdbwselect.py` (792 lines) | rdbwselect() |
| Python | rdplot.py | `Python/rdrobust/src/rdrobust/rdplot.py` (846 lines) | rdplot() |
| Python | funs.py | `Python/rdrobust/src/rdrobust/funs.py` (1158 lines) | rdrobust_output, rdplot_output classes, helpers |
| Python | __init__.py | `Python/rdrobust/src/rdrobust/__init__.py` (8 lines) | Public API exports |
| Stata | rdrobust.ado | `stata/rdrobust.ado` (1332 lines) | rdrobust command |
| Stata | rdbwselect.ado | `stata/rdbwselect.ado` (877 lines) | rdbwselect command |
| Stata | rdplot.ado | `stata/rdplot.ado` (~850 lines) | rdplot command |
