# Method Card: Regression Discontinuity Design with Local Polynomial Estimation

## Overview

The Regression Discontinuity (RD) design exploits a known threshold rule in treatment assignment to identify a causal effect at the cutoff. `rdrobust` implements the local polynomial approach with robust bias-corrected inference developed primarily by Calonico, Cattaneo, Farrell, and Titiunik across a series of papers (2014–2020).

The core insight is that standard MSE-optimal bandwidths used with local polynomial estimators lead to confidence intervals with severe coverage distortions because the bandwidth is "too large" to eliminate the asymptotic bias. Rather than undersmoothing (using an ad hoc smaller bandwidth), rdrobust explicitly estimates the bias, corrects for it, and uses a novel variance formula that accounts for the additional variability introduced by bias estimation. This delivers confidence intervals that are valid even with MSE-optimal bandwidths.

---

## Mathematical Framework

### Sharp RD Design

**Setup**: Treatment \(D_i = \mathbf{1}(X_i \geq c)\) is a deterministic function of running variable \(X_i\) and cutoff \(c\).

**Estimand**:
\[\tau_{\text{SRD}} = \lim_{x \downarrow c} E[Y_i | X_i = x] - \lim_{x \uparrow c} E[Y_i | X_i = x]\]

Under the continuity assumption \(E[Y_i(0)|X_i = x]\) continuous at \(c\):
\[\tau_{\text{SRD}} = E[Y_i(1) - Y_i(0) | X_i = c]\]

### Fuzzy RD Design

**Setup**: Treatment probability jumps at cutoff but is not deterministic: \(0 < \lim_{x \downarrow c} P(D_i = 1 | X_i = x) - \lim_{x \uparrow c} P(D_i = 1 | X_i = x) < 1\).

**Estimand** (ratio of discontinuities):
\[\tau_{\text{FRD}} = \frac{\lim_{x \downarrow c} E[Y_i | X_i = x] - \lim_{x \uparrow c} E[Y_i | X_i = x]}{\lim_{x \downarrow c} E[D_i | X_i = x] - \lim_{x \uparrow c} E[D_i | X_i = x]}\]

This is a local Wald (IV) estimator; identifies LATE for compliers at the cutoff under monotonicity.

### Sharp Kink RD Design

**Estimand** (slope discontinuity in outcome):
\[\tau_{\text{SKRD}} = \lim_{x \downarrow c} \frac{\partial}{\partial x} E[Y_i | X_i = x] - \lim_{x \uparrow c} \frac{\partial}{\partial x} E[Y_i | X_i = x]\]

Implemented via `rdrobust(y, x, deriv = 1)`. Identifies the change in slope of the conditional mean at the cutoff.

### Fuzzy Kink RD Design

**Estimand** (ratio of derivative discontinuities):
\[\tau_{\text{FKRD}} = \frac{\lim_{x \downarrow c} \frac{\partial}{\partial x} E[Y_i | X_i = x] - \lim_{x \uparrow c} \frac{\partial}{\partial x} E[Y_i | X_i = x]}{\lim_{x \downarrow c} \frac{\partial}{\partial x} E[D_i | X_i = x] - \lim_{x \uparrow c} \frac{\partial}{\partial x} E[D_i | X_i = x]}\]

Implemented via `rdrobust(y, x, fuzzy = d, deriv = 1)`. This is a local IV estimator using derivative discontinuities.

---

## Core Theorems

### Theorem 1: Asymptotic Normality of the Robust Bias-Corrected t-Statistic (Sharp RD)

**Source**: Calonico, Cattaneo, and Titiunik (2014), *Econometrica* 82(6): 2295–2326, Section 2.1, p. 2301.

**Statement**: Let Assumptions 1–2 hold with smoothness \(S \geq 3\). If \(n \min\{h_n^5, b_n^5\} \cdot \max\{h_n^2, b_n^2\} \to 0\) and \(n \min\{h_n, b_n\} \to \infty\), then:

\[T_{\text{SRD}}^{\text{rbc}}(h_n, b_n) = \frac{\hat{\tau}_{\text{SRD}}^{\text{bc}}(h_n, b_n) - \tau_{\text{SRD}}}{\sqrt{\mathsf{V}_{\text{SRD}}^{\text{bc}}(h_n, b_n)}} \to_d \mathcal{N}(0, 1)\]

where:
- \(\hat{\tau}_{\text{SRD}}^{\text{bc}}(h_n, b_n) = \hat{\tau}_{\text{SRD}}(h_n) - h_n^2 \hat{\mathsf{B}}_{\text{SRD}}(h_n, b_n)\) is the bias-corrected estimator
- \(\mathsf{V}_{\text{SRD}}^{\text{bc}}(h_n, b_n) = \mathsf{V}_{\text{SRD}}(h_n) + \mathsf{C}_{\text{SRD}}^{\text{bc}}(h_n, b_n)\) incorporates the variance correction for bias estimation

