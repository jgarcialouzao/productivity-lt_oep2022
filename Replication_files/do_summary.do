*Stata 16
*November 2020
*Linas Tarasonis
*Summary statistics

clear all
capture log close
capture program drop _all
set more 1
set seed 13
set max_memory 200g
set segmentsize 3g

grstyle init
grstyle set plain, nogrid

use estimation_sample.dta, clear

qui gen nobs = 1

* sector dummmies
label list sector1dlb
qui gen Manufacturing = (sector1d == 2)
qui gen Construction  = (sector1d == 3)
qui gen Trade = (sector1d == 4)
qui gen Transportation = (sector1d == 5)
qui gen Services = (sector1d == 9)

* Labor productivity
qui gen lp_sales = (rrev_sales+1)/empl

*X variables (NOT lagged)
*Size
drop micro sme
qui gen micro = empl<10
qui gen sme   = empl>=10 & empl<50

*Exporter and importer status
drop importer exporter
qui g tmp = EXP/rev_sales
qui replace tmp = 0 if EXP==. 
g tmp_exporter = tmp>0
qui bys id (year): g exporter = tmp_exporter
qui drop  tmp*

qui g tmp = IMP/rev_sales
qui replace tmp = 0 if IMP==. 
g tmp_importer = tmp>0
qui bys id (year): g importer = tmp_importer
qui drop  tmp*

*Leverage ratio: using ratio total financial debt over total assets
*Highly indebted firm (potentially in trouble in the face of neg shocks, debt ratio>0.5)
drop debt
qui gen  tmp = (cl_tot +ncl_tot)/a_tot
qui replace tmp =0  if tmp==. & a_tot>=0 & (cl_tot +ncl_tot)==0
g debt = tmp
qui drop tmp 

drop if empl==0

foreach y in 2000 2005 2008 2009 2010 2015 {

preserve

keep if year == `y'

collapse (sum) nobs (mean) tfp lp_sales Manufacturing Construction Trade Transportation Services empl age private foreign exporter importer debt 
g year = `y'

qui tempfile year`y'
qui save `year`y''
 
restore
 
}

use `year2000', replace
foreach y in 2005 2008 2009 2010 2015 {
qui append using `year`y''
}


*Export to excel
mkmat *, matrix(ss)
matrix sst = ss'
matrix list sst

putexcel set tables/summary.xls, modify
putexcel A2 = matrix(sst), rownames  
