*sushil's directory
cd "$dropbox/personal/Potential Research/inflation and labour market/"

clear all
set varabbrev off

*set up directories
global rawasheoccdata "data/raw/ashe_occ"
global rawasheinddata "data/raw/ashe_ind"
global rawashepubprivdata "data/raw/ashe_pubpriv"
global rawpayedata "data/raw/paye_rti"
global dataforchecks "data/for_checks"
global dataforexplor "data/for_explor"

*clean data for checks
quietly do "code/1_clean_data/2_clean_ashe_forchecks.do"
quietly do "code/1_clean_data/3_clean_paye_forchecks.do"
quietly do "code/1_clean_data/4_merge_forchecks.do"

*clean data for data exploration
do "code/1_clean_data/5_clean_ashe_forexplor.do"

*clean data for main analyses