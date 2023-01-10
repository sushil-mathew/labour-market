*-------------------------------------------------------------------------------
* SECTION 1
*-------------------------------------------------------------------------------
* CLEAN ASHE OCCUPATION DATA
*-------------------------------------------------------------------------------
forval y=2007/2022{
	import excel using "$rawasheoccdata/`y'/Annual pay - Gross `y'.xls", sheet("All") clear
	keep A-D F H-Q
	drop if missing(B)
	rename A soc_desc
	rename B soc_code
	rename C no_jobs_in1000
	rename D medianannualwage 
	rename F meanannualwage
	rename H p10annualwage 
	rename I p20annualwage
	rename J p25annualwage 
	rename K p30annualwage
	rename L p40annualwage
	rename M p60annualwage
	rename N p70annualwage
	rename O p75annualwage
	rename P p80annualwage
	rename Q p90annualwage

	list *wage in 1 // check if I've renamed the variables correctly above
	drop in 1 //this is just the title of the column, I've renamed the variables
	gen year = `y'
	
	destring *wage no_jobs_in1000 soc_code, replace force
	replace soc_desc = trim(soc_desc)	//remove leading and trailing spaces
	gen agegroup = substr(soc_desc, 1, 5) if substr(soc_desc, 1, 3) != "60+"
	*cleaning up some messy strings from previous command
	replace agegroup = "60+" if substr(soc_desc, 1, 3) == "60+"
	*creating agegroup as an integer
	gen agegroupint = real(substr(agegroup, 1, 2))
	replace soc_desc = substr(soc_desc, 6, .) if substr(soc_desc, 1, 3) != "60+"
	replace soc_desc = substr(soc_desc, 4, .) if substr(soc_desc, 1, 3) == "60+"
	gen long nojobs = no_jobs_in1000*1000
	drop no_jobs_in1000
	tempfile ashe`y'
	save `ashe`y''
}

use `ashe2007', clear
forval y=2008/2022 {
	append using `ashe`y''
}

drop soc_desc
*reshape to wide 
rename (*wage nojobs) (*wage_soc_ nojobs_soc_)
reshape wide medianannualwage_soc_ meanannualwage_soc_ p10annualwage_soc_ p20annualwage_soc_ p25annualwage_soc_ p30annualwage_soc_ p40annualwage_soc_ p60annualwage_soc_ p70annualwage_soc_ p75annualwage_soc_ p80annualwage_soc_ p90annualwage_soc_ nojobs_soc_, i(agegroup agegroupint year) j(soc_code)

tempfile asheocc
save `asheocc'

*-------------------------------------------------------------------------------
* SECTION 2
*-------------------------------------------------------------------------------
* CLEAN ASHE INDUSTRY DATA
*-------------------------------------------------------------------------------
forval y=2007/2022{
	import excel using "$rawasheinddata/`y'/Annual pay - Gross `y'", sheet("All") clear
	keep A-D F H-Q
	drop if missing(B)
	rename A sic_desc
	rename B sic_code
	rename C no_jobs_in1000
	rename D medianannualwage 
	rename F meanannualwage
	rename H p10annualwage 
	rename I p20annualwage
	rename J p25annualwage 
	rename K p30annualwage
	rename L p40annualwage
	rename M p60annualwage
	rename N p70annualwage
	rename O p75annualwage
	rename P p80annualwage
	rename Q p90annualwage

	list *wage in 1 // check if I've renamed the variables correctly above
	drop in 1 //this is just the title of the column, I've renamed the variables
	gen year = `y'
	
	destring *wage no_jobs_in1000, replace force
	replace sic_desc = trim(sic_desc)	//remove leading and trailing spaces
	gen agegroup = substr(sic_desc, 1, 5) if substr(sic_desc, 1, 3) != "60+"
	*cleaning up some messy strings from previous command
	replace agegroup = "60+" if substr(sic_desc, 1, 3) == "60+"
	*creating agegroup as an integer
	gen agegroupint = real(substr(agegroup, 1, 2))
	replace sic_desc = substr(sic_desc, 6, .) if substr(sic_desc, 1, 3) != "60+"
	replace sic_desc = substr(sic_desc, 4, .) if substr(sic_desc, 1, 3) == "60+"
	gen long nojobs = no_jobs_in1000*1000
	drop no_jobs_in1000
	tempfile ashe`y'
	save `ashe`y''
}

use `ashe2007', clear
forval y=2008/2022 {
	append using `ashe`y''
}

drop sic_desc
*reshape to wide
rename (*wage nojobs) (*wage_sic_ nojobs_sic_)
reshape wide medianannualwage_sic_ meanannualwage_sic_ p10annualwage_sic_ p20annualwage_sic_ p25annualwage_sic_ p30annualwage_sic_ p40annualwage_sic_ p60annualwage_sic_ p70annualwage_sic_ p75annualwage_sic_ p80annualwage_sic_ p90annualwage_sic_ nojobs_sic_, i(agegroup agegroupint year) j(sic_code) string


tempfile asheind
save `asheind'

*-------------------------------------------------------------------------------
* SECTION 3
*-------------------------------------------------------------------------------
* CLEAN ASHE PUBLIC-PRIVATE DATA
*-------------------------------------------------------------------------------

forval y=2007/2022{
	import excel using "$rawashepubprivdata/`y'/Annual pay - Gross `y'", sheet("All") clear
	keep A C-D F H-Q
	drop if missing(C)
	rename A pub_priv
	rename C no_jobs_in1000
	rename D medianannualwage 
	rename F meanannualwage
	rename H p10annualwage 
	rename I p20annualwage
	rename J p25annualwage 
	rename K p30annualwage
	rename L p40annualwage
	rename M p60annualwage
	rename N p70annualwage
	rename O p75annualwage
	rename P p80annualwage
	rename Q p90annualwage

	list *wage in 1 // check if I've renamed the variables correctly above
	drop in 1/3 //this is just the title of the column, I've renamed the variables
	gen year = `y'
	
	destring *wage no_jobs_in1000, replace force
	replace pub_priv = trim(pub_priv)	//remove leading and trailing spaces
	gen long nojobs = no_jobs_in1000*1000
	drop no_jobs_in1000
	tempfile ashe`y'
	save `ashe`y''
}

use `ashe2007', clear
forval y=2008/2022 {
	append using `ashe`y''
}
gen ppcode = "pub" if pub_priv == "Public sector"
replace ppcode = "priv" if pub_priv == "Private sector"
replace ppcode = "other" if missing(ppcode)
*reshape to wide
rename (*wage nojobs) (*wage_ nojobs_)
collapse (mean) medianannualwage_ meanannualwage_ p10annualwage_ p20annualwage_ p25annualwage_ p30annualwage_ p40annualwage_ p60annualwage_ p70annualwage_ p75annualwage_ p80annualwage_ p90annualwage_ nojobs_, by(year ppcode)
reshape wide medianannualwage_ meanannualwage_ p10annualwage_ p20annualwage_ p25annualwage_ p30annualwage_ p40annualwage_ p60annualwage_ p70annualwage_ p75annualwage_ p80annualwage_ p90annualwage_ nojobs_, i(year) j(ppcode) string

tempfile ashepubpriv
save `ashepubpriv'

use `asheocc', clear
merge 1:1 year agegroup using `asheind'
drop _merge
merge m:1 year using `ashepubpriv'
drop _merge


save "$dataforexplor/ashe_for_explor", replace
