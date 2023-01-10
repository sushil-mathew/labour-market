cd "$dropbox/personal/Potential Research/inflation and labour market"

import delimited "data/lis_deflator.csv", clear
keep if base == "LIS"
encode country, generate(cid)
gen year = substr(dataset, -2, 2)
tab year
destring year, replace
tab year
replace year = 2000 + year if year <= 20
replace year = 1900 + year if year >= 69 & year < 2000
tab year

keep country cid year cpi2017 ppp2017usd lisppps

xtset cid year 

*tsline cpi2017, by(cid, rescale) name(cpibycountry, replace)

qui reg cpi2017 i.cid#c.year#c.year i.cid#c.year i.cid c.year 

predict cpictryres, residuals

*twoway (scatter cpictryres year, msize(vsmall) mcolor(black%50)), name(cpictryres, replace) 

rename country cname
bys cname (year): gen inflation = ((cpi2017/cpi2017[_n-1])^(1/(year-year[_n-1]))-1)*100

merge 1:m cname year using "data/wgsamp_by_age_group"

preserve
keep if cname == "United Kingdom"
keep if year >= 2000

gen lnwage = ln(meanwage)
twoway (scatter lnwage inflation, msize(vsmall) mcolor(black%30)), by(sex) name(ukwage_inf, replace)
sort year inflation
twoway (scatter lnwage year, msize(vsmall) mcolor(black%30) yaxis(1))(line inflation year, yaxis(2)), by(sex) name(ukwage_inf_year, replace)
twoway (scatter meanhourstot inflation, msize(vsmall) mcolor(black%30)), by(sex) name(ukhours_inf, replace)
sort year inflation
twoway (scatter meanhourstot year, msize(vsmall) mcolor(black%30) yaxis(1))(line inflation year, yaxis(2)), by(sex) name(ukhours_inf_year, replace)

restore

preserve
keep if cname == "United States"
keep if year >= 2000
gen lnwage = ln(meanwage)

twoway (scatter lnwage inflation, msize(vsmall) mcolor(black%30)), by(sex) name(uswage_inf, replace)
sort year inflation
twoway (scatter lnwage year, msize(vsmall) mcolor(black%30) yaxis(1))(line inflation year, yaxis(2)), by(sex) name(uswage_inf_year, replace)
restore

*what all these graphs are telling me is that inflation has low explanatory power on all these variables