**Conditions**:
1. **Smoothness**: \(\mu_+(x)\) and \(\mu_-(x)\) are at least 3 times continuously differentiable (\(S \geq 3\))
2. **Bandwidth rates**: \(n \min\{h_n^5, b_n^5\} \cdot \max\{h_n^2, b_n^2\} \to 0\) (bias shrinks faster than variance)
3. **Effective sample**: \(n \min\{h_n, b_n\} \to \infty\) (enough observations in bandwidth window)
4. **Bounded support**: \(\kappa \max\{h_n, b_n\} < \kappa_0\) (bandwidths stay within data support)

**Key Implications**:
1. The MSE-optimal bandwidth \(h_{\text{MSE}} \propto n^{-1/5}\) satisfies the rate conditions and is valid for robust inference (but NOT for conventional inference).
2. The variance formula \(\mathsf{V}_{\text{SRD}}^{\text{bc}}\) includes an additional correction term \(\mathsf{C}_{\text{SRD}}^{\text{bc}}\) that accounts for variability introduced by bias estimation — this is the key innovation over standard bias correction.
3. When \(h_n = b_n\) (same bandwidth for estimation and bias correction), the bias-corrected local-linear estimator is numerically equivalent to the local-quadratic estimator (CCT 2014, Remark 7).
4. The result permits \(\rho = h_n/b_n \to \rho \in [0, \infty]\), generalizing the standard requirement \(h_n/b_n \to 0\).

---

### Theorem 2: Coverage Error Optimality and CE-Optimal Bandwidth

**Source**: Calonico, Cattaneo, and Farrell (2020), *Econometrics Journal* 23(2): 192–210, Section 3, Theorems 3.1–3.2.

**Statement** (Theorem 3.1(b)): Under Assumption 2.1 with \(S \geq p + 2\), the coverage error of the RBC confidence interval satisfies:

\[\mathbb{P}[\tau_\nu \in I_{\text{RBC}}(h)] - (1 - \alpha) = \frac{1}{nh} \mathcal{Q}_{\text{RBC},1} + nh^{5+2p} \mathcal{Q}_{\text{RBC},2} + h^{2+p} \mathcal{Q}_{\text{RBC},3} + \epsilon_{\text{RBC}}\]

The CE-optimal bandwidth (Theorem 3.2) minimizes this coverage error:

\[h_{\text{RBC}} = \mathcal{H} \cdot n^{-1/(3+p)}\]

yielding coverage error:
\[\mathbb{P}[\tau_\nu \in I_{\text{RBC}}(h_{\text{RBC}})] = 1 - \alpha + O(n^{-(2+p)/(3+p)})\]

**Conditions**:
1. Smoothness \(S \geq p + 2\) (one derivative beyond what MSE requires)
2. \(nh^{1+2\nu}/\log(nh)^{2+\eta} \to \infty\) for some \(\eta > 0\)
3. \(\rho = h/b\) bounded and bounded away from zero

**Key Implications**:
1. The CE-optimal bandwidth rate \(n^{-1/(3+p)}\) differs from the MSE-optimal rate \(n^{-1/(2p+3)}\). For \(p = 1\): CE-optimal is \(n^{-1/4}\) vs MSE-optimal \(n^{-1/5}\).
2. RBC inference dominates undersmoothing: \(I_{\text{RBC}}(h_{\text{RBC}})\) has coverage error \(O(n^{-(2+p)/(3+p)})\) vs \(O(n^{-(1+p)/(2+p)})\) for the best undersmoothed interval.
3. A practical rule-of-thumb: shrink \(\hat{h}_{\text{MSE}}\) by factor \(n^{-p/((2p+3)(p+3))}\) to obtain CE-optimal bandwidth. For \(p = 1\), \(n = 500\): approximately 27% shrinkage.
4. This motivates the `bwselect = "cerrd"` option in `rdbwselect()`.

---

### Theorem 3: MSE-Optimal Bandwidth Rate

**Source**: Calonico, Cattaneo, and Titiunik (2014), *Econometrica*, Section 4.1, p. 2307 (Lemma 1).

**Statement**: Under Assumptions 1–2 with \(S \geq p + 1\), if \(h_n \to 0\) and \(nh_n \to \infty\), then the conditional MSE of the \(p\)th-order local polynomial estimator satisfies:

\[\text{MSE}_{
u,p,s}(h_n) = h_n^{2(p+1-
u)} \left[\mathsf{B}_{
u,p,p+1,s}^2 + o_p(1)\right] + \frac{1}{nh_n^{1+2
u}} \left[\mathsf{V}_{
u,p} + o_p(1)\right]\]

If \(\mathsf{B}_{\nu,p,p+1,s} \neq 0\), the MSE-optimal bandwidth is:

\[h_{\text{MSE},\nu,p,s} = \mathbf{C}_{\text{MSE},\nu,p,s}^{1/(2p+3)} \cdot n^{-1/(2p+3)}\]

