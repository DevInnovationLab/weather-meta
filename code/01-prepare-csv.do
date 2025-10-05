/*******************************************************************************
                Weather forecast meta-analysis
 Creation date: 08/27/2025
 
 Description: This dofile runs forest plots on RCTs measuring the impact of forecasts
*******************************************************************************/

* Settings 
clear all
set more off

* Working directory
if "`c(username)'" == "gschinaia" {
	global project "C:/Users/`c(username)'/Dropbox/Chicago/DIL/icccfsa/weather-meta"
}

** sadly this is my username and I can't change it -Rayan
if "`c(username)'" == "admin" {
	global project "/Users/admin/Developer/weather-meta"
}
glo today: display %tdCCYY-NN-DD date(c(current_date), "DMY")

global data "$project/data"
global graphs "$project/graphs"
global tables "$project/tables"

glob out_gra "${graphs}/${today}"
cap mkdir 	 "${out_gra}"

********************************************************************************
**#                           1. Process data
********************************************************************************
import delimited "$data/meta-weather-raw.csv", clear

glo plots 1 2 3

*** Data prep
foreach v in effect_size standard_error control_mean control_sd{
	if "`v'"!= "effect_size"{
		replace `v' = ".m"   if `v' == "na"
		destring `v', replace 
	}
	*converting from 100,000 pesos
	replace `v'  = `v'*100000   if code == "camacho_2019" & variable_group == "costs" 
	*converting mounds/acre into kg/hectare
	replace `v'  = `v'*40*2.471 if code == "rudder_2024" & variable_group == "yields" 
	
	*converting costs per hectare  into total costs
	replace `v'  = `v'*6.28 if code == "yegbemey_2023" & variable_group == "costs" & (var_version==1|var_version==3)
	replace `v'  = `v'*4.45 if code == "yegbemey_2023" & variable_group == "costs" & (var_version==2|var_version==4)
	
	gen `v'_usd    = `v' * usdxr_yearofstudy
	gen `v'_usd23  = `v'_usd * usd_cum_inflation_to_2023
}


*Display code edits
gen 	dcode = subinstr(code, "_", "_etal_", .)
replace dcode = dcode + "_maize"  if code == "yegbemey_2023" & var_version == 1
replace dcode = dcode + "_cotton" if code == "yegbemey_2023" & var_version == 2
replace dcode = dcode + "_remote" if code == "cole_2025"     & var_version == 2 & variable_group == "yields"

* drop the paid labor outcomes for yegbemey_2023
drop if dcode == "yegbemey_etal_2023" & var_version>2

********************************************************************************
**#                2. Create effect sizes and standard errors 
********************************************************************************

*** Profits wt costs***
* Keep only the rows for specific studies
gen pes23v2 = effect_size_usd23 	 if variable_group == "profits" & !missing(effect_size)
gen pse23v2 = standard_error_usd23   if variable_group == "profits" & !missing(standard_error)

replace pes23v2 = -effect_size_usd23 	 if variable_group == "costs" & code == "yegbemey_2023" & !missing(effect_size)
replace pes23v2 = -effect_size_usd23 	 if variable_group == "costs" & code == "camacho_2019"  & !missing(effect_size)

replace pse23v2 = standard_error_usd23 if variable_group == "costs" & (code == "yegbemey_2023" | code == "camacho_2019" )

gen 	subgroup_cost = 0 if !missing(pes23v2)
replace subgroup_cost = 1 if variable_group == "costs" & (code == "yegbemey_2023" | code == "camacho_2019" )

label def subgroup_cost 0 "Profits" 1 "Cost savings"
label values  subgroup_cost subgroup_cost


*** Per-Hectare Profits & Costs***
bysort code var_version (variable_group): egen land_for_row = max(cond(variable_group=="land", control_mean, .))
* Scaling down effect size and standard errors by land size
foreach v in pes23v2 pse23v2{
	gen `v'_perha = `v' / land_for_row if variable_group== "costs" | variable_group=="profits"
}

*** Yields ***
* Keep only the rows for specific studies
gen yes = effect_size 		if variable_group == "yields" & !missing(effect_size)
gen yse = standard_error  if variable_group == "yields" & !missing(standard_error)


********************************************************************************
**#                3. Create covariates
********************************************************************************
gen tkup_es = effect_size	 if variable_group == "takeup" & var_version == 1
gen tkup_se = standard_error if variable_group == "takeup" & var_version == 1
bys code: egen c_takeup_es = max(tkup_es)
bys code: egen c_takeup_se = max(tkup_se)

gen 	control_mean_prep = control_mean
replace control_mean_prep = control_mean_usd23 if !missing(control_mean_usd23)

********************************************************************************
**#                4. Make selection of outcomes to keep
********************************************************************************
drop if dcode == "cole_etal_2025_remote"
keep if variable_group == "profits" | variable_group == "yields" | variable_group == "costs"
keep if !missing(yes) | !missing(pes23v2) // drops studies that were not in the first forestplot FIXME: to be revised, e.g. include fafchamps?
drop if code == "fafchamps_2012"
order dcode 
sort variable_group dcode

rename (pes23v2 pse23v2 pes23v2_perha pse23v2_perha yes yse c_takeup_es c_takeup_se) (profitcosts_effectsize profitcosts_sterror profitcostsperha_effectsize profitcostsperha_sterror yields_effectsize yields_sterror takeup_effectsize takeup_sterror)
gen 	pct_of_controlmean = profitcosts_effectsize / control_mean_prep
replace pct_of_controlmean = yields_effectsize / control_mean_prep if missing(pct_of_controlmean)

order dcode subgroup_cost variable_group profitcosts_effectsize profitcosts_sterror profitcostsperha_effectsize profitcostsperha_sterror yields_effectsize yields_sterror takeup_effectsize takeup_sterror
order dcode-takeup_sterror definition pct_of_controlmean control_mean_prep n yearofstudy followup 
keep dcode-followup

export delimited  "$data/meta-weather-prep.csv",replace
