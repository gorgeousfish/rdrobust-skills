* rdrobust — Basic Sharp RD Example (Stata)
* Data: U.S. Senate Elections (rdrobust_senate.dta)
* Running variable: vote margin (margin), Cutoff: 0
* Outcome: vote share in next election (vote)
* Reference: Calonico, Cattaneo, and Titiunik (2014, Econometrica)

* ============================================================
* Step 1: Installation and Setup
* ============================================================
* ssc install rdrobust, replace
* net install rdrobust, from(https://raw.githubusercontent.com/rdpackages/rdrobust/master/stata) replace

* ============================================================
* Step 2: Load Data
* ============================================================
use rdrobust_senate.dta, clear

summarize vote margin
display "Sample size: " _N
count if margin < 0
display "Observations left of cutoff: " r(N)
count if margin >= 0
display "Observations right of cutoff: " r(N)

* ============================================================
* Step 3: RD Plot (Visualization)
* ============================================================
rdplot vote margin, c(0) binselect(esmv) ///
    graph_options(title("RD Plot: U.S. Senate Elections") ///
                  xtitle("Vote Margin (Running Variable)") ///
                  ytitle("Vote Share Next Election"))

* ============================================================
* Step 4: Data-Driven Bandwidth Selection
* ============================================================
rdbwselect vote margin, c(0)

* All methods
rdbwselect vote margin, c(0) all

* ============================================================
* Step 5: Main Estimation (Sharp RD, MSE-Optimal Bandwidth)
* ============================================================
rdrobust vote margin, c(0)

* Display stored results
ereturn list

* ============================================================
* Step 6: Robustness Checks
* ============================================================

* --- 6a: Bandwidth sensitivity ---
quietly rdrobust vote margin, c(0)
local h_opt = e(h_l)

local h_half = `h_opt' / 2
local h_double = `h_opt' * 2

display _newline "--- Bandwidth Sensitivity ---"

quietly rdrobust vote margin, c(0) h(`h_half')
display "h = " %6.2f `h_half' " (half):   tau = " %7.4f e(tau_cl) ///
        " , p_rb = " %6.4f e(pv_rb)

quietly rdrobust vote margin, c(0) h(`h_opt')
display "h = " %6.2f `h_opt' " (optimal): tau = " %7.4f e(tau_cl) ///
        " , p_rb = " %6.4f e(pv_rb)

quietly rdrobust vote margin, c(0) h(`h_double')
display "h = " %6.2f `h_double' " (double):  tau = " %7.4f e(tau_cl) ///
        " , p_rb = " %6.4f e(pv_rb)

* --- 6b: Polynomial order sensitivity ---
display _newline "--- Polynomial Sensitivity ---"
forvalues p = 1/3 {
    quietly rdrobust vote margin, c(0) p(`p')
    display "p = `p': tau = " %7.4f e(tau_cl) " , p_rb = " %6.4f e(pv_rb)
}

* --- 6c: Kernel sensitivity ---
display _newline "--- Kernel Sensitivity ---"
foreach kern in triangular epanechnikov uniform {
    quietly rdrobust vote margin, c(0) kernel(`kern')
    display "kernel = " %-13s "`kern'" ": tau = " %7.4f e(tau_cl) ///
            " , p_rb = " %6.4f e(pv_rb)
}

* --- 6d: CER-optimal bandwidth ---
display _newline "--- CER-optimal bandwidth ---"
quietly rdrobust vote margin, c(0) bwselect(cerrd)
display "CER: tau = " %7.4f e(tau_cl) " , h = " %7.4f e(h_l) ///
        " , p_rb = " %6.4f e(pv_rb)

* ============================================================
* Step 7: Results Interpretation
* ============================================================
quietly rdrobust vote margin, c(0)

display _newline "=============================="
display "MAIN RESULTS SUMMARY"
display "=============================="
display "Point estimate (conventional):   " %7.4f e(tau_cl)
display "Point estimate (bias-corrected): " %7.4f e(tau_bc)
display "Robust 95% CI: [" %7.4f e(ci_l_rb) " , " %7.4f e(ci_r_rb) "]"
display "Robust p-value: " %6.4f e(pv_rb)
display "Bandwidth h (left/right): " %7.4f e(h_l) " / " %7.4f e(h_r)
display "Effective N (left/right): " e(N_h_l) " / " e(N_h_r)
display "Kernel: " e(kernel)
display "BW selection: " e(bwselect)

* Expected: RBC point estimate approximately 7-8 (positive incumbency effect)
* Expected: Robust 95% CI roughly [4, 11], p-value < 0.05
* Expected: MSE-optimal bandwidth h approximately 16-17
* Expected: Effective N (left/right) approximately 300-400