where:
\[\mathbf{C}_{\text{MSE},
u,p,s} = \frac{(1+2
u)\mathsf{V}_{
u,p}}{2(p+1-
u)\mathsf{B}_{
u,p,p+1,s}^2}\]

**Conditions**:
1. Smoothness \(S \geq p + 1\) (sufficient to characterize leading bias)
2. Non-vanishing bias: \(\mathsf{B}_{\nu,p,p+1,s} \neq 0\)

**Key Implications**:
1. For the local-linear Sharp RD estimator (\(\nu = 0\), \(p = 1\)): \(h_{\text{MSE}} \propto n^{-1/5}\), the standard rate.
2. The bias depends on \((p+1)\)th derivatives: for \(p = 1\), the second derivatives \(\mu_+^{(2)}\) and \(\mu_-^{(2)}\) determine the leading bias.
3. The MSE-optimal bandwidth for the bias estimator is \(b_{\text{MSE}} = h_{\text{MSE},2,2,2}\) (for Sharp RD with \(p = 1\)).
4. These MSE-optimal choices are valid for the robust confidence intervals (CCT 2014, Remark 10) but NOT for conventional confidence intervals.
5. This formula underlies the `bwselect = "mserd"` option in `rdbwselect()`.

---

## Identification Assumptions (5-Dimension Coverage)

### Assumption 1: Continuity of Conditional Expectation Functions at Cutoff

| Dimension | Content |
|-----------|---------|
| **D1: Formal** | \(\mathbb{E}[Y_i(1) \mid X_i = x]\) and \(\mathbb{E}[Y_i(0) \mid X_i = x]\) are continuous at \(x = c\). This implies \(\tau_{\text{SRD}} = \lim_{x \downarrow c} \mathbb{E}[Y_i \mid X_i = x] - \lim_{x \uparrow c} \mathbb{E}[Y_i \mid X_i = x]\). |
| **D2: Intuition** | Units just above and just below the cutoff have similar average potential outcomes. The outcome does not "jump" except through the treatment channel. All confounders vary smoothly through the cutoff. |
| **D3: Testability** | Not directly testable for the outcome of interest (since both potential outcomes are never observed at the cutoff). However, testable implications arise for pre-treatment covariates: if the design is valid, predetermined covariates should show no discontinuity at the cutoff. |
| **D4: Diagnostic** | Use `rdrobust()` with pre-treatment covariates as outcomes (placebo/falsification tests). **R**: `rdrobust(covariate, x)` for each covariate. **Stata**: `rdrobust covariate runvar`. A statistically significant jump in a covariate (p < 0.05) casts doubt on continuity. |
| **D5: Violation Consequence** | If violated, the estimated treatment effect conflates the true causal effect with a discontinuity in potential outcomes caused by unobserved confounders. The RD estimate becomes biased and loses causal interpretation. |

### Assumption 2: No Manipulation of the Running Variable (Density Continuity)

| Dimension | Content |
|-----------|---------|
| **D1: Formal** | The density \(f(x)\) of the running variable \(X_i\) is continuous at the cutoff \(c\): \(\lim_{x \downarrow c} f(x) = \lim_{x \uparrow c} f(x)\). Equivalently, units cannot precisely sort themselves to one side of the cutoff. |
| **D2: Intuition** | If individuals can manipulate their score to land just above (or below) the cutoff, the groups on either side become systematically different and comparability breaks down. A discontinuity in the density at the cutoff suggests manipulation. |
| **D3: Testability** | Directly testable. A discontinuity in the density of the running variable at the cutoff indicates manipulation. |
| **D4: Diagnostic** | McCrary (2008) density test; Cattaneo, Jansson, and Ma (2020) `rddensity` package provides a formal manipulation test based on local polynomial density estimation. **R/Python**: `rddensity(x, c = cutoff)`. **Stata**: `rddensity runvar, c(cutoff)`. Reject H0 if p < 0.05. |
| **D5: Violation Consequence** | Selective sorting around the cutoff implies that units just above and below differ systematically in unobservable characteristics. The treatment effect estimate captures both the causal effect and the selection bias from manipulation. |

### Assumption 3: Local Regularity / Smoothness Conditions

| Dimension | Content |
|-----------|---------|
| **D1: Formal** | (CCT 2014, Assumption 1): (a) \(\mathbb{E}[Y_i^4 \mid X_i = x]\) is bounded and \(f(x)\) is continuous and bounded away from zero in a neighborhood \((-\kappa_0, \kappa_0)\) around the cutoff. (b) \(\mu_-(x)\) and \(\mu_+(x)\) are \(S\) times continuously differentiable (\(S \geq 3\) for Theorem 1). (c) \(\sigma^2_-(x)\) and \(\sigma^2_+(x)\) are continuous and bounded away from zero. |
| **D2: Intuition** | The regression functions must be "smooth enough" on each side of the cutoff to justify local polynomial approximation. The density must be positive near the cutoff (ensuring observations exist). The conditional variance must be well-behaved to permit standard error estimation. |
| **D3: Testability** | The smoothness order \(S\) is untestable in practice, but higher-order polynomial fits and sensitivity to polynomial order provide informal evidence. Density positivity is observable. |
| **D4: Diagnostic** | Compare estimates across polynomial orders \(p = 1, 2, 3\). Large sensitivity to polynomial order suggests insufficient smoothness relative to bandwidth. Use `rdbwselect()` to check stability of bandwidth choices across specifications. |
| **D5: Violation Consequence** | If smoothness is insufficient (e.g., the true regression function has a kink or rapid oscillation near the cutoff), the polynomial approximation is poor, bias estimates are unreliable, and confidence intervals have incorrect coverage. |

