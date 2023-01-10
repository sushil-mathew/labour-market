use "$dataforchecks/paye_for_checks", clear

merge 1:1 year agegroup using "$dataforchecks/ashe_for_checks"
keep if _merge == 3
drop _merge

lab define agegroup 18 "Age: 18-49" 50 "Age: 50+"
lab values agegroup agegroup

gen meandailywage_paye = meanmonthlywage_paye/30.4 // 365 days/12 months = 30.4 https://www.ons.gov.uk/employmentandlabourmarket/peopleinwork/earningsandworkinghours/articles/newmethodsformonthlyearningsandemploymentestimatesfrompayasyouearnrealtimeinformationpayertidata/december2019

gen mediandailywage_paye = medianmonthlywage_paye/30.4
gen meandailywage_ashe = meanannualwage_ashe/365
gen mediandailywage_ashe = medianannualwage_ashe/365

gen logworkers = ln(noworkers)
gen logjobs = ln(nojobs)

*label variables
lab var year "Year"
lab var agegroup "Age group"
lab var noworkers "Number of workers from PAYE"
lab var logworkers "Natural log - Number of workers from PAYE"
lab var meanmonthlywage_paye "Mean monthly wage from PAYE"
lab var medianmonthlywage_paye "Median monthly wage from PAYE"
lab var nojobs "Number of jobs from ASHE"
lab var logjobs "Natural log - Number of jobs from ASHE" 
lab var medianannualwage_ashe "Median annual wage from ASHE"
lab var meanannualwage_ashe "Mean annual wage from ASHE"
lab var meandailywage_paye "Mean daily wage from PAYE" 
lab var mediandailywage_paye "Median daily wage from PAYE"
lab var meandailywage_ashe "Mean daily wage from ASHE"
lab var mediandailywage_ashe "Median daily wage from ASHE"

save "$dataforchecks/paye_ashe_for_checks", replace
