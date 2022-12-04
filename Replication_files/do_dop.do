*Stata 16
*June 2020
*Jose Garcia-Louzao
*Productivity growth decompositions



clear all
capture log close
capture program drop _all
set more 1
set seed 13
set max_memory 200g
set segmentsize 3g
set emptycells drop 


use firmdata1995_2015.dta, clear

qui keep id year* empl VA* a_tot* fa_int* fa_tan* rev_sales purch_mat sector1d NACE2 own

*Firm types to decompose producitivity
*survivors (S), entrants (E), exiters (X) 
*In t only survivors or exiters (when they have positive employment)
qui bys id (year): g S1 = empl>0  & empl[_n+1]>0  // firms that are in t and t-k
qui bys id (year): g X1  = empl>0   & empl[_n+1]==0
*In t+1 only survivors or entrants (when they have positive employment)
qui bys id (year): g S2 = empl>0  & empl[_n-1]>0  // firms that are in t and t+k
qui bys id (year): g E2  = empl>0  & empl[_n-1]==0

*Remove zero employment observations
qui drop if empl == 0
qui drop if year<2000

*Create industry group based on deflator from Eurostat to match data and deflate monetary variables
qui do do_industry
merge m:1 year industry using deflator2015, keepusing(index_va index_conscapital) keep(match)
qui bys year: egen mean=mean(index_va)
qui replace index_va = mean if index_va==.
qui drop mean
qui bys year: egen mean=mean(index_conscapital)
qui replace index_conscapital = mean if index_conscapital==.
qui drop mean _m

foreach v in rev_sales VA purch_mat fa_tan fa_intan {
qui g r`v' = `v' / (index_va/100)
}

qui drop index_*

qui compress
*TOTAL FACTOR PRODUCTIVITY
*LP (2002) estimate total factor productivity: rev sales on capital labor materials 
ssc install prodest, replace

qui g logK = ln(rfa_tan +  1)
qui g logL = ln(empl)
qui g logM = ln(rpurch_mat + 1)
qui g logY = ln(rrev_sales + 1)
qui g tfp = .

qui egen ind=group(industry)
qui replace ind = 1 if ind==2
qui replace ind = 7 if ind == 6
qui replace ind = 49 if ind==48
qui replace ind = 49 if ind==50
qui egen industry1 = group(ind)
qui drop ind
forvalues s=46(-1)1 {
disp in red `s'
qui  prodest logY if industry1==`s', free(logL) proxy(logM) state(logK) method(lp) id(id) t(year) opt(dfp) tol(0.0001) reps(50) 
qui predict tmp if industry1==`s',  residuals
qui replace tfp = tmp if industry1==`s'
qui drop tmp
} 
qui drop log*

qui bys year: egen tfp_mean = mean(tfp) // unweighted average productivity

*Calculate market share in terms of employment
qui bys year : egen total_emp = sum(empl)
qui g emp_share = empl / total_emp 
qui bys year: egen emp_share_mean = mean(emp_share)

*Aggregate TFP productivity
qui bys year: egen total_tfp = sum(tfp)
qui bys year: egen A_tfp = sum(emp_share*tfp)

*Employment share and productivity for each type of firm (survivors, entrants, exiters)
foreach type in S1 S2 E2 X1 {

qui gen emp_`type' = empl if `type'==1
qui bys year: egen total_emp_`type' = sum(emp_`type')
qui gen emp_share_`type' = total_emp_`type' / total_emp
qui gen i_emp_share_`type' = emp_`type'/ total_emp_`type'
qui bys year: egen emp_share_mean_`type' = mean(i_emp_share_`type')

qui g tfp_`type' = tfp if `type'==1
qui bys year: egen tfp_mean_`type' = mean(tfp_`type')

qui bys year: egen A_tfp_`type' = sum(i_emp_share_`type'*tfp_`type')
}

*LABOR PRODUCTIVITY (sales over employment)
qui g labor_p_rev  = log(rrev_sales/empl)
qui bys year: egen labor_p_rev_mean = mean(labor_p_rev) // unweighted average productivity

*Aggregate (real) labor productivity
qui bys year: egen A_labor_p_rev = sum(emp_share*labor_p_rev)

foreach type in S1 S2 E2 X1 {
qui g labor_p_rev_`type' = labor_p_rev if `type'==1
qui bys year: egen labor_p_rev_mean_`type' = mean(labor_p_rev_`type')

qui bys year: egen A_labor_p_rev_`type' = sum(i_emp_share_`type'*labor_p_rev_`type')
}


*DECOMPOSITIONS
foreach v in tfp labor_p_rev {
***Static Olley and Pakes (1996) decomposition
qui gen op_i_`v' = (emp_share - emp_share_mean)*(`v' - `v'_mean)
qui bys year: egen op_cov_`v' = sum(op_i_`v') // between firm covariance