### Assumption 4: SUTVA / No Interference Near Cutoff

| Dimension | Content |
|-----------|---------|
| **D1: Formal** | The observed outcome for unit \(i\) depends only on its own treatment status: \(Y_i = Y_i(0)(1 - T_i) + Y_i(1) T_i\), where \(T_i = \mathbb{1}(X_i \geq c)\). There is no interference between units. |
| **D2: Intuition** | Each unit's outcome is determined solely by whether that unit is treated or not. There are no spillover effects between treated and control units near the cutoff. |
| **D3: Testability** | Generally untestable without additional data or structural assumptions. In some designs (e.g., geographic RD), spatial spillovers can be examined. |
| **D4: Diagnostic** | Check for discontinuities at "donut" specifications (excluding observations very close to the cutoff). In geographic or network settings, test whether outcomes of nearby untreated units change at the cutoff. |
| **D5: Violation Consequence** | With interference, the potential outcomes \(Y_i(0)\) and \(Y_i(1)\) are ill-defined (they depend on other units' treatments). The RD estimand no longer has a clean causal interpretation as an individual-level treatment effect. |

### Assumption 5: (Fuzzy RD) First-Stage Relevance and Monotonicity

| Dimension | Content |
|-----------|---------|
| **D1: Formal** | (CCT 2014, Assumption 3): (a) \(\mu_{T-}(x) = \mathbb{E}[T_i(0) \mid X_i = x]\) and \(\mu_{T+}(x) = \mathbb{E}[T_i(1) \mid X_i = x]\) are \(S\) times continuously differentiable. (b) \(\tau_{T,\text{SRD}} = \mu_{T+} - \mu_{T-} \neq 0\) (first-stage relevance). (c) Monotonicity: \(T_i(1) \geq T_i(0)\) for all \(i\) (or vice versa). |
| **D2: Intuition** | Crossing the cutoff must actually change the probability of receiving treatment (first stage is nonzero). The direction of the change should be uniform across individuals (monotonicity ensures no "defiers"). |
| **D3: Testability** | First-stage relevance is directly testable by examining the discontinuity in the treatment take-up probability at the cutoff. Monotonicity is generally untestable. |
| **D4: Diagnostic** | Use `rdrobust()` with the treatment indicator as the outcome to estimate the first-stage discontinuity. **R**: `rdrobust(treatment, x)`. **Stata**: `rdrobust treatment runvar`. A small or insignificant first stage indicates weak instruments. Use `rdplot()` to visualize the treatment probability jump. |
| **D5: Violation Consequence** | If \(\tau_{T,\text{SRD}} = 0\), the Fuzzy RD estimator \(\tau_{\text{FRD}} = \tau_{Y,\text{SRD}} / \tau_{T,\text{SRD}}\) is undefined (division by zero). If monotonicity fails, the estimand loses its LATE interpretation and becomes a weighted average over heterogeneous complier types with potentially negative weights. |

---

## Method Variants

### Sharp RD

| Aspect | Detail |
|--------|--------|
| **Estimand** | \(\tau_{\text{SRD}} = \mathbb{E}[Y_i(1) - Y_i(0) \mid X_i = c]\) — ATE at the cutoff |
| **Identification** | Continuity of \(\mathbb{E}[Y_i(d) \mid X_i = x]\) at \(c\) (Hahn, Todd, van der Klaauw 2001) |
| **Treatment rule** | \(D_i = \mathbb{1}(X_i \geq c)\) — deterministic |
| **Estimator** | Difference of local-linear intercepts: \(\hat{\tau} = \hat{\mu}_{+,1}(h) - \hat{\mu}_{-,1}(h)\) |
| **Polynomial order** | \(p = 1\) (local linear); bias correction uses \(q = 2\) (local quadratic) |
| **Smoothness required** | \(S \geq 3\) |
| **rdrobust call** | `rdrobust(y, x, c = cutoff)` — default, no `fuzzy` argument |
| **When to use** | Treatment perfectly determined by crossing the cutoff (e.g., age thresholds, test score cutoffs, vote margins) |

### Fuzzy RD

| Aspect | Detail |
|--------|--------|
| **Estimand** | \(\tau_{\text{FRD}} = \frac{\mu_{Y+} - \mu_{Y-}}{\mu_{T+} - \mu_{T-}}\) — LATE for compliers at the cutoff |
| **Identification** | Continuity + first-stage relevance + monotonicity (CCT 2014, Theorem 3) |
| **Treatment rule** | \(D_i\) probabilistic; \(P(D_i = 1 \mid X_i = x)\) jumps at \(c\) but not from 0 to 1 |
| **Estimator** | Ratio of two sharp RD estimators (outcome / treatment) — local Wald |
| **Polynomial order** | \(p = 1\) for both numerator and denominator; \(q = 2\) for bias correction |
| **Additional assumptions** | First-stage relevance (\(\tau_{T,\text{SRD}} \neq 0\)) and monotonicity |
| **rdrobust call** | `rdrobust(y, x, fuzzy = T, c = cutoff)` where T is treatment variable |
| **When to use** | Treatment is encouraged (not mandated) at the cutoff; imperfect compliance (e.g., eligibility for program but voluntary enrollment) |

### Kink RD

| Aspect | Detail |
|--------|--------|
| **Estimand** | \(\tau_{\text{KRD}} = \mu_+^{(1)} - \mu_-^{(1)}\) — change in slope of the regression function at the cutoff |
| **Identification** | Continuity of the level (no jump) but discontinuity in the first derivative |
| **Treatment rule** | Treatment intensity changes slope at \(c\) (not level) |
| **Estimator** | Difference of local-quadratic first-derivative estimates |
| **Polynomial order** | \(p = 2\) (local quadratic); bias correction uses \(q = 3\) (local cubic) |
| **Smoothness required** | \(S \geq 4\) |
| **rdrobust call** | `rdrobust(y, x, deriv = 1, c = cutoff)` |
| **When to use** | Policy creates a kink (slope change) rather than a jump — e.g., tax rate kinks, benefit formula kinks |

### Method Variants Comparison Table

| Feature | Sharp RD | Fuzzy RD | Kink RD |
|---------|----------|----------|---------|
| **Estimand** | ATE at cutoff | LATE for compliers at cutoff | Change in slope |
| **Treatment rule** | Deterministic | Probabilistic | Slope change |
| **Estimator** | Difference of intercepts | Ratio of two SRD estimators | Difference of derivatives |
| **Default p** | 1 | 1 | 2 |
| **Bias correction q** | 2 | 2 | 3 |
| **Smoothness** | \(S \geq 3\) | \(S \geq 3\) + Assumption 5 | \(S \geq 4\) |
| **CCT 2014 Theorem** | Theorem 1 | Theorem 3 | Theorem 2 |
| **rdrobust parameter** | Default | `fuzzy = T` | `deriv = 1` |

---

## Comparative Analysis: RD vs. Other Causal Methods

| Feature | RD (rdrobust) | Instrumental Variables | Matching | Difference-in-Differences |
|---------|--------------|----------------------|----------|--------------------------|
| **Identifying assumption** | Continuity at cutoff | Exclusion restriction + relevance | Conditional independence (CIA) | Parallel trends |
| **Estimand** | LATE at cutoff | LATE for compliers (global) | ATT / ATE | ATT |
| **Scope of effect** | Local (at threshold only) | Potentially global | Global (conditional on covariates) | Global (over time) |
| **Data requirements** | Running variable with known cutoff | Instrument + endogenous variable | Rich covariates for overlap | Panel data or repeated cross-sections |
| **Key diagnostic** | Density test + covariate balance | First-stage F-stat (> 10) | Balance table + overlap | Pre-treatment parallel trends |
| **Bandwidth / tuning** | Critical (h via MSE/CER) | Not applicable | Caliper width | Not applicable |
| **Manipulation concern** | Sorting at cutoff | Instrument validity (untestable) | Unobserved confounders | Violation of parallel trends |
| **External validity** | Low (effect only at cutoff) | Depends on complier heterogeneity | Moderate (conditional on overlap) | Moderate (treated group) |
| **Functional form** | Local polynomial (nonparametric) | Typically linear 2SLS | Nonparametric | Typically linear |
| **When preferred** | Clear institutional threshold exists | Strong instrument available, no threshold | Rich observational data, no time variation | Policy staggered over time |

---

## Estimation Method

### Local Polynomial Regression

For each side of the cutoff (\(s \in \{l, r\}\)), fit a weighted polynomial regression within bandwidth \(h\):

\[\hat{\beta}_s = \arg\min_{\beta} \sum_{i: X_i \in \mathcal{N}_s(c, h)} \left(Y_i - \sum_{j=0}^{p} \beta_j (X_i - c)^j\right)^2 K\left(\frac{X_i - c}{h}\right)\]

where \(K(\cdot)\) is the kernel function and \(\mathcal{N}_s(c, h)\) denotes observations within bandwidth \(h\) on side \(s\).

The RD estimate is: \(\hat{\tau} = \hat{\beta}_{r,0} - \hat{\beta}_{l,0}\)

### Bias Correction

The local polynomial estimator has bias of order \(O(h^{p+1})\). The bias-corrected estimator uses a higher-order polynomial (order \(q > p\)) with a potentially different bandwidth \(b\):

\[\hat{\tau}_{\text{bc}} = \hat{\tau} - \hat{B}\]

where:
\[\hat{B} = h^{p+1}\left[\frac{\hat{\mu}_{+}^{(p+1)}(b)}{(p+1)!} \mathcal{B}_{+}(h) - \frac{\hat{\mu}_{-}^{(p+1)}(b)}{(p+1)!} \mathcal{B}_{-}(h)\right]\]

The bias estimate \(\hat{B}\) is computed from local polynomial regressions of order \(q = p + 1\) with pilot bandwidth \(b\).

### Robust Variance Estimation

The robust bias-corrected (RBC) confidence interval accounts for the additional variability introduced by bias estimation:

\[CI_{\text{RBC}} = \left[\hat{\tau}_{\text{bc}} \pm z_{\alpha/2} \cdot \sqrt{\hat{\mathsf{V}}^{\text{bc}}}\right]\]

where \(\hat{\mathsf{V}}^{\text{bc}} = \hat{\mathsf{V}}(\hat{\tau}) + \hat{\mathsf{C}}^{\text{bc}}\) incorporates both:
- \(\hat{\mathsf{V}}(\hat{\tau})\): variance of the original (uncorrected) estimator
- \(\hat{\mathsf{C}}^{\text{bc}}\): additional variance from estimating the bias term

Key result from CCT (2014): conventional CIs using \(\hat{\tau}\) with standard SE have *incorrect* coverage when MSE-optimal bandwidths are used. The RBC CI achieves correct coverage uniformly.

---

## Bandwidth Selection

### MSE-Optimal Bandwidth

The MSE-optimal bandwidth minimizes the mean squared error of the point estimator:

\[h_{\text{MSE}} = \arg\min_h \text{MSE}(\hat{\tau}(h)) = \arg\min_h \left[\text{Bias}^2(\hat{\tau}(h)) + \text{Var}(\hat{\tau}(h))\right]\]

For local linear (\(p = 1\)):
\[h_{\text{MSE}} = \left(\frac{\mathcal{V}}{2(p+1)\mathcal{B}^2}\right)^{1/(2p+3)} n^{-1/(2p+3)} = \left(\frac{\mathcal{V}}{4\mathcal{B}^2}\right)^{1/5} n^{-1/5}\]

where:
- \(\mathcal{B} = \frac{\mu_+^{(2)}}{2} B_+ - \frac{\mu_-^{(2)}}{2} B_-\) (leading bias, depends on second derivatives)
- \(\mathcal{V} = \frac{\sigma_-^2}{f} V_- + \frac{\sigma_+^2}{f} V_+\) (asymptotic variance, depends on conditional variances and density)

### CER-Optimal Bandwidth

The Coverage Error Rate (CER) optimal bandwidth minimizes the coverage error of the confidence interval:

\[h_{\text{CER}} = \arg\min_h |P(\tau \in CI(h)) - (1-\alpha)|\]

For \(p = 1\): \(h_{\text{CER}} \propto n^{-1/4}\), which is smaller than \(h_{\text{MSE}} \propto n^{-1/5}\).

Rule-of-thumb: \(\hat{h}_{\text{CER}}^{\text{rot}} = n^{-p/((2p+3)(p+3))} \cdot \hat{h}_{\text{MSE}}\)

CER bandwidth is typically smaller than MSE bandwidth (more conservative, better coverage).

### Bandwidth Selection Variants

| Method | Description | Use Case |
|--------|-------------|----------|
| `mserd` | Common MSE-optimal | Default; single bandwidth both sides |
| `msetwo` | Two MSE-optimal (left/right) | Asymmetric data density |
| `msesum` | MSE-optimal for sum of estimates | Sum estimand |
| `msecomb1` | min(mserd, msesum) | Conservative MSE |
| `msecomb2` | median(msetwo, mserd, msesum) | Robust MSE |
| `cerrd` | Common CER-optimal | Coverage-focused inference |
| `certwo` | Two CER-optimal (left/right) | Asymmetric + coverage |
| `cersum` | CER-optimal for sum | Sum + coverage |
| `cercomb1` | min(cerrd, cersum) | Conservative CER |
| `cercomb2` | median(certwo, cerrd, cersum) | Robust CER |

---

## Parameter Priority Ranking

### Critical Parameters (must specify correctly)

| Priority | Parameter | Default | Rationale |
|----------|-----------|---------|-----------|
| 🔴 Critical | `y` | — | Outcome variable; defines the estimand |
| 🔴 Critical | `x` | — | Running variable; defines the identification strategy |
| 🔴 Critical | `c` | 0 | Cutoff value; must match institutional rule exactly |
| 🔴 Critical | `bwselect` | `"mserd"` | Bandwidth method; MSE-optimal is the theoretically justified default |

### Important Parameters (affect methodology)

| Priority | Parameter | Default | Rationale |
|----------|-----------|---------|-----------|
| 🟡 Important | `p` | 1 | Polynomial order; p=1 is optimal for boundary estimation (Fan & Gijbels 1996) |
| 🟡 Important | `q` | p+1 | Bias correction order; must be > p for valid bias estimation |
| 🟡 Important | `kernel` | `"tri"` | Kernel function; triangular is MSE-optimal for boundary problems (Triangular kernel) |
| 🟡 Important | `vce` | `"nn"` | Variance estimator; nearest-neighbor is default; cluster for clustered data |
| 🟡 Important | `fuzzy` | NULL | Treatment variable for Fuzzy RD; changes the estimand to LATE |
| 🟡 Important | `deriv` | 0 | Derivative order; 0 = level discontinuity, 1 = kink |

### Optional Parameters (fine-tuning)

| Priority | Parameter | Default | Rationale |
|----------|-----------|---------|-----------|
| 🟢 Optional | `h` | data-driven | Manual bandwidth override; use only for robustness checks |
| 🟢 Optional | `b` | data-driven | Manual bias bandwidth; rarely needs override |
| 🟢 Optional | `covs` | NULL | Pre-treatment covariates for efficiency; does not change consistency |
| 🟢 Optional | `cluster` | NULL | Cluster variable for cluster-robust VCE |
| 🟢 Optional | `masspoints` | `"adjust"` | Mass point handling; adjust is safe default |
| 🟢 Optional | `scaleregul` | 1 | Regularization for bandwidth selection; 0 = no regularization |
| 🟢 Optional | `nnmatch` | 3 | Number of neighbors for NN variance; rarely changed |
| 🟢 Optional | `weights` | NULL | Observation weights; for survey data |

---

## Kernel Functions

| Kernel | Formula | Properties |
|--------|---------|------------|
| Triangular (default) | \(K(u) = (1-|u|)\mathbf{1}(|u| \leq 1)\) | MSE-optimal for boundary estimation; gives more weight to obs near cutoff |
| Epanechnikov | \(K(u) = \frac{3}{4}(1-u^2)\mathbf{1}(|u| \leq 1)\) | MSE-optimal for interior estimation |
| Uniform | \(K(u) = \frac{1}{2}\mathbf{1}(|u| \leq 1)\) | Equal weights; equivalent to OLS within window |

---

## Variance-Covariance Estimation

### Heteroskedasticity-Robust Options

| Method | Description |
|--------|-------------|
| `nn` (default) | Nearest-neighbor variance estimator; uses `nnmatch` nearest obs |
| `hc0` | White heteroskedasticity-robust (no finite-sample correction) |
| `hc1` | HC1 with (n-1)/(n-k) correction |
| `hc2` | HC2 with leverage adjustment |
| `hc3` | HC3 jackknife-like (most conservative) |

### Cluster-Robust Options

| Method | Description |
|--------|-------------|
| `cr1` | Cluster-robust with degrees-of-freedom correction |
| `cr2` | Bell-McCaffrey (2002) bias-reduced CRV2; recommended for few clusters |
| `cr3` | Pustejovsky-Tipton (2018) leave-one-cluster-out jackknife; most conservative |

---

## Covariates in RD

Following Calonico, Cattaneo, Farrell, and Titiunik (2019), covariates enter the RD estimation to improve efficiency without changing the point estimate (asymptotically). The covariate-adjusted estimator:

\[\hat{\tau}_{\text{adj}} = \hat{\tau} - \hat{\gamma}'(\bar{Z}_r - \bar{Z}_l)\]

Key properties:
- Point estimate is asymptotically equivalent (covariates do not affect consistency)
- Standard errors can decrease substantially with good covariates
- Bandwidth selection accounts for covariates
- Collinear covariates are automatically dropped (when `covs_drop = TRUE`)

---

## Mass Points and Discrete Running Variables

When the running variable has repeated values (mass points), standard smoothness assumptions are locally violated. `rdrobust` handles this via the `masspoints` option:

- `"off"`: Ignore mass points (not recommended)
- `"check"`: Report number of unique values per side
- `"adjust"` (default): Ensure minimum number of unique observations in bandwidth window

---

## Theoretical Convergence Rates

| Component | Rate | Notes |
|-----------|------|-------|
| Point estimator bias | \(n^{-(p+1)/(2p+3)}\) | For local linear (p=1): \(n^{-2/5}\) |
| Point estimator std dev | \(n^{-1/2}h^{-1/2}\) | Depends on bandwidth |
| MSE-optimal bandwidth | \(h \sim n^{-1/(2p+3)}\) | For p=1: \(h \sim n^{-1/5}\) |
| CER-optimal bandwidth | \(h \sim n^{-1/(3+p)}\) | Typically smaller than MSE |
| RBC coverage error | \(n^{-(2+p)/(3+p)}\) | For p=1: \(n^{-3/4}\) |
| Conventional coverage error | Does not vanish with MSE bandwidth | Invalid inference |
| Bias-corrected estimator | Additional \(b^{-(q+1)}\) term | Accounts for bias estimation error |

---

## Innovation Mapping: Theory to Software

| Theoretical Result | Software Implementation | Parameter/Function |
|--------------------|------------------------|-------------------|
| Theorem 1 (RBC normality, Sharp RD) | `rdrobust()` default inference | `all = TRUE` in summary shows all rows |
| Theorem 2 (RBC normality, Kink RD) | `rdrobust()` with derivative | `deriv = 1` |
| Theorem 3 (RBC normality, Fuzzy RD) | `rdrobust()` with fuzzy option | `fuzzy = T` |
| MSE-optimal bandwidth (Lemma 1) | `rdbwselect()` MSE criteria | `bwselect = "mserd"` |
| CE-optimal bandwidth (CCF 2020) | `rdbwselect()` CER criteria | `bwselect = "cerrd"` |
| ROT bandwidth shrinkage | Internal to `rdbwselect()` | \(n^{-p/((2p+3)(p+3))}\) factor |
| Assumption 1 (continuity) | Placebo/falsification tests | `rdrobust(covariate, x)` |
| Assumption 2 (no manipulation) | Density test | `rddensity` package |
| Nearest-neighbor variance | `rdrobust()` default VCE | `vce = "nn"`, `nnmatch = 3` |
| IMSE-optimal binning (CCT 2015) | `rdplot()` bin selection | `binselect = "es"`, `"qs"` |
| Mimicking variance binning | `rdplot()` MV bins | `binselect = "esmv"` (default) |
| Covariate adjustment (CCFT 2019) | Covariate-adjusted estimation | `covs = Z` |

---

## Key Formulas

### Sharp RD Point Estimator

The local-linear (\(p = 1\)) estimator:

\[\hat{\tau}_{\text{SRD}}(h) = \hat{\mu}_{+,1}(h) - \hat{\mu}_{-,1}(h)\]

where each intercept solves:
\[(\hat{\mu}_{+,1}(h), \hat{\mu}_{+,1}^{(1)}(h))' = \arg\min_{b_0, b_1} \sum_{i: X_i \geq c} (Y_i - b_0 - b_1(X_i - c))^2 K\left(\frac{X_i - c}{h}\right)\]

### Bias-Corrected Estimator

\[\hat{\tau}_{\text{SRD}}^{\text{bc}}(h, b) = \hat{\tau}_{\text{SRD}}(h) - h^2 \hat{\mathsf{B}}_{\text{SRD}}(h, b)\]

### Robust Confidence Interval

\[\hat{I}_{\text{SRD}}^{\text{rbc}}(h, b) = \left[\hat{\tau}_{\text{SRD}}^{\text{bc}}(h, b) \pm z_{1-\alpha/2} \sqrt{\hat{\mathsf{V}}_{\text{SRD}}^{\text{bc}}(h, b)}\right]\]

### Fuzzy RD Estimator

\[\hat{\tau}_{\text{FRD}}(h) = \frac{\hat{\tau}_{Y,\text{SRD}}(h)}{\hat{\tau}_{T,\text{SRD}}(h)} = \frac{\hat{\mu}_{Y+,1}(h) - \hat{\mu}_{Y-,1}(h)}{\hat{\mu}_{T+,1}(h) - \hat{\mu}_{T-,1}(h)}\]

### IMSE-Optimal Number of Bins (rdplot)

\[J_-^{\text{IMSE}} = \lceil \mathcal{C}_-^{\text{IMSE}} \cdot n^{1/3} \rceil, \qquad J_+^{\text{IMSE}} = \lceil \mathcal{C}_+^{\text{IMSE}} \cdot n^{1/3} \rceil\]

---

## Key References

1. **Identification**: Hahn, Todd, and van der Klaauw (2001). "Identification and Estimation of Treatment Effects with a Regression-Discontinuity Design." *Econometrica* 69(1): 201-209.
2. **Robust Inference**: Calonico, Cattaneo, and Titiunik (2014). "Robust Nonparametric Confidence Intervals for Regression-Discontinuity Designs." *Econometrica* 82(6): 2295-2326.
3. **Bias Estimation Effect**: Calonico, Cattaneo, and Farrell (2018). *JASA* 113(522): 767-779.
4. **Covariates**: Calonico, Cattaneo, Farrell, and Titiunik (2019). *Review of Economics and Statistics* 101(3): 442-451.
5. **Optimal Bandwidth**: Calonico, Cattaneo, and Farrell (2020). *Econometrics Journal* 23(2): 192-210.
6. **RD Plots**: Calonico, Cattaneo, and Titiunik (2015). *JASA* 110(512): 1753-1769.
7. **Practical Guide**: Cattaneo, Idrobo, and Titiunik (2020). *A Practical Introduction to Regression Discontinuity Designs*. Cambridge Elements.
8. **Density Testing**: Cattaneo, Jansson, and Ma (2020). "Simple Local Polynomial Density Estimators." *JASA* 115(531): 1449-1455.
