*Create 1-digit sector 
gen sector1d=.
replace sector1d=1 if NACE2>=1 & NACE2<=9 | (NACE1_2>=1 & NACE1_2<=14 & year<2000 & NACE2==.)
replace sector1d=2 if NACE2>=10 & NACE2<=39 | ((NACE1_2>=15 & NACE1_2<=21 | NACE1_2>=23 & NACE1_2<=41 | NACE1_2==90) & year<2000 & NACE2==.) 
replace sector1d=3 if NACE2>=41 & NACE2<=43 | (NACE1_2==45  & year<2000 & NACE2==.) 
replace sector1d=4 if NACE2>=45 & NACE2<=47 | (NACE1_2>=50 & NACE1_2<=52  & year<2000 & NACE2==.) 
replace sector1d=5 if NACE2>=49 & NACE2<=53 | (NACE1_2==55  & year<2000 & NACE2==.) 
replace sector1d=6 if NACE2>=55 & NACE2<=56 | (NACE1_2>=60 & NACE1_2<=63  & year<2000 & NACE2==.) 
replace sector1d=7 if NACE2>=58 & NACE2<=63 | ( (NACE1_2==22 | NACE1_2==64)  & year<2000 & NACE2==.) 
replace sector1d=8 if NACE2>=64 & NACE2<=68 | ((NACE1_2>=65 & NACE1_2<=67 | NACE1_2==70)  & year<2000 & NACE2==.) 
replace sector1d=9 if NACE2>=69 & NACE2<=75 | (NACE1_2>=73 & NACE1_2<=74  & year<2000 & NACE2==.) 
replace sector1d=10 if NACE2>=77 & NACE2<=82 | (NACE1_2==71  & year<2000 & NACE2==.) 
replace sector1d=11 if NACE2>=85 & NACE2<=88 | ((NACE1_2==80 | NACE1_2==85)  & year<2000 & NACE2==.) 
replace sector1d=12 if NACE2>=90 & NACE2<=93 | (NACE1_2==92  & year<2000 & NACE2==.) 
replace sector1d=13 if NACE2>=94 & NACE2<=96 | ((NACE1_2 == 72 | NACE1_2==93 | NACE1_2==91)  & year<2000 & NACE2==.) 
replace sector1d=14 if NACE2==84 | (NACE1_2==75  & year<2000 & NACE2==. ) 

*label define sector1dlb  1 "Primary sector" 2 "Manufacturing"  3 "Construction"  4 "Trade" 5 "Transportation and storage" 6 "Accommodation and food services" 7 "Information and communication"  8 "Financial, insurance and real estate activities"  9 "Professional, scientific and technical activities" 10 "Administrative and support services" 11 "Education, human health and social work" 12 "Entertainment" 13 "Other services" 14 "Public admin. and Social Security", modify
label define sector1dlb  1 "Primary sector" 2 "Manufacturing"  3 "Construction"  4 "Trade" 5 "Transportation" 6 "Accomm. and food" 7 "ICT"  8 "Financial serv."  9 "Professional serv." 10 "Admin. serv." 11 "Social serv." 12 "Entertainment" 13 "Other serv." 14 "Public admin.", modify
label values sector1d sector1dlb