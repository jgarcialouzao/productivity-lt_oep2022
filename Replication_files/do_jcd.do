*Stata 16
*June 2020
*Jose Garcia-Louzao
*Job creation and destruction

clear all
capture log close
capture program drop _all
set more 1
set seed 13
set max_memory 200g
set segmentsize 3g

grstyle init

grstyle set plain, nogrid

*NET EMPLOYMENT GROWTH AND JOB REALLOCATION
use firmdata1995_2015.dta, clear

qui xtset id year

* Job Creation and Destruction Measures - Firm level
qui bys id (year): gen empchange = empl - l.empl
qui gen JC =  empchange if empchange>0        // Job Creation
qui gen JD = abs(empchange) if empchange<0   //  Job Destruction	

qui bys id (year): gen DHS = 0.5*( empl + l.empl )            // Davis et al. denominator
qui gen firmJC_rate = JC / DHS 						 	     // Unit-level job creation rate
qui gen firmJD_rate = JD / DHS                        	    //  Unit-level job destruction rate
qui gen firmNET_rate = empchange / DHS		   			  // Unit-level net employment growth

*Total employment
qui bys year : egen totalemp = sum(empl) 
qui bys year: egen nofirms_total=count(id) if empl>0
qui bys id (year): gen DHS_total = 0.5*( totalemp  + l.totalemp)

qui gen sizeweight_total  = DHS / DHS_total

*Economy JCD
qui bys year: egen JC_rate_total = sum(sizeweight_total*firmJC_rate) 		                         // job creation rate
qui bys year: egen JC_rate_entry_total = sum(sizeweight_total*firmJC_rate) if firmJC_rate==2		// job creation rate due to entry
qui bys year: egen JC_rate_exp_total = sum(sizeweight_total*firmJC_rate)   if firmJC_rate!=2	   // job creation rate due to expansion of firms


qui bys year: egen JD_rate_total = sum(sizeweight_total*firmJD_rate)	   				        //  job destruction rate
qui bys year: egen JD_rate_exit_total = sum(sizeweight_total*firmJD_rate) if firmJD_rate==2	   //  job destruction rate due to exit
qui bys year: egen JD_rate_con_total = sum(sizeweight_total*firmJD_rate) if firmJD_rate!=2	  //  job destruction rate due to contraction 

qui bys year: gen netJC_rate_total = JC_rate_total - JD_rate_total         // Net employment growth
qui bys year: gen JR_rate_total = JC_rate_total + JD_rate_total			  // Job reallocation rate
qui gen EJR_rate_total = JR_rate_total - abs(netJC_rate_total)


collapse (firstnm) JC_* JD_* netJC_* JR_* , by(year)

foreach v in JC_rate_total  JC_rate_entry_total  JC_rate_exp_total JD_rate_total  JD_rate_exit_total JD_rate_con_total netJC_rate_total JR_rate_total  {
qui replace `v' = 100*`v'
}


qui drop if year<2001

tw (line netJC_rate_total year, lpattern(dash) lcolor(black)) (connect JC_rate_total JD_rate_total year, lpattern(solid solid) lcolor(black gs8) lwidth(thick thick) mcolor(black%40 gs8%30) msymbol(O T)) ,  graphregion(color(white)) bgcolor(white) xtitle("Year") ytitle("Percent", height(5)) legend( cols(3) size(*.9) symxsize(*.5) label(1 "Employment growth") label(2 "Job creation") label(3 "Job destruction") ) ylabel(-10(5)20,nogrid) xlabel(2001(2)2015) //xlabel(2000 "2000" 2005 "2005" 2010 "2010" 2015 "2015")
qui graph export "${path1}JCD.pdf", as(pdf) replace

qui gen netJC_rate_surviving = (JC_rate_exp_total - JD_rate_con_total)
qui gen netJC_rate_netentry  = (JC_rate_entry_total - JD_rate_exit_total)


tw (line netJC_rate_total year, lpattern(dash) lcolor(black)) (connect netJC_rate_surviving netJC_rate_netentry year, lpattern(solid solid) lcolor(black gs8) lwidth(thick thick) mcolor(black%40 gs8%30) msymbol(O T)) ,  graphregion(color(white)) bgcolor(white) xtitle("Year") ytitle("Percent", height(5)) legend( cols(3) size(*.9) symxsize(*.5) label(1 "Employment growth") label(2 "Survivors") label(3 "Net entry") ) ylabel(-12(2)10,nogrid) xlabel(2001(2)2015) //xlabel(1996 "1996" 2000 "2000" 2005 "2005" 2010 "2010" 2015 "2015")
qui graph export "${path1}JCD_1.pdf", as(pdf) replace


tw (line JC_rate_total year, lpattern(dash) lcolor(black)) (connect JC_rate_exp_total  JC_rate_entry_total  year, lpattern(solid solid) lcolor(black gs8) lwidth(thick thick) mcolor(black%40 gs8%30) msymbol(O T)) ,  graphregion(color(white)) bgcolor(white) xtitle("Year") ytitle("Percent", height(5)) legend( cols(3) size(*.9) symxsize(*.5) label(1 "Job creation") label(2 "Survivors") label(3 "Entrants") ) ylabel(0(5)20,nogrid) xlabel(2001(2)2015) //xlabel(1996 "1996" 2000 "2000" 2005 "2005" 2010 "2010" 2015 "2015")
qui graph export "${path1}JC.pdf", as(pdf) replace


tw (line JD_rate_total year, lpattern(dash) lcolor(black)) (connect JD_rate_con_total JD_rate_exit_total  year, lpattern(solid solid) lcolor(black gs8) lwidth(thick thick) mcolor(black%40 gs8%30) msymbol(O T)) ,  graphregion(color(white)) bgcolor(white) xtitle("Year") ytitle("Percent", height(5)) legend( cols(3) size(*.9) symxsize(*.5) label(1 "Job destruction") label(2 "Survivors") label(3 "Exiters") ) ylabel(0(5)20,nogrid) xlabel(2001(2)2015) //xlabel(1996 "1996" 2000 "2000" 2005 "2005" 2010 "2010" 2015 "2015")
qui graph export "${path1}JD.pdf", as(pdf) replace



