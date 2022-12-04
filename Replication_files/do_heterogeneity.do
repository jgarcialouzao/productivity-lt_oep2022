
********************************************************************************
** HETEROGENEITY ANALYSIS
********************************************************************************

use  estimation_sample.dta, clear 

global controls "micro sme young private foreign exporter importer debt"
global controlsGR "microGR smeGR youngGR privateGR foreignGR exporterGR importerGR debtGR"

qui g prod = Ltfp
qui g prodGR = LtfpGR

label var prod "Productivity"
label var prodGR "Productivity $\times$ GR"

*Financial dependence following Rajan and Zingales (1998) idea
tempfile fin
preserve
qui drop if empl==0
qui drop debt
qui drop if year>2007
sort id year
xtset id year
qui bys id: g gross_Kformation = fa_tang + fa_oth + fa_intang - l.fa_tang - l.fa_oth - l.fa_intang 
qui bys id: egen total_gross_Kformation = mean(gross_Kformation)
qui bys id (year): drop if _n == 1
qui bys id: egen total_pi_oper = mean(pi_oper)
qui gen tmp = 1 - (total_pi_oper/total_gross_Kformation)
qui bys industry1: egen RZ = median(tmp)
qui gen findep = 0 if RZ<=0.1425
qui replace findep = 1 if RZ>0.1425 & RZ<0.5721
qui replace findep = 2 if RZ>=0.5721
qui bys industry1: keep if _n == 1
qui keep industry1 findep
save `fin'
restore 

qui merge m:1 industry1 using `fin'
qui drop   _m

label var Ltfp "TFP"
label var LtfpGR "TFP $\times$ GR"

xtset, clear

bootstrap, reps(100) seed(13) cluster(id):  reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR if findep==0
outreg2 using reg_exit_het.tex , replace keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

bootstrap, reps(100) seed(13) cluster(id):  reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR if findep==1
outreg2 using reg_exit_het.tex , append keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

bootstrap, reps(100) seed(13) cluster(id):  reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR if findep==2
outreg2 using reg_exit_het.tex , append keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label


********************************************************************************
*Manufacturing - construction - services (tradable and non_tradable)
*Tradable vs non-tradable sectors: tradability average share of trade of sales > 10% 
*Define using pre-crisis values to avoid impact of trade collapse of GR, i.e. endogeneity
tempfile tradable
preserve
qui drop if empl==0
qui bys industry1 year: egen total_sales = total(rev_sales)
qui bys industry1 year: egen total_exp= total(EXP)
qui bys industry1 year: egen total_imp= total(IMP)
qui gen tmp = (total_exp + total_imp) / total_sales
qui replace tmp = . if year>2007
qui drop if tmp==.
qui bys industry1 year: keep if _n==1
qui bys industry1: egen mean = mean(tmp)
qui gen tradable = mean>0.10 
qui bys industry1: keep if _n==1
qui keep industry1 tradable
save `tradable'
restore
qui merge m:1 industry1 using `tradable'
qui drop   _m


label var Ltfp "TFP"
label var LtfpGR "TFP $\times$ GR"

bootstrap, reps(100) seed(13) cluster(id):  reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR if sector1d==3
outreg2 using reg_exit_het.tex , append  keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

bootstrap, reps(100) seed(13) cluster(id): reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR if sector1d>3 & tradable==0
outreg2 using reg_exit_het.tex , append keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

bootstrap, reps(100) seed(13) cluster(id):  reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR if sector1d>3 & tradable==1
outreg2 using reg_exit_het.tex , append keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

bootstrap, reps(100) seed(13) cluster(id): reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR if sector1d==2
outreg2 using reg_exit_het.tex , append keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

********************************************************************************
*Herfindhal Index to declare concentrated and non-concentrated sectors, HHI>0.15 concentrated following By Department of Justice/Federal Trade Commission 2010 horizontal merger guidelines, an HHI above 0.15 is considered “moderately concentrated” and an HHI above 0.25 is considered “highly concentrated.”
*we could use hhi5 ado file (ssc install hhi5)
*Use only pre-crisis value to define groups to avoid impact of GR
*Product-market concentration (sales shares)
tempfile  conc_sales
preserve
qui drop if empl==0
qui bys industry1 year: egen total_sales = total(rrev_sales)
qui bys industry1 year: egen s2 = total((rrev_sales/total_sales)^2)
qui replace s2 = . if year>2007
qui drop if s2==.
qui bys industry1 year: keep if _n==1
qui bys industry1: egen mean = mean(s2)
qui gen conc_sales= mean>0.25
qui bys industry1: keep if _n==1
qui keep industry1 conc_sales
save `conc_sales'
restore
qui merge m:1 industry1 using `conc_sales'
qui drop   _m


label var Ltfp "TFP"
label var LtfpGR "TFP $\times$ GR"

bootstrap, reps(100) seed(13) cluster(id):  reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR if conc_sales==0
outreg2 using reg_exit_het.tex , append keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

bootstrap, reps(100) seed(13) cluster(id):  reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR if conc_sales==1
outreg2 using reg_exit_het.tex , append keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label
qui drop conc_sales

*Labor market concentration (employment shares)
tempfile  conc_empl
preserve
qui drop if empl==0
qui bys industry1 year: egen total_empl = total(empl)
qui bys industry1 year: egen s2 = total((empl/total_empl)^2)
qui replace s2 = . if year>2007
qui drop if s2==.
qui bys industry1 year: keep if _n==1
qui bys industry1: egen mean = mean(s2)
qui gen conc_empl= mean>0.25
qui bys industry1: keep if _n==1
qui keep industry1 conc_empl
save `conc_empl'
restore
qui merge m:1 industry1 using `conc_empl'
qui drop   _m

label var Ltfp "TFP"
label var LtfpGR "TFP $\times$ GR"

bootstrap, reps(100) seed(13) cluster(id):  reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR if conc_empl==0
outreg2 using reg_exit_het.tex , append keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label

bootstrap, reps(100) seed(13) cluster(id):  reg  exit Ltfp LtfpGR i.year i.industry1 $controls $controlsGR if conc_empl==1
outreg2 using reg_exit_het.tex , append keep(Ltfp LtfpGR) addtext(Industry FE, Yes, Year FE, Yes) tex(frag) nocons dec(4)  nonotes label
qui drop conc_empl

