# rdrobust — Basic Sharp RD Example (R)
# Data: U.S. Senate Elections (built-in rdrobust_RDsenate)
# Running variable: vote margin (X), Cutoff: 0
# Outcome: vote share in next election (Y)
# Reference: Calonico, Cattaneo, and Titiunik (2014, Econometrica)

# ============================================================
# Step 1: Installation and Setup
# ============================================================
# install.packages("rdrobust")
library(rdrobust)

# ============================================================
# Step 2: Load Data
# ============================================================
data(rdrobust_RDsenate)
y <- rdrobust_RDsenate$vote    # outcome: vote share next election
x <- rdrobust_RDsenate$margin  # running variable: vote margin (win/loss)

cat("Sample size:", length(y), "\n")
cat("Running variable range: [", min(x), ",", max(x), "]\n")
cat("Observations left of cutoff:", sum(x < 0), "\n")
cat("Observations right of cutoff:", sum(x >= 0), "\n")

# ============================================================
# Step 3: RD Plot (Visualization)
# ============================================================
rdplot(y, x, c = 0,
       binselect = "esmv",
       title = "RD Plot: U.S. Senate Elections",
       x.label = "Vote Margin (Running Variable)",
       y.label = "Vote Share Next Election")

# ============================================================
# Step 4: Data-Driven Bandwidth Selection
# ============================================================
bw <- rdbwselect(y, x, c = 0)
summary(bw)

# Also compute all available methods
bw_all <- rdbwselect(y, x, c = 0, all = TRUE)
summary(bw_all)

# ============================================================
# Step 5: Main Estimation (Sharp RD, MSE-Optimal Bandwidth)
# ============================================================
out <- rdrobust(y, x, c = 0)
summary(out)

# ============================================================
# Step 6: Robustness Checks
# ============================================================

# --- 6a: Bandwidth sensitivity ---
h_opt <- out$bws[1, 1]  # MSE-optimal bandwidth (left)

out_half <- rdrobust(y, x, c = 0, h = h_opt / 2)
out_double <- rdrobust(y, x, c = 0, h = h_opt * 2)

cat("\n--- Bandwidth Sensitivity ---\n")
cat(sprintf("h = %.2f (half):   tau = %.4f, p_rb = %.4f\n",
            h_opt / 2, out_half$coef[3], out_half$pv[3]))
cat(sprintf("h = %.2f (optimal): tau = %.4f, p_rb = %.4f\n",
            h_opt, out$coef[3], out$pv[3]))
cat(sprintf("h = %.2f (double): tau = %.4f, p_rb = %.4f\n",
            h_opt * 2, out_double$coef[3], out_double$pv[3]))

# --- 6b: Polynomial order sensitivity ---
cat("\n--- Polynomial Sensitivity ---\n")
for (p_order in 1:3) {
  out_p <- rdrobust(y, x, c = 0, p = p_order)
  cat(sprintf("p = %d: tau = %.4f, robust p-val = %.4f\n",
              p_order, out_p$coef[3], out_p$pv[3]))
}

# --- 6c: Kernel sensitivity ---
cat("\n--- Kernel Sensitivity ---\n")
for (kern in c("triangular", "epanechnikov", "uniform")) {
  out_k <- rdrobust(y, x, c = 0, kernel = kern)
  cat(sprintf("kernel = %-13s: tau = %.4f, p_rb = %.4f\n",
              kern, out_k$coef[3], out_k$pv[3]))
}

# --- 6d: CER-optimal bandwidth ---
out_cer <- rdrobust(y, x, c = 0, bwselect = "cerrd")
cat("\n--- CER-optimal bandwidth ---\n")
cat(sprintf("CER: tau = %.4f, h = %.4f, p_rb = %.4f\n",
            out_cer$coef[3], out_cer$bws[1, 1], out_cer$pv[3]))

# ============================================================
# Step 7: Results Interpretation
# ============================================================
cat("\n==============================\n")
cat("MAIN RESULTS SUMMARY\n")
cat("==============================\n")
cat("Point estimate (conventional):", round(out$coef[1], 4), "\n")
cat("Point estimate (bias-corrected):", round(out$coef[2], 4), "\n")
cat("RBC Point estimate:", round(out$coef[3], 4), "\n")
cat("Robust SE:", round(out$se[3], 4), "\n")
cat("Robust 95% CI: [", round(out$ci[3, 1], 4), ",",
    round(out$ci[3, 2], 4), "]\n")
cat("Robust p-value:", round(out$pv[3], 4), "\n")
cat("Bandwidth h (left/right):", round(out$bws[1, 1], 4), "/",
    round(out$bws[1, 2], 4), "\n")
cat("Effective N (left/right):", out$N_h[1], "/", out$N_h[2], "\n")
cat("Kernel:", out$kernel, "\n")
cat("BW selection:", out$bwselect, "\n")
cat("VCE method:", out$vce, "\n")

# Expected: RBC point estimate approximately 7-8 (positive incumbency effect)
# Expected: Robust 95% CI roughly [4, 11], p-value < 0.05
# Expected: MSE-optimal bandwidth h approximately 16-17
# Expected: Effective N (left/right) approximately 300-400
