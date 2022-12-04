*Stata 16
*June 2020
*Jose Garcia-Louzao
*Read and append firm-level data

clear all
capture log close
capture program drop _all
set more 1
set seed 13
set max_memory 200g
set segmentsize 3g


*time dimension
local miny = 1995
local maxy = 2015


*read csv files and transform to dta files
forvalues y=`miny'(1)`maxy' {
xlsfirms `y'
save firmdata`y'.dta, replace
}


*append years into a single firm-level dataset
forvalues y=`miny'(1)`maxy' {
qui append using firmdata`y'.dta, force
}

*gen NACE1_2 = .
*Homogeneize sector of activity
foreach v in NACE1_2 NACE2 own type legal_birth legal_death legal_death_y  {
qui gen negy = -year
qui bys id (negy): replace `v' = `v'[_n-1] if `v'==. &  `v'[_n-1] != .
qui bys id (year): replace `v' = `v'[_n-1] if `v'==. &  `v'[_n-1] != .
qui drop negy
}
*Create one digit sector of activity
qui bys id: egen mode=mode(NACE2), maxmode
qui replace NACE2 = mode
qui drop mode
qui do ${path1}do_sectorhom
qui bys id: egen mode=mode(sector1d), maxmode
qui replace sector1d = mode
qui drop mode

foreach v in type own legal_birth legal_death legal_death_y {
qui bys id: egen mode=mode(`v'), maxmode
qui replace `v' = mode
drop mode 
}

**Restrictions
*Remove firms with gaps in the time dimension
qui drop if legal_birth==.
qui bys id (year):  gen gap = 1 if year!=year[_n-1]+1 & _n!=1
qui bys id (gap ): replace gap  = gap[1] if gap==.
qui drop if gap == 1
qui drop gap

/*
*Remove firms whose first observation have 250 employees or more
qui gen flag = 1 if year==yofd(legal_birth) & empl>=250 
qui bys id (flag): replace flag=flag[1] if flag==.
qui drop if flag==1
qui drop flag
*/

*Remove primary sector as well as health and education
qui drop if sector1d==1 | sector1d==8 | sector1d==11

*Exclude firms with y-o-y growth rates of sales, employment, assets
*Drop if variable below 1th percentile or above 99th percentile of the industry
qui do ${path3}do_industry
qui egen ind=group(industry)
qui replace ind = 1 if ind==2
qui replace ind = 7 if ind == 6
qui replace ind = 49 if ind==48
qui replace ind = 49 if ind==50
qui egen industry1 = group(ind)
qui drop ind industry


foreach v in rev_sales empl fa_tan purch_mat {
qui bys id (year): gen g`v' = (`v' - `v'[_n-1])/`v'[_n-1] 
}

foreach v in grev_sales gempl gfa_tan gpurch_mat {
qui bys industry1:  egen p1`v'  = pctile(`v') , p(1) 
qui bys industry1:  egen p99`v' = pctile(`v')  , p(99) 
}

qui gen flag = 1 if ( ((grev_sales<p1grev_sales | grev_sales>p99grev_sales) & grev_sales!=.) | ((gempl<p1gempl | gempl>p99gempl) & gempl!=.)   | ((gfa_tan  <p1gfa_tan  | gfa_tan  >p99gfa_tan) & gfa_tan!=.)  | ((gpurch_mat  <p1gpurch_mat  | gpurch_mat  >p99gpurch_mat) & gpurch_mat!=.) ) 
qui bys id (flag): replace flag = flag[1] if flag==.
qui drop if flag==1
qui drop flag  p1* p99* grev_sales gempl gfa_tan gpurch_mat industry1

*Balance the panel and keep observations t_birth and t_death when employment is 0 - important for the computation of job flows
qui xtset id year
qui tsfill, full

*Fill in information for created observations (first and last years), there are some variables that can only be related to operational years (sales, profits, costs) so we do not recover them for entry and exit years
foreach v in empl empl_p hours hours_p a_tot fa_intang fa_tang fa_fin fa_oth ca_inv purch_mat  {
qui replace `v'=0 if `v'==.
}
*Recover rest of variables using longitudinal info
foreach v in NACE2 sector1d own type legal_birth legal_death legal_death_y  {
qui gen negy = -year
qui bys id (negy): replace `v' = `v'[_n-1] if `v'==. &  `v'[_n-1] != .
qui bys id (year): replace `v' = `v'[_n-1] if `v'==. &  `v'[_n-1] != .
qui drop negy
}


*first/last year with positive employment
qui bys id: gegen minyear=min(year) if empl>0
qui bys id (minyear): replace minyear=minyear[1] if minyear==.

qui bys id: gegen maxyear=max(year) if empl>0
qui bys id (maxyear): replace maxyear=maxyear[1] if maxyear==.

drop if year<minyear - 1
drop if year>maxyear + 1

*Birth and death years 
qui gen year_birth = minyear // use first positive employment observed
*refine using information on legal birth
drop if minyear < yofd(legal_birth)
qui replace year_birth = yofd(legal_birth) if yofd(legal_birth)<1995 & minyear==1995 // use only for those whose first observation is in 1995, for the rest we rely on first positive employment
qui bys id (year): drop if _n == 1 & empl==0 & year_birth<year // avoid fake entries

*Exit last year with positive employment except if last year is the last observation year and information available does not say the opposite
qui gen year_death = maxyear
qui replace year_death = . if maxyear==`maxy' 
qui replace year_death = `maxy' if (legal_death_y==`maxy' | yofd(legal_death)==`maxy')
qui drop maxyear minyear

sort id year
qui compress

save firmdata`miny'_`maxy'.dta, replace



forvalues y=`miny'(1)`maxy' {
erase firmdata`y'.dta
