# METHOD-UNDERSTANDING: rdrobust

## 1. Method Overview

The Regression Discontinuity (RD) design is a quasi-experimental empirical strategy in which units are assigned to treatment based on whether their value of an observed covariate (the "running variable" or "score") exceeds a known cutoff. The fundamental idea is that units with score values barely above and below the cutoff are comparable in all relevant aspects except treatment status, enabling identification of a local average treatment effect at the cutoff. Under a continuity assumption on the conditional expectation functions, the RD treatment effect is nonparametrically identified as the difference in the limits of the regression functions from each side of the cutoff.

The **rdrobust** package implements the robust bias-corrected (RBC) inference framework developed by Calonico, Cattaneo, and Titiunik (2014, Econometrica). The core insight is that standard MSE-optimal bandwidths used with local polynomial estimators lead to confidence intervals with severe coverage distortions because the bandwidth is "too large" to eliminate the asymptotic bias. Rather than undersmoothing (using an ad hoc smaller bandwidth), rdrobust explicitly estimates the bias, corrects for it, and uses a novel variance formula that accounts for the additional variability introduced by bias estimation. This delivers confidence intervals that are valid even with MSE-optimal bandwidths.

The package provides three core functions: `rdrobust()` for robust bias-corrected point estimation and inference (CCT 2014), `rdplot()` for statistically optimal RD data visualization with data-driven bin selection (CCT 2015 JASA), and `rdbwselect()` for MSE-optimal and coverage error rate (CER)-optimal bandwidth selection (CCF 2020 Econometrics Journal). Together, these cover the full workflow from visualization through formal inference, with implementations in R, Python, and Stata.

## 2. Identification Assumptions

### Assumption 1: Continuity of Conditional Expectation Functions at Cutoff

| Dimension | Content |
|-----------|---------|
| D1: Formal | $\mathbb{E}[Y_i(1) \mid X_i = x]$ and $\mathbb{E}[Y_i(0) \mid X_i = x]$ are continuous at $x = c$. This implies $\tau_{\text{SRD}} = \lim_{x \downarrow c} \mathbb{E}[Y_i \mid X_i = x] - \lim_{x \uparrow c} \mathbb{E}[Y_i \mid X_i = x]$. |
| D2: Intuition | Units just above and just below the cutoff have similar average potential outcomes. The outcome does not "jump" except through the treatment channel. All confounders vary smoothly through the cutoff. |
| D3: Testability | Not directly testable for the outcome of interest (since both potential outcomes are never observed at the cutoff). However, testable implications arise for pre-treatment covariates: if the design is valid, predetermined covariates should show no discontinuity at the cutoff. |
| D4: Diagnostic | Use `rdrobust()` with pre-treatment covariates as outcomes (placebo/falsification tests). A statistically significant jump in a covariate at the cutoff casts doubt on continuity. |
| D5: Violation | If violated, the estimated treatment effect conflates the true causal effect with a discontinuity in potential outcomes caused by unobserved confounders. The RD estimate becomes biased and loses causal interpretation. |

### Assumption 2: No Manipulation of the Running Variable (Density Continuity)

| Dimension | Content |
|-----------|---------|
| D1: Formal | The density $f(x)$ of the running variable $X_i$ is continuous at the cutoff $c$: $\lim_{x \downarrow c} f(x) = \lim_{x \uparrow c} f(x)$. Equivalently, units cannot precisely sort themselves to one side of the cutoff. |
| D2: Intuition | If individuals can manipulate their score to land just above (or below) the cutoff, the groups on either side become systematically different and comparability breaks down. A discontinuity in the density at the cutoff suggests manipulation. |
| D3: Testability | Directly testable. A discontinuity in the density of the running variable at the cutoff indicates manipulation. |
| D4: Diagnostic | McCrary (2008) density test; Cattaneo, Jansson, and Ma (2020) `rddensity` package provides a formal manipulation test based on local polynomial density estimation. |
| D5: Violation | Selective sorting around the cutoff implies that units just above and below differ systematically in unobservable characteristics. The treatment effect estimate captures both the causal effect and the selection bias from manipulation. |

### Assumption 3: Local Regularity / Smoothness Conditions

