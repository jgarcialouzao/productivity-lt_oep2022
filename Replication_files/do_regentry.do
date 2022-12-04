
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

qui drop if exit==1
qui keep year id year_birth GR tfp industry1 empl foreign private foreignGR privateGR sector1d
qui gen entry = year==year_birth
qui gen tfpGR = tfp*GR
qui gen micro = empl<10
qui gen sme   = empl>=10 & empl<50
qui gen microGR = micro*GR
qui gen smeGR   = sme*GR

label var tfp "TFP"
label var tfpGR "TFP $\times$ GR"

bootstrap, reps(100) seed(13) cluster(id):  reg  entry tfp tfpGR i.year i.industry1
outreg2 using reg_entry.tex , replace keep(tfp tfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label
bootstrap, reps(100) seed(13) cluster(id):  reg  entry tfp tfpGR i.year i.industry1 micro sme private foreign microGR smeGR privateGR foreignGR
outreg2 using reg_entry.tex , append keep(tfp tfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4) nonotes label