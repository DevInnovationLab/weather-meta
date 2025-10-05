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

if "`c(username)'" == "" {
	global data ""
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
import delimited "$data/meta-weather.csv", clear

glo plots 1 2 3

*** Data prep
foreach v in effect_size standard_error control_mean control_sd{
	if "`v'"!= "effect_size"{
		replace `v' = ".m"   if `v' == "na"
		destring `v', replace 
	}
	replace `v'  = `v'*100000   if code == "camacho_2019" & variable_group == "costs" //converting from 100,000 pesos
	replace `v'  = `v'*40*2.471 if code == "rudder_2024" & variable_group == "yields" //converting mounds/acre into kg/hectare
	gen `v'_usd    = `v' * usdxr_yearofstudy
	gen `v'_usd23  = `v'_usd * usd_cum_inflation_to_2023
}

*Display code edits
gen 	dcode = subinstr(code, "_", "_etal_", .)
replace dcode = dcode + "_maize"  if code == "yegbemey_2023" & var_version == 1
replace dcode = dcode + "_cotton" if code == "yegbemey_2023" & var_version == 2
replace dcode = dcode + "_remote" if code == "cole_2025"     & var_version == 2 & variable_group == "yields"

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


*** Yields ***
* Keep only the rows for specific studies
gen yes = effect_size 		if variable_group == "yields" & !missing(effect_size)
gen yse = standard_error  if variable_group == "yields" & !missing(standard_error)



