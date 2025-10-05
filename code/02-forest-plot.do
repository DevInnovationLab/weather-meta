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
**#                           1. Import data
********************************************************************************
import delimited "$data/meta-weather-prepped.csv", clear

glo plots 1 2 3

********************************************************************************
**#                           2. Run plots
********************************************************************************
foreach p in $plots{

	if "`p'" == "1"{

		*** Profits ***
		* Keep only the rows for specific studies
		gen pes23 = effect_size_usd23 	if variable_group == "profits" & !missing(effect_size)
		gen pse23 = standard_error_usd23 if variable_group == "profits" & !missing(standard_error)

		* Declare meta-analysis data: effect sizes and standard errors
		meta set pes23 pse23, studysize(n) studylabel(code)

		* Summarize using random-effects model
		meta summarize, random
		local pooled = r(theta)   // pooled effect estimate from random-effects 

		* Generate the forest plot with random-effects results
		meta forestplot, random noohetstats  noohomtest /*  xline(`pooled', lpattern(dash)) xline(0) */ scheme(lean2)

		**
		graph display, xsize(8)

		graph save     "${out_gra}/profits_fp"     , replace
    	graph export    "${out_gra}/profits_fp.png" , replace
	}

	if "`p'" == "2"{
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

		* Declare meta-analysis data: effect sizes and standard errors
		meta set pes23v2 pse23v2, studysize(n) studylabel(dcode) 

		* Summarize using random-effects model
		meta summarize, random subgroup(subgroup_cost) 
		scalar pooled = r(theta)   // pooled effect estimate from random-effects 

		* Generate the forest plot with random-effects results
		meta forestplot, random noohetstats  ///
						 noohomtest /* no overall homogeneity test */ ///
						 subgroup(subgroup_cost) /* no subgroup het test*/ ///
						 noghet /* add line: esrefl*/ ///
						 scheme(lean2) ///
						/*  xline(`pooled', lpattern(dash)) xline(0) */ ///
						 note("Random effects model. Values are in 2023 USD.")
		**
	    graph display, xsize(8)

		graph save     "${out_gra}/profits_costs_fp"     , replace
    	graph export    "${out_gra}/profits_costs_fp.png" , replace
	}

		if "`p'" == "3"{

		*** Yields ***
		* Keep only the rows for specific studies
		gen yes = effect_size 		if variable_group == "yields" & !missing(effect_size)
		gen yse = standard_error  if variable_group == "yields" & !missing(standard_error)

		* Declare meta-analysis data: effect sizes and standard errors
		meta set yes yse, studysize(n) studylabel(dcode)

		* Summarize using random-effects model
		meta summarize, random

		* Generate the forest plot with random-effects results
		meta forestplot, random noohetstats  noohomtest  ///
								scheme(lean2) ///
								 /* xline(`pooled', lpattern(dash)) xline(0) */ ///
								 note("Random effects model. Values are in kg/hectare.")
		**
	    graph display, xsize(8)
    
     	graph save     "${out_gra}/yields_fp"     , replace
    	graph export    "${out_gra}/yields_fp.png" , replace
	}

}
