*Stata 16
*August 2020
*Jose Garcia-Louzao
*Firm exit models

clear all
capture log close
capture program drop _all
set more 1
set seed 13
set max_memory 200g
set segmentsize 3g

use  estimation_sample.dta, clear 

global controls "micro sme young private foreign exporter importer debt"
global controlsGR "microGR smeGR youngGR privateGR foreignGR exporterGR importerGR debtGR"


label var Ltfp "TFP"
label var LtfpGR "TFP $\times$ GR"

*We exclude exit as we already show it in the previous section, now employment growth
**Net job creation 
bootstrap, reps(100) seed(13) cluster(id):  reg njc Ltfp LtfpGR i.year i.industry1 $controls $controlsGR if year_death==.
outreg2 using reg_njc.tex , replace  keep(Ltfp LtfpGR ) ctitle(All Firms) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label  

*job creation vs job destruction excluding exit
bootstrap, reps(100) seed(13) cluster(id): reg  jc Ltfp LtfpGR i.year i.industry1 $controls $controlsGR if year_death==.
outreg2 using reg_njc.tex , append keep(Ltfp LtfpGR) ctitle(Job-creating) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

bootstrap, reps(100) seed(13) cluster(id):  reg  jd Ltfp LtfpGR i.year i.industry1 $controls $controlsGR if year_death==.
outreg2 using reg_njc.tex , append keep(Ltfp LtfpGR) ctitle(Job-destroying) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label


*WITH FIXED EFFECTS
**Net job creation 
xtset id year
xtreg  njc Ltfp LtfpGR i.year $controls $controlsGR if year_death==., fe vce(bootstrap, reps(100) seed(13)) cluster(id)
outreg2 using reg_njc.tex , append  keep(Ltfp LtfpGR ) ctitle(All firms) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

*job creation vs job destruction excluding exit
xtreg  jc Ltfp LtfpGR i.year  $controls $controlsGR if year_death==., fe vce(bootstrap, reps(100) seed(13)) cluster(id)
outreg2 using reg_njc.tex , append keep(Ltfp LtfpGR) ctitle(Job-creating) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

xtreg jd Ltfp LtfpGR i.year $controls $controlsGR if year_death==., fe vce(bootstrap, reps(100) seed(13)) cluster(id)
outreg2 using reg_njc.tex , append keep(Ltfp LtfpGR) ctitle(Job-destroying) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label


