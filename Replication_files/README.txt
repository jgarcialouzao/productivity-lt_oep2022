This readme explains the logical sequence to replicate the main results in "Productivity-Enhancing Reallocation during the Great Recession: Evidence from Lithuania" by Jose Garcia-Louzao and Linas Tarasonis

The primary data used in the analysis are confidential and therefore are not provided.
The data are kept at the facilities of the Bank of Lithuania. Researchers can apply for the visit program and obtain access to the dataset (https://www.lb.lt/en/ca-visiting-researcherprogramme).

The full set of results can be obtained running the "RoadMap" program. This program includes the folliwing sub-programs:

do_firmdata extracts data from excel files and transform it in Stata files
do_firmdyn produces Figure 2
do_jcd produces Figure 3 and 4
do_dop produces Figure 5 and Figure A.1
do_estimationsample creates analysis sample to estimate the cleansing effect at the micro-level
do_summary produces Table A.2
do_regexit produces the results in Table 1
do_heterogeneity produces the results in Table 2
do_regemp produces the results in Table 3
do_reg_entry produces the results in Tabble 4
do_robustness produces the regression results in the Online Appendix


Note: Place all Stata files, both do, ado, and additional dta, in the same folder.
