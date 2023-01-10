*-------------------------------------------------------------------------------
* SECTION 1
*-------------------------------------------------------------------------------
* CLEAN ASHE OCC DATA TO CHECK IF NUMBER OF JOBS, MEAN AND MEDIAN WAGES AGGREGATE 
* WELL TO PAYE DATA
*-------------------------------------------------------------------------------
forval y=2007/2022{
	import excel using "$rawasheoccdata/`y'/Annual pay - Gross `y'", sheet("All") clear
	keep A B C D F
	drop in 1/4
	rename A soc_desc
	rename B soc_code
	rename C no_jobs_in1000
	rename D medianannualwage 
	rename F meanannualwage

	list *wage in 1 // check if I've renamed the variables correctly above
	drop in 1 //this is just the title of the column, I've renamed the variables
	gen year = `y'
	
	drop in 1
	keep in 1/6
	rename soc_desc age_group //we have 18-21, 22-29, 30-39, 40-49, 50-59, 60+ in this dataset
	drop soc_code 
	destring *wage no_jobs_in1000, replace
	tab age_group, mis
	gen agegroup = 18 if inlist(age_group, "18-21", "22-29", "30-39", "40-49")
	replace agegroup = 50 if agegroup == .
	gen long nojobs = no_jobs_in1000*1000
	collapse (rawsum) nojobs (mean) *wage, by(year agegroup)
	rename *wage *wage_ashe
	tempfile ashe`y'
	save `ashe`y''
}

use `ashe2007', clear
forval y=2008/2022 {
	append using `ashe`y''
}

save "$dataforchecks/ashe_for_checks", replace
