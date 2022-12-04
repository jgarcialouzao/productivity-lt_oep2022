

********************************************************************************
** ROBUSTNESS
********************************************************************************

use  estimation_sample.dta, clear 

global controls "micro sme young private foreign exporter importer debt"
global controlsGR "microGR smeGR youngGR privateGR foreignGR exporterGR importerGR debtGR"

qui g prod = Ltfp
qui g prodGR = LtfpGR

label var prod "Productivity"
label var prodGR "Productivity $\times$ GR"

**(1) Using value-added instead of sales
qui gen lp_va = log((rVA+1)/empl)
qui bys id (year): gen Llp_va = lp_va[_n-1]
qui gen Llp_vaGR = Llp_va*GR

qui gen lp_va_hours = log((rVA+1)/hours)
qui bys id (year): gen Llp_va_hours = lp_va_hours[_n-1]
qui gen Llp_va_hoursGR = Llp_va_hours*GR
qui drop lp_*

set more 1
qui drop prod*
qui g prod = Ltfp_va
qui g prodGR = Ltfp_vaGR

label var prod "Productivity"
label var prodGR "Productivity $\times$ GR"

bootstrap, reps(100) seed(13) cluster(id): reg  exit prod prodGR i.year i.industry1 $controls $controlsGR
outreg2 using reg_exit_VA.tex , replace keep(prod prodGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

qui drop prod*
qui g prod = Llp_va
qui g prodGR = Llp_vaGR

label var prod "Productivity"
label var prodGR "Productivity $\times$ GR"

bootstrap, reps(100) seed(13) cluster(id):  reg  exit prod prodGR i.year i.industry1 $controls $controlsGR
outreg2 using reg_exit_VA.tex , append keep(prod prodGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

qui drop prod*
qui g prod = Llp_va_hours
qui g prodGR = Llp_va_hoursGR

label var prod "Productivity"
label var prodGR "Productivity $\times$ GR"

bootstrap, reps(100) seed(13) cluster(id):  reg  exit prod prodGR  i.year i.industry1 $controls $controlsGR
outreg2 using reg_exit_VA.tex , append keep(prod prodGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label
qui drop *Llp_va*


**(2) Firm exit sensitivity time effects
preserve
qui drop *GR
qui gen GR = year>=2008 & year<=2012
foreach v in Ltfp micro sme young private foreign exporter importer debt {
qui gen `v'GR= `v'*GR
}

label var Ltfp "TFP"
label var LtfpGR "TFP $\times$ GR"

bootstrap, reps(100) seed(13) cluster(id):  reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR
outreg2 using reg_timesens.tex , replace ctitle(GR:08-12)  keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes, Industry-Year FE, No)tex(frag) nocons dec(4)  nonotes label
restore

qui gen REC = year>2010
foreach v in Ltfp micro sme young private foreign exporter debt {
qui gen `v'REC= `v'*REC
}

label var Ltfp "TFP"
label var LtfpGR "TFP $\times$ GR"
label var LtfpREC "TFP $\times$ Recovery"

bootstrap, reps(100) seed(13) cluster(id):  reg  exit Ltfp LtfpGR LtfpREC i.industry1 $controls $controlsGR *REC 
outreg2 using reg_timesens.tex , append ctitle(GR \& REC) keep(Ltfp LtfpGR LtfpREC)  addtext(Industry FE, Yes, Year FE, Yes, Industry-Year FE, No) tex(frag) nocons dec(4)  nonotes label
drop *REC

qui gen indy = industry1*year
bootstrap, reps(100) seed(13) cluster(id):  reg  exit Ltfp LtfpGR i.indy $controls $controlsGR
drop indy
outreg2 using reg_timesens.tex , append ctitle(Industry $\times$ Year) keep(Ltfp LtfpGR) addtext(Industry FE, No, Year FE, No, Industry-Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

preserve
drop Ltfp*
qui bys id: egen Ltfp = mean(tfp)
qui gen LtfpGR = Ltfp*GR

label var Ltfp "TFP"
label var LtfpGR "TFP $\times$ GR"

bootstrap, reps(100) seed(13) cluster(id):  reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR  
outreg2 using $reg_tfpmeasure.tex , replace ctitle(Avg. TFP) keep(Ltfp LtfpGR)  addtext(Industry FE, Yes, Year FE, Yes, Industry-Year FE, No) tex(frag) nocons dec(4)  nonotes label
restore

preserve
drop Ltfp*
qui bys id: egen Ltfp = mean(tfp) if year<=2008 & year_birth<2008
bys id (Ltfp): replace Ltfp=Ltfp[1] if Ltfp==.
qui gen LtfpGR = Ltfp*GR

label var Ltfp "TFP"
label var LtfpGR "TFP $\times$ GR"

bootstrap, reps(100) seed(13) cluster(id):  reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR  
outreg2 using reg_tfpmeasure.tex , append ctitle(Pre-GR Avg. TFP) keep(Ltfp LtfpGR)  addtext(Industry FE, Yes, Year FE, Yes, Industry-Year FE, No) tex(frag) nocons dec(4)  nonotes label
restore

preserve
drop Ltfp*
qui bys id (year): gen Ltfp = tfp[_n-2]
qui gen LtfpGR = Ltfp*GR

label var Ltfp "TFP"
label var LtfpGR "TFP $\times$ GR"

bootstrap, reps(100) seed(13) cluster(id):  reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR  
outreg2 using reg_tfpmeasure.tex , append ctitle(TFP-2yr) keep(Ltfp LtfpGR)  addtext(Industry FE, Yes, Year FE, Yes, Industry-Year FE, No) tex(frag) nocons dec(4)  nonotes label
restore

preserve
drop Ltfp*
qui bys id (year): gen Ltfp = tfp[_n-3]
qui gen LtfpGR = Ltfp*GR

label var Ltfp "TFP"
label var LtfpGR "TFP $\times$ GR"

bootstrap, reps(100) seed(13) cluster(id):  reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR  
outreg2 using reg_tfpmeasure.tex , append ctitle(TFP-3yr) keep(Ltfp LtfpGR)  addtext(Industry FE, Yes, Year FE, Yes, Industry-Year FE, No) tex(frag) nocons dec(4)  nonotes label
restore
*/
**(3)Firm exit discrete time duration model
preserve
label var Ltfp "TFP"
label var LtfpGR "TFP $\times$ GR"
replace age=20 if age>=20
bootstrap, reps(100) seed(13) cluster(id):  logit exit Ltfp LtfpGR i.year i.industry1 i.age GR micro sme private foreign exporter importer debt microGR smeGR privateGR foreignGR exporterGR importerGR debtGR, tol(0.00001)
outreg2 using reg_exit_modelsens.tex , replace keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label
xtset id year
qui drop if year_birth<2000
xtlogit exit Ltfp LtfpGR i.year i.industry1 i.age micro sme private foreign exporter importer debt microGR smeGR privateGR foreignGR exporterGR importerGR debtGR, re tol(0.00001)
outreg2 using reg_exit_modelsens.tex , append keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label
restore


*Using only 2005-2015
use  estimation_sample.dta, clear 

global controls "micro sme young private foreign exporter importer debt"
global controlsGR "microGR smeGR youngGR privateGR foreignGR exporterGR importerGR debtGR"

label var Ltfp "TFP"
label var LtfpGR "TFP $\times$ GR"

keep if year>=2005
bootstrap, reps(100) seed(13) cluster(id): reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR
outreg2 using reg_all_20052015.tex , replace keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

bootstrap, reps(100) seed(13) cluster(id):  reg njc Ltfp LtfpGR i.year i.industry1 $controls $controlsGR if year_death==.
outreg2 using reg_all_20052015.tex , append keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label


use  estimation_sample.dta, clear 

qui drop if exit==1
qui keep year id year_birth GR tfp industry1 empl foreign private foreignGR privateGR sector1d
qui gen entry = year==year_birth
qui gen tfpGR = tfp*GR
qui gen micro = empl<10
qui gen sme   = empl>=10 & empl<50
qui gen microGR = micro*GR
qui gen smeGR   = sme*GR

rename tfp Ltfp
rename tfpGR LtfpGR
label var Ltfp "TFP"
label var LtfpGR "TFP $\times$ GR"
keep if year>=2005
bootstrap, reps(100) seed(13) cluster(id):  reg  entry Ltfp LtfpGR i.year i.industry1 micro sme private foreign microGR smeGR privateGR foreignGR
outreg2 using reg_all_20052015.tex , append keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label


**Excluding anomalous sectors
use  ${path0}estimation_sample.dta, clear 

global controls "micro sme young private foreign exporter importer debt"
global controlsGR "microGR smeGR youngGR privateGR foreignGR exporterGR importerGR debtGR"

label var Ltfp "TFP"
label var LtfpGR "TFP $\times$ GR"

drop if sector1d==4 | sector1d==6 | sector1d==7 | sector1d>=12
bootstrap, reps(100) seed(13) cluster(id): reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR
outreg2 using reg_all_exclsectors.tex , replace keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

bootstrap, reps(100) seed(13) cluster(id):  reg njc Ltfp LtfpGR i.year i.industry1 $controls $controlsGR if year_death==.
outreg2 using reg_all_exclsectors.tex , append keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label


use  estimation_sample.dta, clear 

qui drop if exit==1
qui keep year id year_birth GR tfp industry1 empl foreign private foreignGR privateGR sector1d
qui gen entry = year==year_birth
qui gen tfpGR = tfp*GR
qui gen micro = empl<10
qui gen sme   = empl>=10 & empl<50
qui gen microGR = micro*GR
qui gen smeGR   = sme*GR

rename tfp Ltfp
rename tfpGR LtfpGR
label var Ltfp "TFP"
label var LtfpGR "TFP $\times$ GR"
drop if sector1d==4 | sector1d==6 | sector1d==7 | sector1d>=12
bootstrap, reps(100) seed(13) cluster(id):  reg  entry Ltfp LtfpGR i.year i.industry1 micro sme private foreign microGR smeGR privateGR foreignGR
outreg2 using reg_all_exclsectors.tex , append keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label