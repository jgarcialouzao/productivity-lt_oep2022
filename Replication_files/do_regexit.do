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

use estimation_sample.dta, clear 

global controls "micro sme young private foreign exporter importer debt"
global controlsGR "microGR smeGR youngGR privateGR foreignGR exporterGR importerGR debtGR"

qui g prod = Ltfp
qui g prodGR = LtfpGR

label var prod "Productivity"
label var prodGR "Productivity $\times$ GR"

bootstrap, reps(100) seed(13) cluster(id): reg  exit prod prodGR i.year i.industry1 $controls $controlsGR
outreg2 using reg_exit.tex , replace keep(prod prodGR) ctitle(TFP) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

*Labor productivity
qui gen lp_sales = log((rrev_sales+1)/empl)
qui bys id (year): gen Llp_sales = lp_sales[_n-1]
qui gen Llp_salesGR = Llp_sales*GR

qui drop prod*
qui gen prod = Llp_sales
qui gen prodGR = Llp_salesGR

bootstrap, reps(100) seed(13) cluster(id): reg  exit prod prodGR i.year i.industry1 $controls $controlsGR
outreg2 using reg_exit.tex , append keep(prod prodGR) ctitle(Sales per worker) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

qui gen lp_sales_hours = log((rrev_sales+1)/hours)
qui bys id (year): gen Llp_sales_hours = lp_sales_hours[_n-1]
qui gen Llp_sales_hoursGR = Llp_sales_hours*GR

qui drop prod*
qui g prod = Llp_sales_hours
qui g prodGR = Llp_sales_hoursGR

bootstrap, reps(100) seed(13) cluster(id):  reg  exit prod prodGR  i.year i.industry1 $controls $controlsGR
outreg2 using reg_exit.tex, append keep(prod prodGR) ctitle(Sales per hour) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label
qui drop  *Llp_sales*



