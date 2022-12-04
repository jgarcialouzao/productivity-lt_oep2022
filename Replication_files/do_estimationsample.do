*Stata 16
*August 2020
*Jose Garcia-Louzao
*Estimation sample


clear all
capture log close
capture program drop _all
set more 1
set seed 13
set max_memory 200g
set segmentsize 3g

use firmdata1995_2015.dta, clear

*Y variable

*Employment growth 
qui bys id (year): gen empl_lag = empl[_n-1]
qui gen njc = (empl - empl_lag)/((empl + empl_lag)/2)
qui gen jc = njc if njc>0
qui gen jd = abs(njc) if njc<0

*Exit 
qui gen exit = njc==-2


*Only valid observations for productivity analysis
qui drop if year<2000
qui drop if empl==0 & njc!=-2 // first obs was only useful to compute entry
qui compress

*TFP
*Create industry group based on deflator from Eurostat to match data and deflate monetary variables
qui do ${path3}do_industry
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
qui  prodest logY if industry1==`s', free(logL) proxy(logM) state(logK) method(lp) id(id) t(year) opt(dfp) tol(0.0001)  reps(50) 
qui predict tmp if industry1==`s',  residuals
qui replace tfp = tmp if industry1==`s'
qui drop tmp
}

*Lagged TFP, GR dummy, interaction
qui bys id (year): gen Ltfp = tfp[_n-1]
qui gen GR = year==2008 | year==2009 | year==2010
qui gen LtfpGR = Ltfp*GR

*TFP using VA - cannot be as detailed due to lack of observations
qui g tfp_va = .
qui egen sector = group(sector1d)
qui gen logY_va = log(rVA + 1)
forvalues s=1(1)46 {
disp in red `s'
qui  prodest logY_va if industry1==`s', free(logL) proxy(logM) state(logK) method(lp) id(id) t(year) opt(dfp) va tol(0.0001) reps(50)
qui predict tmp if industry1==`s',  residuals
qui replace tfp_va = tmp if industry1==`s'
qui drop tmp
}

qui drop log* sector

qui bys id (year): gen Ltfp_va = tfp_va[_n-1]
qui gen Ltfp_vaGR = Ltfp_va*GR

*X variables (lagged)
*Size
qui gen micro = empl_lag<10
qui gen sme   = empl_lag>=10 & empl_lag<50

*Age
qui gen age = year - year_birth 
qui gen young  = age<5

*Ownership: Public Private Foreing
qui gen private = own == 21 | own==22
qui gen foreign = own==23

*Exporter and importer status
qui g tmp = EXP/rev_sales
qui replace tmp = 0 if EXP==. 
g tmp_exporter = tmp>0
qui bys id (year): g exporter = tmp_exporter[_n-1]
qui drop  tmp*

qui g tmp = IMP/rev_sales
qui replace tmp = 0 if IMP==. 
g tmp_importer = tmp>0
qui bys id (year): g importer = tmp_importer[_n-1]
qui drop  tmp*

*Leverage ratio: using ratio total financial debt over total assets
*Highly indebted firm (potentially in trouble in the face of neg shocks, debt ratio>sectoral median)
qui gen  tmp = (cl_tot +ncl_tot)/a_tot
qui replace tmp =0  if tmp==. & a_tot>=0 & (cl_tot +ncl_tot)==0
*g tmp_debt = tmp>0.5
qui bys id (year): g debt = tmp[_n-1]
qui drop tmp*

*Interactions with GR
foreach v in micro sme young foreign private exporter importer debt  {
qui g `v'GR = `v'*GR
}

qui compress
xtset, clear

save estimation_sample.dta, replace


