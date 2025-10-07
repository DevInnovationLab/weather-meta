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
	global project "C:/Users/`c(username)'/Dropbox/Chicago/DIL/github/weather-meta"
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
**#                           1. Import data
********************************************************************************
import delimited "$data/meta-weather-prep.csv", clear

glo plots /*  2 3 4 */ 1 

sort dcode

********************************************************************************
**#                           2. Run plots
********************************************************************************
foreach p in $plots{

	if "`p'" == "1"{

		* Declare meta-analysis data: effect sizes and standard errors
		meta set profitcosts_effectsize profitcosts_sterror, studysize(n) studylabel(dcode)

		* Summarize using random-effects model
		meta summarize, random
		local pooled = r(theta)   // pooled effect estimate from random-effects 

		* Generate the forest plot with random-effects results
		meta forestplot, random noohetstats  noohomtest /*  xline(`pooled', lpattern(dash)) xline(0) */ scheme(lean2) ///
							 note("Random effects model. Values are in 2023 USD.")


		**
		graph display, xsize(8)

		graph save     "${out_gra}/profits_fp"     , replace
    	graph export    "${out_gra}/profits_fp.png" , replace
	}

	if "`p'" == "2"{

		* Declare meta-analysis data: effect sizes and standard errors
		meta set profitcosts_effectsize profitcosts_sterror, studysize(n) studylabel(dcode) 

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
		* Declare meta-analysis data: effect sizes and standard errors
		meta set yields_effectsize yields_sterror, studysize(n) studylabel(dcode)

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
	
	if "`p'" == "4"{
		
		* per-hectare effects
		* Declare meta-analysis data: effect sizes and standard errors
		meta set profitcostsperha_effectsize profitcostsperha_sterror, studysize(n) studylabel(dcode) 

		* Summarize using random-effects model
		meta summarize, random subgroup(subgroup_cost) 
		scalar pooled = r(theta)   // pooled effect estimate from random-effects 

		* Generate the forest plot with random-effects results
		meta forestplot, random noohetstats  ///
						 noohomtest /* no overall homogeneity test */ ///
						  /* subgroup(subgroup_cost) no subgroup het test*/ ///
						 noghet /* add line: esrefl*/ ///
						 scheme(lean2) ///
						/*  xline(`pooled', lpattern(dash)) xline(0) */ ///
						 note("Random effects model. Values are in 2023 USD per hectare.")
		**
	    graph display, xsize(8)

		graph save     "${out_gra}/profits_costs_perha_fp"     , replace
    	graph export    "${out_gra}/profits_costs_perha_fp.png" , replace
	}

}