| Dimension | Content |
|-----------|---------|
| D1: Formal | (CCT 2014, Assumption 1): (a) $\mathbb{E}[Y_i^4 \mid X_i = x]$ is bounded and $f(x)$ is continuous and bounded away from zero in a neighborhood $(-\kappa_0, \kappa_0)$ around the cutoff. (b) $\mu_-(x)$ and $\mu_+(x)$ are $S$ times continuously differentiable ($S \geq 3$ for Theorem 1). (c) $\sigma^2_-(x)$ and $\sigma^2_+(x)$ are continuous and bounded away from zero. |
| D2: Intuition | The regression functions must be "smooth enough" on each side of the cutoff to justify local polynomial approximation. The density must be positive near the cutoff (ensuring observations exist). The conditional variance must be well-behaved to permit standard error estimation. |
| D3: Testability | The smoothness order $S$ is untestable in practice, but higher-order polynomial fits and sensitivity to polynomial order provide informal evidence. Density positivity is observable. |
| D4: Diagnostic | Compare estimates across polynomial orders $p = 1, 2, 3$. Large sensitivity to polynomial order suggests insufficient smoothness relative to bandwidth. Use `rdbwselect()` to check stability of bandwidth choices. |
| D5: Violation | If smoothness is insufficient (e.g., the true regression function has a kink or rapid oscillation near the cutoff), the polynomial approximation is poor, bias estimates are unreliable, and confidence intervals have incorrect coverage. |

### Assumption 4: SUTVA / No Interference Near Cutoff

