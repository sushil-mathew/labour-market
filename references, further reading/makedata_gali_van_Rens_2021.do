**************************************************************************************
* Clean raw data:
**************************************************************************************

* LPC data, private non-farm business sector:

clear
set more off
insheet using lpc_clean.csv, comma names

foreach VAR of varlist prs* {
	replace `VAR' = substr(`VAR',1,7) if substr(`VAR',8,3)=="(R)"
}
destring _all, replace

ren prs85006013 empl
ren prs85006023 hrspwk
ren prs85006033 hours
ren prs85006043 output
ren prs85006053 output_nom
ren prs85006093 oph
ren prs85006163 opp
drop prs*

gen byte qrt = real(substr(period,4,1))
gen int year = real(substr(period,6,4))
drop period
order year qrt
sort year qrt
gen time = year + 0.25*(qrt-1)
gen int t = 4*(year-1960)+qrt-1
tsset t, quarterly

save data, replace


**************************************************************************************
* Check consistency:
**************************************************************************************

clear
use data

gen hours2 = empl * hrspwk
corr hours hours2
drop hours2

gen oph2 = output/hours
corr oph oph2
drop oph2

gen opp2 = output/empl
corr opp opp2
drop opp2


**************************************************************************************
* Filter the data:
**************************************************************************************

clear
set matsize 800
use data

drop if hours==. | output==.
su year

* HP filter, BP filter and 4th difference in logs:
foreach VAR of varlist empl hrspwk hours output oph opp {
	gen `VAR'_log = 100*ln(`VAR')
	hpfilter `VAR'_log, l(1600)
	gen `VAR'_hp = `VAR'_log - H
	drop H
	bpass `VAR'_log 6 32
	svmat fX
	ren fX1 `VAR'_bp
	gen `VAR'_4d = `VAR'_log - L4.`VAR'_log
}
drop if hours_4d ==.

* Result: filtered data 1948:I-2015:II

save data_filtered, replace


**************************************************************************************
* Graphs with NBER dates:
**************************************************************************************

clear
use data_filtered
set more off
pause on

* Define NBER business cycle dates graph command:
qui su oph_hp
local axmin = 1.1*r(min)
local axmax = 1.1*r(max)
* Note: time defined such that 1980:I = 1980, 1980:II = 1980.25, etc.
* Note: Recession dates based on monthly NBER dates, from peak to trough
local NBER1 = "function y=`axmax', base(`axmin') range(1948.833333 1949.75) recast(area) color(gs12)"
local NBER2 = "function y=`axmax', base(`axmin') range(1953.5 1954.333333) recast(area) color(gs12)"
local NBER3 = "function y=`axmax', base(`axmin') range(1957.583333 1958.25) recast(area) color(gs12)"
local NBER4 = "function y=`axmax', base(`axmin') range(1960.25 1961.083333) recast(area) color(gs12)"
local NBER5 = "function y=`axmax', base(`axmin') range(1969.916667 1970.833333) recast(area) color(gs12)"
local NBER6 = "function y=`axmax', base(`axmin') range(1973.833333 1975.166667) recast(area) color(gs12)"
local NBER7 = "function y=`axmax', base(`axmin') range(1980 1980.5) recast(area) color(gs12)"
local NBER8 = "function y=`axmax', base(`axmin') range(1981.5 1982.833333) recast(area) color(gs12)"
local NBER9 = "function y=`axmax', base(`axmin') range(1990.5 1991.166667) recast(area) color(gs12)"
local NBER10 = "function y=`axmax', base(`axmin') range(2001.166667 2001.833333) recast(area) color(gs12)"
local NBER11 = "function y=`axmax', base(`axmin') range(2007.916667 2009.4166667) recast(area) color(gs12)"

* Graph with NBER business cycle dates:

*nbercycles oph_bp, file(nberdates.do) replace
*pause 