***Dynamic OP - Mellitz and Polanee (2015) decomposition
*Between firm component for survivors
qui gen op_i_`v'_S1 = (i_emp_share_S1 -emp_share_mean_S1)*(`v'_S1 - `v'_mean_S1)*S1
qui bys year: egen op_cov_`v'_S1 = sum(op_i_`v'_S1)

qui gen op_i_`v'_S2 = (i_emp_share_S2 - emp_share_mean_S2)*(`v'_S2 - `v'_mean_S2)*S2
qui bys year: egen op_cov_`v'_S2 = sum(op_i_`v'_S2)
qui drop op_i_`v'_S2
}
qui compress

***Only 1 observation per year for the decomposition
qui bys year: keep if _n == 1 
qui keep year total* A_`v'* emp_share_* *`v'_mean*   op_cov* 

foreach v in tfp labor_p_rev   {
*Average productivity t and t-1
qui g A_`v'_bar = (A_`v' + A_`v'[_n-1])/2 if year==year[_n-1]+1
qui g A_`v'_S_bar = (A_`v'_S2 + A_`v'_S1[_n-1])/2  if year==year[_n-1]+1


*Change in aggregate productivity t and t-1
qui g DA_`v' = 100*(A_`v' - A_`v'[_n-1]) if year==year[_n-1]+1

***Pieces of the OP decomposition
qui g D`v'_mean = 100*(`v'_mean - `v'_mean[_n-1]) if year==year[_n-1]+1
qui g D`v'_op_cov=  100*(op_cov_`v' - op_cov_`v'[_n-1]) if year==year[_n-1]+1


***Pieces of the MP decomposition (dynamic OP)
*a. survivors
qui g DA_`v'_S = 100*(A_`v'_S2 - A_`v'_S1[_n-1])  if year==year[_n-1]+1
qui g D`v'_mean_S = 100*(`v'_mean_S2 - `v'_mean_S1[_n-1]) if year==year[_n-1]+1
qui g D`v'_op_cov_S =  100*(op_cov_`v'_S2 - op_cov_`v'_S1[_n-1]) if year==year[_n-1]+1 

*b. exiters
qui g DA_`v'_X1 = 100*(emp_share_X1[_n-1]*(A_`v'_S1[_n-1] - A_`v'_X1[_n-1])) if year==year[_n-1]+1

*c. entrants
qui g DA_`v'_E2 = 100*(emp_share_E2*(A_`v'_E2 - A_`v'_S2))

qui gen DA_`v'_netentry = DA_`v'_X1 + DA_`v'_E2 
}


qui keep year D*

qui drop if year<2001
qui compress

tw (line DA_tfp year, lpattern(dash) lcolor(black)) (connect Dtfp_mean_S Dtfp_op_cov_S DA_tfp_netentry year, lpattern(solid solid solid) lcolor(black gs8 black) lwidth(thick thick medthick) mcolor(black%40 gs8%30 black) msymbol(O T X)) ,  graphregion(color(white)) bgcolor(white) xtitle("Year") ytitle("Percent", height(5)) legend( cols(4) size(*.75) symxsize(*.5) label(1 "Productivity growth") label(2 "Within") label(3 "Between") label(4 "Net entry") ) ylabel(-40(10)20,nogrid)  xlabel(2001(2)2015) 
qui graph export "${path1}DOP_tfp.pdf", as(pdf) replace

tw (connect DA_tfp_E2  DA_tfp_X1  year, lpattern(solid solid solid) lcolor(black gs8 black) lwidth(thick thick medthick) mcolor(black%40 gs8%30) msymbol(O T X)) ,  graphregion(color(white)) bgcolor(white) xtitle("Year") ytitle("Percent", height(5)) legend( cols(4) size(*.75) symxsize(*.5) label(1 "Entry") label(2 "Exit")) ylabel(,nogrid)  xlabel(2001(2)2015)  ylabel(-6(2)6,nogrid) 
qui graph export "${path1}DOP_tfp_entryexit.pdf", as(pdf) replace


tw (line DA_labor_p_rev year, lpattern(dash) lcolor(black)) (connect Dlabor_p_rev_mean_S Dlabor_p_rev_op_cov_S DA_labor_p_rev_netentry year, lpattern(solid solid solid) lcolor(black gs8 black) lwidth(thick thick medthick) mcolor(black%40 gs8%30 black) msymbol(O T X)) ,  graphregion(color(white)) bgcolor(white) xtitle("Year") ytitle("Percent", height(5)) legend( cols(4) size(*.75) symxsize(*.5) label(1 "Productivity growth") label(2 "Within") label(3 "Between") label(4 "Net entry") ) ylabel(-40(10)20,nogrid)  xlabel(2001(2)2015) 
qui graph export "${path1}DOP_labor_rev.pdf", as(pdf) replace