| Dimension | Content |
|-----------|---------|
| D1: Formal | The observed outcome for unit $i$ depends only on its own treatment status: $Y_i = Y_i(0)(1 - T_i) + Y_i(1) T_i$, where $T_i = \mathbb{1}(X_i \geq c)$. There is no interference between units (one unit's treatment does not affect another's outcome). |
| D2: Intuition | Each unit's outcome is determined solely by whether that unit is treated or not. There are no spillover effects between treated and control units near the cutoff. |
| D3: Testability | Generally untestable without additional data or structural assumptions. In some designs (e.g., geographic RD), spatial spillovers can be examined. |
| D4: Diagnostic | Check for discontinuities at "donut" specifications (excluding observations very close to the cutoff). In geographic or network settings, test whether outcomes of nearby untreated units change at the cutoff. |
| D5: Violation | With interference, the potential outcomes $Y_i(0)$ and $Y_i(1)$ are ill-defined (they depend on other units' treatments). The RD estimand no longer has a clean causal interpretation as an individual-level treatment effect. |

### Assumption 5: (Fuzzy RD) First-Stage Relevance and Monotonicity

| Dimension | Content |
|-----------|---------|
| D1: Formal | (CCT 2014, Assumption 3): (a) $\mu_{T-}(x) = \mathbb{E}[T_i(0) \mid X_i = x]$ and $\mu_{T+}(x) = \mathbb{E}[T_i(1) \mid X_i = x]$ are $S$ times continuously differentiable. (b) $\tau_{T,\text{SRD}} = \mu_{T+} - \mu_{T-} \neq 0$ (first-stage relevance). Additionally, for LATE interpretation, monotonicity is required: $T_i(1) \geq T_i(0)$ for all $i$ (or vice versa). |
| D2: Intuition | Crossing the cutoff must actually change the probability of receiving treatment (first stage is nonzero). The direction of the change should be uniform across individuals (monotonicity ensures no "defiers"). |
| D3: Testability | First-stage relevance is directly testable by examining the discontinuity in the treatment take-up probability at the cutoff. Monotonicity is generally untestable. |
| D4: Diagnostic | Use `rdrobust()` with the treatment indicator as the outcome to estimate the first-stage discontinuity. A small or insignificant first stage indicates weak instruments. Use `rdplot()` to visualize the treatment probability jump. |
| D5: Violation | If $\tau_{T,\text{SRD}} = 0$, the Fuzzy RD estimator $\tau_{\text{FRD}} = \tau_{Y,\text{SRD}} / \tau_{T,\text{SRD}}$ is undefined (division by zero). If monotonicity fails, the estimand loses its LATE interpretation and becomes a weighted average over heterogeneous complier types with potentially negative weights. |

## 3. Core Theorems

### Theorem 1: Asymptotic Normality of the Robust Bias-Corrected t-Statistic (Sharp RD)

**Source**: Calonico, Cattaneo, and Titiunik (2014), Econometrica 82(6): 2295–2326, Section 2.1, p. 2301.

**Statement**: Let Assumptions 1–2 hold with $S \geq 3$. If $n \min\{h_n^5, b_n^5\} \cdot \max\{h_n^2, b_n^2\} \to 0$ and $n \min\{h_n, b_n\} \to \infty$, then:

$$T_{\text{SRD}}^{\text{rbc}}(h_n, b_n) = \frac{\hat{\tau}_{\text{SRD}}^{\text{bc}}(h_n, b_n) - \tau_{\text{SRD}}}{\sqrt{\mathsf{V}_{\text{SRD}}^{\text{bc}}(h_n, b_n)}} \to_d \mathcal{N}(0, 1)$$

where $\mathsf{V}_{\text{SRD}}^{\text{bc}}(h_n, b_n) = \mathsf{V}_{\text{SRD}}(h_n) + \mathsf{C}_{\text{SRD}}^{\text{bc}}(h_n, b_n)$, and $\hat{\tau}_{\text{SRD}}^{\text{bc}}(h_n, b_n) = \hat{\tau}_{\text{SRD}}(h_n) - h_n^2 \hat{\mathsf{B}}_{\text{SRD}}(h_n, b_n)$ is the bias-corrected estimator.

**Conditions**:
- Smoothness: $\mu_+(x)$ and $\mu_-(x)$ are at least 3 times continuously differentiable ($S \geq 3$)
- Bandwidth rates: $n \min\{h_n^5, b_n^5\} \cdot \max\{h_n^2, b_n^2\} \to 0$ (bias shrinks)
- Effective sample: $n \min\{h_n, b_n\} \to \infty$ (enough observations in window)
- Bounded support: $\kappa \max\{h_n, b_n\} < \kappa_0$

**Implications**:
1. The MSE-optimal bandwidth $h_{\text{MSE}} \propto n^{-1/5}$ satisfies the rate conditions and is valid for robust inference (but not for conventional inference).
2. The variance formula $\mathsf{V}_{\text{SRD}}^{\text{bc}}$ includes an additional correction term $\mathsf{C}_{\text{SRD}}^{\text{bc}}$ that accounts for variability introduced by bias estimation—this is the key innovation over standard bias correction.
3. When $h_n = b_n$ (same kernel), the bias-corrected local-linear estimator is numerically equivalent to the local-quadratic estimator (Remark 7), providing a simple implementation path.
4. The result permits $\rho = h_n/b_n \to \rho \in [0, \infty]$, generalizing the standard requirement $h_n/b_n \to 0$.

### Theorem 2: Coverage Error Optimality and CE-Optimal Bandwidth (CCF 2020)

**Source**: Calonico, Cattaneo, and Farrell (2020), Econometrics Journal 23(2): 192–210, Section 3, Theorems 3.1–3.2.

**Statement** (Theorem 3.1(b)): Under Assumption 2.1 with $S \geq p + 2$, the coverage error of the RBC confidence interval satisfies:

$$\mathbb{P}[\tau_\nu \in I_{\text{RBC}}(h)] - (1 - \alpha) = \frac{1}{nh} \mathcal{Q}_{\text{RBC},1} + nh^{5+2p} \mathcal{Q}_{\text{RBC},2} + h^{2+p} \mathcal{Q}_{\text{RBC},3} + \epsilon_{\text{RBC}}$$

The CE-optimal bandwidth (Theorem 3.2) is:

$$h_{\text{RBC}} = \mathcal{H} \cdot n^{-1/(3+p)}$$

yielding coverage error $\mathbb{P}[\tau_\nu \in I_{\text{RBC}}(h_{\text{RBC}})] = 1 - \alpha + O(n^{-(2+p)/(3+p)})$.

**Conditions**:
- Smoothness $S \geq p + 2$ (one derivative beyond what MSE requires)
- $nh^{1+2\nu}/\log(nh)^{2+\eta} \to \infty$ for $\eta > 0$
- $\rho = h/b$ bounded and bounded away from zero

**Implications**:
1. The CE-optimal bandwidth rate $n^{-1/(3+p)}$ differs from the MSE-optimal rate $n^{-1/(2p+3)}$. For $p = 1$: CE-optimal is $n^{-1/4}$ vs MSE-optimal $n^{-1/5}$.
2. RBC inference dominates undersmoothing: $I_{\text{RBC}}(h_{\text{RBC}})$ has coverage error $O(n^{-(2+p)/(3+p)})$ vs $O(n^{-(1+p)/(2+p)})$ for the best undersmoothed interval.
3. A practical rule-of-thumb: shrink $\hat{h}_{\text{MSE}}$ by factor $n^{-p/((2p+3)(p+3))}$ to obtain CE-optimal bandwidth. For $p = 1$, $n = 500$: approximately 27% shrinkage.
4. This motivates the `bwselect = "cerrd"` option in `rdbwselect()`.

### Theorem 3: MSE-Optimal Bandwidth Rate (CCT 2014, Lemma 1)

**Source**: Calonico, Cattaneo, and Titiunik (2014), Econometrica, Section 4.1, p. 2307 (Lemma 1).

**Statement**: Under Assumptions 1–2 with $S \geq p + 1$, if $\mathsf{h}_n \to 0$ and $n\mathsf{h}_n \to \infty$, then the conditional MSE of the $p$th-order local polynomial estimator $\hat{\tau}_{\nu,p}(\mathsf{h}_n)$ satisfies:

$$\text{MSE}_{
u,p,s}(\mathsf{h}_n) = \mathsf{h}_n^{2(p+1-
u)} \left[\mathsf{B}_{
u,p,p+1,s}^2 + o_p(1)\right] + \frac{1}{n\mathsf{h}_n^{1+2
u}} \left[\mathsf{V}_{
u,p} + o_p(1)\right]$$

If $\mathsf{B}_{\nu,p,p+1,s} \neq 0$, the MSE-optimal bandwidth is:

$$\mathsf{h}_{\text{MSE},
u,p,s} = \mathbf{C}_{\text{MSE},
u,p,s}^{1/(2p+3)} \cdot n^{-1/(2p+3)}, \quad \mathbf{C}_{\text{MSE},
u,p,s} = \frac{(1+2
u)\mathsf{V}_{
u,p}}{2(p+1-
u)\mathsf{B}_{
u,p,p+1,s}^2}$$

**Conditions**:
- Smoothness $S \geq p + 1$ (sufficient to characterize leading bias)
- Non-vanishing bias: $\mathsf{B}_{\nu,p,p+1,s} \neq 0$

**Implications**:
1. For the local-linear Sharp RD estimator ($\nu = 0$, $p = 1$): $h_{\text{MSE}} \propto n^{-1/5}$, which is the standard rate.
2. The bias depends on $(p+1)$th derivatives: for $p = 1$, the second derivatives $\mu_+^{(2)}$ and $\mu_-^{(2)}$ determine the leading bias.
3. The MSE-optimal bandwidth for the bias estimator is $b_{\text{MSE}} = \mathsf{h}_{\text{MSE},2,2,2}$ (for Sharp RD with $p = 1$).
4. These MSE-optimal choices are valid for the robust confidence intervals (Remark 10) but NOT for conventional confidence intervals.
5. This formula underlies the `bwselect = "mserd"` option in `rdbwselect()`.

## 4. Method Variants

| Feature | Sharp RD | Fuzzy RD | Kink RD |
|---------|----------|----------|---------|
| **Estimand** | $\tau_{\text{SRD}} = \mathbb{E}[Y_i(1) - Y_i(0) \mid X_i = c]$ | $\tau_{\text{FRD}} = \frac{\mu_{Y+} - \mu_{Y-}}{\mu_{T+} - \mu_{T-}}$ | $\tau_{\text{SKRD}} = \mu_+^{(1)} - \mu_-^{(1)}$ |
| **Interpretation** | ATE at cutoff | LATE for compliers at cutoff | Change in slope of regression function |
| **Treatment rule** | $T_i = \mathbb{1}(X_i \geq c)$ deterministic | $T_i$ probabilistic, jumps at $c$ | Treatment intensity changes slope at $c$ |
| **Estimator** | Difference of local-linear intercepts | Ratio of two sharp RD estimators | Difference of local-quadratic first derivatives |
| **Polynomial order** | $p = 1$ (local linear) | $p = 1$ (local linear, for numerator & denominator) | $p = 2$ (local quadratic) |
| **Bias correction order** | $q = p + 1 = 2$ (local quadratic) | $q = p + 1 = 2$ | $q = p + 1 = 3$ (local cubic) |
| **Smoothness required** | $S \geq 3$ | $S \geq 3$ + Assumption 3 | $S \geq 4$ |
| **Additional assumptions** | None beyond Assumptions 1–2 | First-stage relevance ($\tau_{T,\text{SRD}} \neq 0$); monotonicity for LATE | None beyond Assumptions 1–2 |
| **rdrobust parameter** | Default (no `fuzzy` argument) | `fuzzy = T` (treatment variable) | `deriv = 1` |
| **CCT 2014 Theorem** | Theorem 1 | Theorem 3 | Theorem 2 |

## 5. Innovation Mapping

| Theory | Implementation | Parameter/Function |
|--------|---------------|-------------------|
| Theorem 1 (RBC normality, Sharp RD) | `rdrobust()` default inference | `all = TRUE` returns conventional, bias-corrected, and robust CIs |
| Theorem 2 (RBC normality, Kink RD) | `rdrobust()` with derivative estimation | `deriv = 1` |
| Theorem 3 (RBC normality, Fuzzy RD) | `rdrobust()` with fuzzy option | `fuzzy = T` where T is treatment variable |
| MSE-optimal bandwidth (Lemma 1) | `rdbwselect()` MSE criteria | `bwselect = "mserd"` (common), `"msetwo"` (separate), `"msesum"` (sum) |
| CE-optimal bandwidth (CCF 2020, Thm 3.2) | `rdbwselect()` CER criteria | `bwselect = "cerrd"` (common), `"certwo"` (separate), `"cersum"` (sum) |
| ROT bandwidth shrinkage formula | Internal to `rdbwselect()` | Applies $n^{-p/((2p+3)(p+3))}$ factor to MSE bandwidth |
| Assumption 1 (continuity) | Placebo/falsification tests | `rdrobust(covariate, x)` for each pre-treatment covariate |
| Assumption 2 (no manipulation) | Density test | `rddensity` package (separate from rdrobust) |
| Assumption 3 (smoothness) | Sensitivity to polynomial order | `p = 1` vs `p = 2` comparison |
| Nearest-neighbor variance estimation | `rdrobust()` default VCE | `vce = "nn"` with `nnmatch = 3` |
| HC robust variance | `rdrobust()` alternative VCE | `vce = "hc0"`, `"hc1"`, `"hc2"`, `"hc3"` |
| Cluster-robust variance | `rdrobust()` with clustering | `cluster = cluster_var` (R/Python); `vce(cluster clvar)` (Stata) |
| IMSE-optimal binning (CCT 2015) | `rdplot()` bin selection | `binselect = "es"` (ES-IMSE), `"qs"` (QS-IMSE) |
| Mimicking variance binning (CCT 2015) | `rdplot()` MV bin selection | `binselect = "esmv"` (default), `"qsmv"` |
| Triangular kernel (MSE-optimal) | Default kernel choice | `kernel = "triangular"` |
| Regularization for small bias | Bandwidth stability | `scaleregul = 1` (default) |
| Covariates for efficiency (CCFT 2019) | Covariate-adjusted estimation | `covs = Z` matrix of pre-treatment covariates |

## 6. Key Formulas

### 6.1 Sharp RD Point Estimator

The local-linear ($p = 1$) estimator of the sharp RD treatment effect:

$$\hat{\tau}_{\text{SRD}}(h) = \hat{\mu}_{+,1}(h) - \hat{\mu}_{-,1}(h)$$

where $\hat{\mu}_{+,1}(h)$ and $\hat{\mu}_{-,1}(h)$ are intercepts from weighted local-linear regressions fitted separately above and below the cutoff:

$$(\hat{\mu}_{+,1}(h), \hat{\mu}_{+,1}^{(1)}(h))' = \arg\min_{b_0, b_1} \sum_{i=1}^n \mathbb{1}(X_i \geq c)(Y_i - b_0 - b_1(X_i - c))^2 K\left(\frac{X_i - c}{h}\right)$$

### 6.2 Bias-Corrected Estimator

$$\hat{\tau}_{\text{SRD}}^{\text{bc}}(h, b) = \hat{\tau}_{\text{SRD}}(h) - h^2 \hat{\mathsf{B}}_{\text{SRD}}(h, b)$$

where the bias estimate uses local-quadratic fits with pilot bandwidth $b$:

$$\hat{\mathsf{B}}_{\text{SRD}}(h, b) = \frac{\hat{\mu}_{+,2}^{(2)}(b)}{2!} \mathcal{B}_{+,\text{SRD}}(h) - \frac{\hat{\mu}_{-,2}^{(2)}(b)}{2!} \mathcal{B}_{-,\text{SRD}}(h)$$

### 6.3 Robust Confidence Interval

$$\hat{I}_{\text{SRD}}^{\text{rbc}}(h, b) = \left[\hat{\tau}_{\text{SRD}}^{\text{bc}}(h, b) \pm z_{1-\alpha/2} \sqrt{\hat{\mathsf{V}}_{\text{SRD}}^{\text{bc}}(h, b)}\right]$$

where $\hat{\mathsf{V}}_{\text{SRD}}^{\text{bc}}(h, b)$ accounts for both the variance of the original estimator AND the additional variability from bias estimation.

### 6.4 MSE-Optimal Bandwidth (Local Linear, Sharp RD)

$$h_{\text{MSE}} = \left(\frac{\mathcal{V}}{2(p+1)\mathcal{B}^2}\right)^{1/(2p+3)} n^{-1/(2p+3)}$$

For $p = 1$: $h_{\text{MSE}} \propto n^{-1/5}$, where:
- $\mathcal{B} = \frac{\mu_+^{(2)}}{2} B_+ - \frac{\mu_-^{(2)}}{2} B_-$ (leading bias, depends on second derivatives)
- $\mathcal{V} = \frac{\sigma_-^2}{f} V_- + \frac{\sigma_+^2}{f} V_+$ (asymptotic variance, depends on conditional variances and density)

### 6.5 CE-Optimal Bandwidth (CCF 2020)

$$h_{\text{CER}} = \mathcal{H} \cdot n^{-1/(3+p)}$$

For $p = 1$: $h_{\text{CER}} \propto n^{-1/4}$, which is smaller than $h_{\text{MSE}} \propto n^{-1/5}$.

Rule-of-thumb implementation: $\hat{h}_{\text{CER}}^{\text{rot}} = n^{-p/((2p+3)(p+3))} \cdot \hat{h}_{\text{MSE}}$

### 6.6 Fuzzy RD Estimator

$$\hat{\tau}_{\text{FRD}}(h) = \frac{\hat{\tau}_{Y,\text{SRD}}(h)}{\hat{\tau}_{T,\text{SRD}}(h)} = \frac{\hat{\mu}_{Y+,1}(h) - \hat{\mu}_{Y-,1}(h)}{\hat{\mu}_{T+,1}(h) - \hat{\mu}_{T-,1}(h)}$$

This is a ratio of two sharp RD estimators—one for the outcome, one for the treatment variable.

### 6.7 IMSE-Optimal Number of Bins (rdplot)

$$J_-^{\text{IMSE}} = \lceil \mathcal{C}_-^{\text{IMSE}} \cdot n^{1/3} \rceil, \qquad J_+^{\text{IMSE}} = \lceil \mathcal{C}_+^{\text{IMSE}} \cdot n^{1/3} \rceil$$

where constants $\mathcal{C}_\pm^{\text{IMSE}}$ depend on the bin type (ES or QS) and features of the DGP.

### 6.8 Mimicking Variance Number of Bins (rdplot)

$$J_-^{\text{MV}} = \left\lceil \mathcal{C}_-^{\text{MV}} \frac{n}{\log(n)^2} \right\rceil, \qquad J_+^{\text{MV}} = \left\lceil \mathcal{C}_+^{\text{MV}} \frac{n}{\log(n)^2} \right\rceil$$

The MV method produces more bins than IMSE, better capturing data variability.

---

## References

- Calonico, S., Cattaneo, M. D., and Titiunik, R. (2014). "Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs." *Econometrica*, 82(6): 2295–2326.
- Calonico, S., Cattaneo, M. D., and Titiunik, R. (2015). "Optimal Data-Driven Regression Discontinuity Plots." *Journal of the American Statistical Association*, 110(512): 1753–1769.
- Calonico, S., Cattaneo, M. D., and Farrell, M. H. (2020). "Optimal Bandwidth Choice for Robust Bias-Corrected Inference in Regression Discontinuity Designs." *Econometrics Journal*, 23(2): 192–210.
- Cattaneo, M. D., Idrobo, N., and Titiunik, R. (2020). *A Practical Introduction to Regression Discontinuity Designs: Foundations.* Cambridge Elements.
- Hahn, J., Todd, P., and van der Klaauw, W. (2001). "Identification and Estimation of Treatment Effects with a Regression-Discontinuity Design." *Econometrica*, 69(1): 201–209.

---

**Note on CCT 2015 JASA MineRU Conversion**: The MineRU-converted Markdown for the CCT (2015) JASA paper (`Calonico-Cattaneo-Titiunik_2015_JASA/auto/`) contains incorrect content (a different paper on neutrino physics was extracted). The rdplot theory described above is synthesized from the CIT (2020) monograph Sections 3.1–3.2, which provides a comprehensive exposition of the IMSE and mimicking variance methods from the original CCT (2015) paper.
