*sushil's directory
cd "$dropbox/personal/Potential Research/inflation and labour market/"

clear all
set varabbrev off

global dataforchecks "data/for_checks"
global output "output/checks"

use "$dataforchecks/paye_ashe_for_checks", clear
*plot time series by age group for number of workers and jobs
xtset agegroup year
xtline logworkers logjobs 	//we're seeing what we expect to see
							//number of workers > number of jobs
							//larger proportion of younger workers work part time compared to older individuals
graph export "$output/workers_and_jobs.png", replace

*plot time series by age group for median from both sources - this is a bad check because I average the medians for all age groups. This is not a sensible quantity.
xtline mediandailywage_paye mediandailywage_ashe
graph export "$output/mediandailywages.png", replace
*plot time series by age group for mean from both sources - convert both to daily by dividing by 365
xtline meandailywage_paye meandailywage_ashe //not clear why there should be these differences between ASHE and PAYE, but it's not large enough to matter I think
graph export "$output/meandailywages.png", replace
