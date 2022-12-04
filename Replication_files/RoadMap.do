*Stata 16
*June 2022
*Replication roadmap for Productivity-Enhancing Reallocation during the Great Recession: Evidence from Lithuania
*Jose Garcia-Louzao and Linas Tarasonis

cd //set folder

*Packages need to be installed
ssc install outreg2, replace
ssc install prodest, replace

*Roadmap to get all the results 

do do_firmdata.do 
do do_firmdyn.do 
do do_jcd.do 
do do_dop.do
do do_estimationsample.do 
do do_summary.do
do do_regexit.do 
do do_heterogeneity.do
do do_regemp.do 
do do_regentry.do 
do do_robustness.do