twoway (`NBER1') (`NBER2') (`NBER3') (`NBER4') (`NBER5') (`NBER6') (`NBER7') (`NBER8') (`NBER9') (`NBER10') (`NBER11') /* 
	*/ (line oph_hp time, lcol(blue) lpat(solid) lwidth(medthick) cmiss(n)) /*
	*/ if year>=1948 & year<=2016, yline(0) yti(" ", size(zero)) xti(" ", size(zero)) /*
	*/ xlabel(1950 1955 to 2015) xmlabel(1948 1949 to 2016, nolabels) legend(off) /*
	*/ ti("Labor productivity (HP filter)", size(medium))
graph export oph_nber_hp.eps, replace
pause

twoway (`NBER1') (`NBER2') (`NBER3') (`NBER4') (`NBER5') (`NBER6') (`NBER7') (`NBER8') (`NBER9') (`NBER10') (`NBER11') /* 
	*/ (line oph_bp time, lcol(blue) lpat(solid) lwidth(medthick) cmiss(n)) /*
	*/ if year>=1948 & year<=2016, yline(0) yti(" ", size(zero)) xti(" ", size(zero)) /*
	*/ xlabel(1950 1955 to 2015) xmlabel(1948 1949 to 2016, nolabels) legend(off) /*
	*/ ti("Labor productivity (bandpass filter)", size(medium))
graph export oph_nber_bp.eps, replace
pause

twoway (`NBER1') (`NBER2') (`NBER3') (`NBER4') (`NBER5') (`NBER6') (`NBER7') (`NBER8') (`NBER9') (`NBER10') (`NBER11') /* 
	*/ (line oph_bp time, lcol(red) lpat(dash) lwidth(medthick) cmiss(n)) /*
	*/ (line oph_hp time, lcol(blue) lpat(solid) lwidth(medthick) cmiss(n)) /*
	*/ if year>=1948 & year<=2016, yline(0) yti(" ", size(zero)) xti(" ", size(zero)) /*
	*/ xlabel(1950 1955 to 2015) xmlabel(1948 1949 to 2016, nolabels) legend(off) /*
	*/ ti("Labor productivity (solid: HP, dash: BP)", size(medium))
graph export oph_nber_hpbp.eps, replace
pause

**************************************************************************************
* Graphs with rolling correlation:
**************************************************************************************

clear
use data_filtered
*pause on

* Rolling correlations:

foreach window of numlist 4 6 8 10 12 {
local Tband = 0.5*4*`window'  /* in quarters, band on each side */
foreach FILTER in "hp" "bp" "4d" {
	gen corr_py_`FILTER' = .
	gen corr_ph_`FILTER' = .
	qui su t
	local Tmin = r(min) + `Tband'
	local Tmax = r(max) - `Tband'
	forvalues T = `Tmin'(1)`Tmax' {
		qui corr oph_`FILTER' output_`FILTER' if t>=`T'-`Tband' & t<=`T'+`Tband'
		qui replace corr_py_`FILTER' = r(rho) if t==`T'
		qui corr oph_`FILTER' hours_`FILTER' if t>=`T'-`Tband' & t<=`T'+`Tband'
		qui replace corr_ph_`FILTER' = r(rho) if t==`T'
	}
	twoway (line corr_ph_`FILTER' time, lcol(red) lpat(dash) lwidth(medthick) cmiss(n)) /*
		*/ (line corr_py_`FILTER' time, lcol(blue) lpat(solid) lwidth(medthick) cmiss(n)) /*
		*/ if year>=1948 & year<=2016, yline(0) yti(" ", size(zero)) xti(" ", size(zero)) /*
		*/ xlabel(1950 1955 to 2016) xmlabel(1948 1949 to 2016, nolabels) legend(off) /*
		*/ ti("Correl prod with output (blue) and hours (red), cntrd `window'-yr rolling window, `FILTER'", size(small))
	graph export corr_`window'_`FILTER'.eps, replace
	pause
}
drop corr_py_* corr_ph_*
}  /* end foreach window */

