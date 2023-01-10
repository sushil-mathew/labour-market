*-------------------------------------------------------------------------------
* SECTION 1
*-------------------------------------------------------------------------------
* CLEAN PAYE DATA TO CHECK IF NUMBER OF WORKERS AGGREGATES WELL TO ASHE DATA
*-------------------------------------------------------------------------------

import excel using "$rawpayedata/july14-nov22", sheet("28. Employees (Age)") clear
drop in 1/5
rename A date 
rename B noworkers0
rename C noworkers18
rename D noworkers25
rename E noworkers35
rename F noworkers50
rename G noworkers65
rename H noworkerstot
drop in 1
gen year = substr(date, -4, 4)

destring year noworkers*, replace
gen month = substr(date, 1, length(date)-5)
drop date

gen lnworkers = ln(noworkerstot)
bys year: su lnworkers //we see that employment within a year decreases by 2% max even during 2020 and 2021

reshape long noworkers, i(year month) j(agegroup)

*ashe age groups 18-21, 22-29, 30-39, 40-49, 50-59, 60+
tab agegroup
drop if agegroup == 0
replace agegroup = 18 if agegroup < 50 
replace agegroup = 50 if agegroup >= 50
tab agegroup
collapse (rawsum) noworkers, by(year month agegroup)
collapse (mean) noworkers, by(year agegroup)

tempfile workers
save `workers'

*-------------------------------------------------------------------------------
* SECTION 2
*-------------------------------------------------------------------------------
* CLEAN PAYE DATA TO CHECK IF MEAN AND MEDIAN WAGES ARE SAME IN BOTH DATASETS
*-------------------------------------------------------------------------------

* MEDIAN
import excel using "$rawpayedata/july14-nov22", sheet("29. Median pay (Age)") clear
drop in 1/5
rename A date 
rename B medianmonthlywage0
rename C medianmonthlywage18
rename D medianmonthlywage25
rename E medianmonthlywage35
rename F medianmonthlywage50
rename G medianmonthlywage65
rename H medianmonthlywagetot
drop in 1
gen year = substr(date, -4, 4)

destring year medianmonthlywage*, replace
gen month = substr(date, 1, length(date)-5)
drop date

reshape long medianmonthlywage, i(year month) j(agegroup)

tab agegroup
drop if agegroup == 0
replace agegroup = 18 if agegroup < 50 
replace agegroup = 50 if agegroup >= 50
tab agegroup
collapse (mean) medianmonthlywage, by(year month agegroup)
collapse (mean) medianmonthlywage, by(year agegroup)

rename medianmonthlywage medianmonthlywage_paye

tempfile medwage
save `medwage'

*MEAN
import excel using "$rawpayedata/july14-nov22", sheet("30. Mean pay (Age)") clear
drop in 1/5
rename A date 
rename B meanmonthlywage0
rename C meanmonthlywage18
rename D meanmonthlywage25
rename E meanmonthlywage35
rename F meanmonthlywage50
rename G meanmonthlywage65
rename H meanmonthlywagetot
drop in 1
gen year = substr(date, -4, 4)

destring year meanmonthlywage*, replace
gen month = substr(date, 1, length(date)-5)
drop date

reshape long meanmonthlywage, i(year month) j(agegroup)

*ashe age groups 18-21, 22-29, 30-39, 40-49, 50-59, 60+
tab agegroup
drop if agegroup == 0
replace agegroup = 18 if agegroup < 50 
replace agegroup = 50 if agegroup >= 50
tab agegroup
collapse (mean) meanmonthlywage, by(year month agegroup)
collapse (mean) meanmonthlywage, by(year agegroup)

rename meanmonthlywage meanmonthlywage_paye


merge 1:1 year agegroup using `workers'
drop _merge
merge 1:1 year agegroup using `medwage'
drop _merge

save "$dataforchecks/paye_for_checks", replace
