clear
set more off
pause on

use data_filtered


**************************************************************************************
* De-mean the (filtered) data to make sure they have mean exactly zero:
**************************************************************************************

foreach VAR of varlist *_hp *_bp *_4d {
	qui su `VAR'
	qui replace `VAR' = `VAR' - r(mean)
}


**************************************************************************************
* Loop over variables of interest, filter and sample period:
**************************************************************************************

* Generate regressors and variables to store results:

gen PRE = (year<=1984)
gen POST = (year>1984)

set obs 500
gen str8 bcstats_var = ""
gen str8 bcstats_period = ""
gen str8 bcstats_filter = ""
foreach STAT in "sd" "relsd" "corr" {
	foreach SUFFIX in "pre" "post" "diff" {
		gen str6 bcstats_`STAT'_output_`SUFFIX' = ""
	}
	foreach SUFFIX in "pre" "post" "diff" {
		gen str6 bcstats_`STAT'_empl_`SUFFIX' = ""
	}
	foreach SUFFIX in "pre" "post" "diff" {
		gen str6 bcstats_`STAT'_hours_`SUFFIX' = ""
	}
}
local LINENO = 1 /* First row for storing results */

* Loops:

foreach VARIAB in "output" "opp" "oph" "empl" "hours" {

foreach BEGINYEAR of numlist 1948 1965 1975 1980 {
local ENDYEAR = 2*1984 + 1 - `BEGINYEAR'
if `ENDYEAR'>2015 local ENDYEAR = 2015
if `ENDYEAR' <= 1990 local ENDYEAR = 1990

foreach FILTER in "bp" "hp" "4d" {

foreach REF_VAR in "output" "empl" "hours" {

local VARIABLE = "`VARIAB'_`FILTER'"
local REFVARIABLE = "`REF_VAR'_`FILTER'"

**************************************************************************************
* Estimate the second moments and their var-covar matrix:
**************************************************************************************

quietly {

gen VAR = `VARIABLE'*`VARIABLE'
gen REFVAR = `REFVARIABLE'*`REFVARIABLE'
gen COV = `VARIABLE'*`REFVARIABLE'

*sureg (VAR PRE POST, nocons) (REFVAR PRE POST, nocons) (COV PRE POST, nocons)  /* Does not allow for robust option, use suest instead */

*mysureg (VAR POST) (REFVAR POST) (COV POST), robust  /* This works (although mysureg is much slower and does not allow for nonconstant option, which is a bit of a hassle) */
*mysureg (VAR POST) (REFVAR POST) (COV POST)
*sureg (VAR POST) (REFVAR POST) (COV POST)

*regress VAR PRE POST, nocons vce(robust)
*newey VAR PRE POST, nocons lag(1)  /* Of course this would be more correct. If there is no autocorrelation, then there is also no correlation in the pre and post estimators */

reg VAR PRE POST, nocons, if year >= `BEGINYEAR' & year <= `ENDYEAR'
estimates store VAR
reg REFVAR PRE POST, nocons, if year >= `BEGINYEAR' & year <= `ENDYEAR'
estimates store REFVAR
reg COV PRE POST, nocons, if year >= `BEGINYEAR' & year <= `ENDYEAR'
estimates store COV

suest VAR REFVAR COV, vce(robust)

drop _est*
drop VAR REFVAR COV

} /* end quietly */


**************************************************************************************
* Calculate BC moments of interest using delta-method:
**************************************************************************************

quietly {

* Standard deviation (test against 0):
local est_sd_pre = sqrt([VAR_mean]PRE)
qui testnl sqrt([VAR_mean]PRE) = 0
local se_sd_pre = abs( `est_sd_pre' - 0 ) / sqrt(r(chi2))
local est_sd_post = sqrt([VAR_mean]POST)
qui testnl sqrt([VAR_mean]POST) = 0
local se_sd_post = abs( `est_sd_post' - 0 ) / sqrt(r(chi2))

* Standard deviation (test ratio):
local est_sd_diff = sqrt([VAR_mean]POST) / sqrt([VAR_mean]PRE)
qui testnl sqrt([VAR_mean]POST) / sqrt([VAR_mean]PRE) = 1
local se_sd_diff = abs( `est_sd_diff' - 1 ) / sqrt(r(chi2))

* Relative standard deviation (test against 1):
local est_relsd_pre = sqrt([VAR_mean]PRE) / sqrt([REFVAR_mean]PRE)
testnl sqrt([VAR_mean]PRE) / sqrt([REFVAR_mean]PRE) = 1
local se_relsd_pre = abs( `est_relsd_pre' - 1 ) / sqrt(r(chi2))
local est_relsd_post = sqrt([VAR_mean]POST) / sqrt([REFVAR_mean]POST)
testnl sqrt([VAR_mean]POST) / sqrt([REFVAR_mean]POST) = 1
local se_relsd_post = abs( `est_relsd_post' - 1 ) / sqrt(r(chi2))

* Relative standard deviation (test ratio):
local est_relsd_diff = ( sqrt([VAR_mean]POST) / sqrt([REFVAR_mean]POST) ) / ( sqrt([VAR_mean]PRE) / sqrt([REFVAR_mean]PRE) )
testnl ( sqrt([VAR_mean]POST) / sqrt([REFVAR_mean]POST) ) / ( sqrt([VAR_mean]PRE) / sqrt([REFVAR_mean]PRE) ) = 1
local se_relsd_diff = abs( `est_relsd_diff' - 1 ) / sqrt(r(chi2))

* Correlation coefficient (test against 0):
local est_corr_pre = [COV_mean]PRE / ( sqrt([VAR_mean]PRE) * sqrt([REFVAR_mean]PRE) )
testnl [COV_mean]PRE / ( sqrt([VAR_mean]PRE) * sqrt([REFVAR_mean]PRE) ) = 0
local se_corr_pre = abs( `est_corr_pre' - 0 ) / sqrt(r(chi2))
local est_corr_post = [COV_mean]POST / ( sqrt([VAR_mean]POST) * sqrt([REFVAR_mean]POST) )
testnl [COV_mean]POST / ( sqrt([VAR_mean]POST) * sqrt([REFVAR_mean]POST) ) = 0
local se_corr_post = abs( `est_corr_post' - 0 ) / sqrt(r(chi2))

* Correlation coefficient (test difference):
local est_corr_diff = ( [COV_mean]POST / ( sqrt([VAR_mean]POST) * sqrt([REFVAR_mean]POST) ) ) - ( [COV_mean]PRE / ( sqrt([VAR_mean]PRE) * sqrt([REFVAR_mean]PRE) ) )
testnl ( [COV_mean]POST / ( sqrt([VAR_mean]POST) * sqrt([REFVAR_mean]POST) ) ) - ( [COV_mean]PRE / ( sqrt([VAR_mean]PRE) * sqrt([REFVAR_mean]PRE) ) ) = 0
local se_corr_diff = abs( `est_corr_diff' - 0 ) / sqrt(r(chi2))

} /* end quietly */


**************************************************************************************
* Store results:
**************************************************************************************

foreach STAT in "sd" "relsd" "corr" {
foreach SUFFIX in "pre" "post" "diff" {
	qui su year if `VARIABLE' ~= . & year >= `BEGINYEAR' & year <= `ENDYEAR'
	if r(min) == `BEGINYEAR' & r(max) == `ENDYEAR' {
		qui replace bcstats_`STAT'_`REF_VAR'_`SUFFIX' =  string(round(`est_`STAT'_`SUFFIX'',.01),"%9.2f") in `LINENO'
		local LINENOPLUS1 = `LINENO' + 1
		qui replace bcstats_`STAT'_`REF_VAR'_`SUFFIX' = "[" + string(round(`se_`STAT'_`SUFFIX'',.01),"%9.2f") + "]" in `LINENOPLUS1'
	}
}
}

} /* end loop over REF_VAR */

qui replace bcstats_var = "`VARIAB'" in `LINENO'
qui replace bcstats_period = "`BEGINYEAR' - `ENDYEAR'" in `LINENO'
qui replace bcstats_filter = upper("`FILTER'") in `LINENO'
local LINENO = `LINENO' + 2

} /* end loop over FILTER */
} /* end loop over BEGINYEAR */

disp _n"Variable: `VARIAB'"

} /* end loop over VARIAB */

outsheet bcstats_* using results_table.csv, comma replace

