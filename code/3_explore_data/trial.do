*sushil's directory
cd "$dropbox/personal/Potential Research/inflation and labour market/"

clear all
set varabbrev off

*set up directories
global dataforexplor "data/for_explor"

use "$dataforexplor/ashe_for_explor", clear
drop *_sic_*
drop *_pub*
drop *_priv*
drop *_other*
drop p*wage*
reshape long medianannualwage_soc_ meanannualwage_soc_ nojobs_soc_, i(year agegroup agegroupint) j(soc)
rename (medianannualwage_soc_ meanannualwage_soc_ nojobs_soc_)(medianannualwage meanannualwage nojobs)
tab soc
drop if soc <= 9

reg meanannualwage i.year#i.agegroupint i.agegroupint
margins i.agegroupint#i.year i.agegroupint
marginsplot, xdimension(year) noci