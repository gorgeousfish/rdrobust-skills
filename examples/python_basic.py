"""
rdrobust — Basic Sharp RD Example (Python)
Data: U.S. Senate Elections (built-in rdrobust_RDsenate)
Running variable: vote margin (X), Cutoff: 0
Outcome: vote share in next election (Y)
Reference: Calonico, Cattaneo, and Titiunik (2014, Econometrica)
"""

# ============================================================
# Step 1: Installation and Setup
# ============================================================
# pip install rdrobust
import numpy as np
import pandas as pd
from rdrobust import rdrobust, rdbwselect, rdplot

# ============================================================
# Step 2: Load Data
# ============================================================
from rdrobust.datasets import rdrobust_RDsenate

data = rdrobust_RDsenate()
y = data['vote'].values       # outcome: vote share next election
x = data['margin'].values     # running variable: vote margin

print(f"Sample size: {len(y)}")
print(f"Running variable range: [{x.min():.4f}, {x.max():.4f}]")
print(f"Observations left of cutoff: {np.sum(x < 0)}")
print(f"Observations right of cutoff: {np.sum(x >= 0)}")

# ============================================================
# Step 3: RD Plot (Visualization)
# ============================================================
rdplot(y, x, c=0,
       binselect="esmv",
       title="RD Plot: U.S. Senate Elections",
       x_label="Vote Margin (Running Variable)",
       y_label="Vote Share Next Election")

# ============================================================
# Step 4: Data-Driven Bandwidth Selection
# ============================================================
bw = rdbwselect(y, x, c=0)
print("\n--- Bandwidth Selection (MSE-RD) ---")
print(bw[0])  # bw[0] is the DataFrame of bandwidths

# All available methods
bw_all = rdbwselect(y, x, c=0, all=True)
print("\n--- All Bandwidth Methods ---")
print(bw_all[0])

# ============================================================
# Step 5: Main Estimation (Sharp RD, MSE-Optimal Bandwidth)
# ============================================================
out = rdrobust(y, x, c=0)
print(out)

# ============================================================
# Step 6: Robustness Checks
# ============================================================

# --- 6a: Bandwidth sensitivity ---
h_opt = out.bws.iloc[0, 0]  # MSE-optimal bandwidth (left)

out_half = rdrobust(y, x, c=0, h=h_opt / 2)
out_double = rdrobust(y, x, c=0, h=h_opt * 2)

print("\n--- Bandwidth Sensitivity ---")
print(f"h = {h_opt/2:.2f} (half):    tau = {out_half.coef.iloc[2]:.4f}, "
      f"p_rb = {out_half.pv.iloc[2]:.4f}")
print(f"h = {h_opt:.2f} (optimal): tau = {out.coef.iloc[2]:.4f}, "
      f"p_rb = {out.pv.iloc[2]:.4f}")
print(f"h = {h_opt*2:.2f} (double):  tau = {out_double.coef.iloc[2]:.4f}, "
      f"p_rb = {out_double.pv.iloc[2]:.4f}")

# --- 6b: Polynomial order sensitivity ---
print("\n--- Polynomial Sensitivity ---")
for p_order in [1, 2, 3]:
    out_p = rdrobust(y, x, c=0, p=p_order)
    print(f"p = {p_order}: tau = {out_p.coef.iloc[2]:.4f}, "
          f"robust p-val = {out_p.pv.iloc[2]:.4f}")

# --- 6c: Kernel sensitivity ---
print("\n--- Kernel Sensitivity ---")
for kern in ["triangular", "epanechnikov", "uniform"]:
    out_k = rdrobust(y, x, c=0, kernel=kern)
    print(f"kernel = {kern:13s}: tau = {out_k.coef.iloc[2]:.4f}, "
          f"p_rb = {out_k.pv.iloc[2]:.4f}")

# --- 6d: CER-optimal bandwidth ---
out_cer = rdrobust(y, x, c=0, bwselect="cerrd")
print(f"\n--- CER-optimal bandwidth ---")
print(f"CER: tau = {out_cer.coef.iloc[2]:.4f}, "
      f"h = {out_cer.bws.iloc[0,0]:.4f}, p_rb = {out_cer.pv.iloc[2]:.4f}")

# ============================================================
# Step 7: Results Interpretation
# ============================================================
print("\n==============================")
print("MAIN RESULTS SUMMARY")
print("==============================")
print(f"Point estimate (conventional):   {out.coef.iloc[0]:.4f}")
print(f"Point estimate (bias-corrected): {out.coef.iloc[1]:.4f}")
print(f"RBC Point estimate: {out.coef.iloc[2]:.4f}")
print(f"Robust SE: {out.se.iloc[2]:.4f}")
print(f"Robust 95% CI: [{out.ci.iloc[2, 0]:.4f}, {out.ci.iloc[2, 1]:.4f}]")
print(f"Robust p-value: {out.pv.iloc[2]:.4f}")
print(f"Bandwidth h (left/right): {out.bws.iloc[0,0]:.4f} / "
      f"{out.bws.iloc[0,1]:.4f}")
print(f"Effective N (left/right): {out.N_h[0]} / {out.N_h[1]}")
print(f"Kernel: {out.kernel}")
print(f"BW selection: {out.bwselect}")
print(f"VCE method: {out.vce}")

# Expected: RBC point estimate approximately 7-8 (positive incumbency effect)
# Expected: Robust 95% CI roughly [4, 11], p-value < 0.05
# Expected: MSE-optimal bandwidth h approximately 16-17
# Expected: Effective N (left/right) approximately 300-400
