*Stata 16
*June 2020
*Jose Garcia-Louzao
*Firm dynamics

clear all
capture log close
capture program drop _all
set more 1
set seed 13
set max_memory 200g
set segmentsize 3g

grstyle init

grstyle set plain, nogrid


*1. FIRM DYNAMICS: Growth, Entry and Exit
use firmdata1995_2015.dta, clear

qui g firm_entry = 1 if year>=year_birth & year_birth>year-1 & year_death>=year

qui g firm = 1 if empl>0

collapse (sum) firm firm_entry  , by(year)

sort year
qui g firm_exit = abs((firm[_n-1] + firm_entry) - firm)

sort year
qui g gfirm = 100*(firm - firm[_n-1])/((firm + firm[_n-1])/2)
qui g entry = 100*firm_entry/((firm + firm[_n-1])/2)
sort year
qui g exit  = 100*firm_exit/((firm + firm[_n-1])/2)

qui drop if year<2001

tw (line gfirm year, lpattern(dash) lcolor(black)) (connect entry exit year, lpattern(solid solid) lcolor(black gs8) lwidth(thick thick) mcolor(black%40 gs8%30) msymbol(O T)) ,  graphregion(color(white)) bgcolor(white) xtitle("Year") ytitle("Percent", height(5)) legend( cols(3) size(*.9) symxsize(*.5) label(1 "Firm growth") label(2 "Entry") label(3 "Exit") ) ylabel(0(5)20,nogrid) xlabel(2001(2)2015) //xlabel(1996 "1996" 2000 "2000" 2005 "2005" 2010 "2010" 2015 "2015")
qui graph export "firmdynamics.pdf", as(pdf) replace




