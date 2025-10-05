clear all

set trace off
ssc install eclplot 


**** Initiating the loop for each category

local category assets work education aspirations
foreach cat in `category' {

global user = "`c(username)'"
di "$user"

loc dir "$path8/for specific tables/07 comparison/"
//if "$user" == "gschinaia" loc dir "C:/Users/$user/Dropbox/DriveLab/01 Ethiopia Aspirations/00 Analysis/03 Results/07 comparison/"


loc dta_working "`dir'\data"
loc figures "`dir'\output"

	import excel "`dta_working'\Ethiopia aspirations comparison table.xlsx", sheet("format_stata") firstrow clear

    
	if "`cat'" == "assets" {
	    loc section_names " "Total assets" "Productive assets" "Durable assets ""
		loc sections total_assets productive_assets durable_assets
		loc field Assets
		local theme_title "Investment and assets"
		local exception_controlm if !inlist(varname, "asset_bcbt_conz", "asset_bcas_dur")
		loc num G1
		
		loc subfield_num1 Total assets value
		loc subfield_num2 Productive assets (including livestock)
		loc subfield_num3 Durable assets
		loc subfield_num4

	}
	
	if "`cat'" == "work" {
	    loc section_names " "Minutes worked daily""
		loc sections hours_worked
		loc field Work
		local theme_title "Work"
		local exception_controlm if !inlist(varname, "work_roj", "work_bat")
		loc num G2
		
		loc subfield_num1 Minutes worked daily
		loc subfield_num2
		loc subfield_num3 
		loc subfield_num4 
			}

	if "`cat'" == "aspirations" {
		loc section_names " "Aspirations" "Expected education""
		loc sections aspirations educ_exct
		loc field Aspirations
		local theme_title "Aspirations and expectations"
		local exception_controlm if !inlist(varname, "asp_roj_om", "asp_roj_oy", "asp_cec")		
		loc num G3
		
		loc subfield_num1 Aspirations
		loc subfield_num2 Expected education
		loc subfield_num3
		loc subfield_num4
			}

	if "`cat'" == "education" {
		loc section_names " "Educational expenditure" " 
		loc sections educ_exp 
		loc field Education
		local theme_title "Education"
		local exception_control if !inlist(varname,	eexp_jork)
		loc num G4
		
		loc subfield_num1 Educational expenditure
		loc subfield_num2 
		loc subfield_num3 
		loc subfield_num4
			}

* Creating varnames equal to the family of outcome in which each variable belongs

//Assets
loc total_assets "asset_easp_tot asset_eup_tot asset_oasp_nlnlo"
loc productive_assets " asset_eup_prod asset_bcas_bus asset_oasp_prod  asset_easp_com"
loc durable_assets "asset_easp_dur  asset_oasp_dur asset_bcbt_conz asset_bcas_dur asset_eup_hou" 


// Work
loc hours_worked "work_easp_mwd work_easp_mwd_r work_oasp_mwd work_oasp_mwd_r work_ocash_mwd work_eup_mwd work_bcbt_mwd work_bcash_mwd work_bcbt23_mwd work_bcash23_mwd work_jork_mwd work_lug work_cec"

// Aspirations
loc aspirations "asp_easp_ai asp_bea_wcg asp_mac_spef asp_luge asp_roj_oy asp_bat asp_cec asp_oasp"
loc educ_exct "eee_easp eee_bara eee_oasp"

// Educ attainment
loc educ_exp "eexp_easp eexp_jork eexp_brnv eexp_oasp"

gen area = ""
loc area_order 1
loc var_order 1

gen study_order = .
replace study_order = 1 if paper == "Ethiopia aspirations 2024"
replace study_order = 2 if paper == "Ethiopia aspirations 2024 (tools)"
replace study_order = 3 if paper == "Ethiopia aspirations 2024 (livestock)"
replace study_order = 15 if paper == "John and Orkin 2022"
replace study_order =  16 if paper == "Orkin et al 2014 aspirations"
replace study_order =  17 if paper == "Orkin et al 2014 cash"
replace study_order = 4 if paper == "Ethiopia ultra poor 2015"
replace study_order = 20 if paper == "Pooled ultra poor 2015"
replace study_order = 21 if paper == "Ethiopia ultra poor 2024"
replace study_order = 8 if paper == "Blattman 2017 cbt (EL 1 year)"
replace study_order = 9 if paper == "Blattman 2017 cash (EL 1 year)"
replace study_order = 10 if paper == "Blattman 2023 cbt (EL 10 years)"
replace study_order = 11 if paper == "Blattman 2023 cash (EL 10 years)"
replace study_order = 7 if paper == "Beaman et al 2012"
replace study_order = 5 if paper == "Baranov"
replace study_order =  14 if paper == "Macours Vakis 2009"
replace study_order = 6 if paper == "Batista"
replace study_order = 13 if paper == "Lugeba"
replace study_order =  19 if paper == "Rojas"
replace study_order = 12 if paper == "Cecchi"
replace study_order = 18 if paper == "Riley 2024"



gen subfield_num = .
replace subfield_num = 1 if subfield == "`subfield_num1'"
replace subfield_num = 2 if subfield ==  "`subfield_num2'" 
replace subfield_num = 3 if subfield ==  "`subfield_num3'" 
replace subfield_num = 4 if subfield ==  "`subfield_num4'" 

keep if field == "`field'" & subfield != ""

sort subfield_num study_order 



gen area_num = .
*gen order = .
gen outcome_order = .
loc areacount: word count `sections'
forvalues i = 1/`areacount' {
	loc outcome_order 1
	loc area_num `i'
	loc name: word `i' of `section_names'
	loc section: word `i' of `sections'
	foreach test in ``section'' {
		replace area = "`name'" if varname=="`test'"
		replace outcome_order = `outcome_order' if varname=="`test'"
		replace area_num = `area_num' if varname=="`test'"
		loc ++var_order
		loc ++outcome_order
	}
}

sort area_num study_order
gen order = _n

 

//Temporary

* Creating horizontal lines between sections

isid area_num outcome_order
# de ;
lab de area_num 
1 "`subfield_num1'"
2 "`subfield_num2'"
3 "`subfield_num3'"
4 "`subfield_num4''"

;
# de cr
lab values area_num area_num

loc n 0
loc i 0
while `++i' <= _N {
	if subfield[`i'] != subfield[`i' - 1] {
		loc ++n
		
		set obs `=_N + 2'
		replace order = order + 2 if _n >= `i'
		replace order = `i'		in `=_N - 1'
		replace order = `i' + 1	in L

		loc line_move_up 1.5
		loc ln`n' = cond(`i' == 1, 2.2, order[`i'] - 0.7) - `line_move_up'

		sort order
		loc i = `i' + 2
	}
}
 

assert `n'==`areacount'



*****************gen prefix of study authors
gen study_authors = ""
replace study_authors = "John and Orkin 2022" if paper == "John and Orkin 2022"
replace study_authors = "Bernard et al. 2025" if paper == "Ethiopia aspirations 2024"
replace study_authors = "Bernard et al. 2025 (tools)" if paper == "Ethiopia aspirations 2024 (tools)"
replace study_authors = "Bernard et al. 2025 (livestock)" if paper == "Ethiopia aspirations 2024 (livestock)"
replace study_authors = "Orkin et al. 2024" if paper == "Orkin et al 2014 aspirations"
replace study_authors = "Banerjee et al. 2015"  if paper == "Ethiopia ultra poor 2015"
replace study_authors = "Banerjee et al. 2015 (Pooled)"  if paper == "Pooled ultra poor 2015"
replace study_authors = "Barker et al. 2024"  if paper == "Ethiopia ultra poor 2024"
replace study_authors =  "Blattman, Jamison, and Sheridan 2017" if paper == "Blattman 2017 cbt (EL 1 year)"
replace study_authors =  "Blattman et al. 2023" if paper == "Blattman 2023 cbt (EL 10 years)"
replace study_authors = "Beaman et al. 2012"  if paper == "Beaman et al 2012" 
replace study_authors = "Baranov et al. 2020" if paper == "Baranov"
replace study_authors = "Macours and Vakis 2009" if paper == "Macours Vakis 2009"
replace study_authors = "Riley 2024" if paper == "Riley 2024"
replace study_authors = "Batista and Seither 2019" if paper == "Batista"
replace study_authors = "Lubega et al. 2021" if paper == "Lugeba"
replace study_authors = "Rojas Valdes, Wydick, and Lybbert 2022" if paper == "Rojas"
replace study_authors = "Cecchi et al. 2022" if paper == "Cecchi"


	foreach clear in lxs rxs textadd yline posclr negclr nsclr color msymbol estopts ciopts ///
		compltext comprtext inf opts  labelstext_lu labelstext_ld labelstext_ln labelstext_ru ///
		labelstext_rd labelstext_rn rangel ranger midpoint outliervar {
		loc `clear'
	}
	loc areacount: word count `sections'
	
	*Expressing the effect size in terms of percentage of the control mean
	gen effect_perc = b_treatment_end
	replace effect_perc = b_treatment_end/controlmean_end  if !inlist(varname, "asset_bcbt_conz", "eexp_jork", "work_roj", "work_bat", "asp_roj_om", "asp_roj_oy", "asp_cec",  "eexp_brnv", "asp_easp_ai") & varname != "asp_oasp" // MANUALLY ADD PAPERS FOR WHICH YOU DO NOT STANDARDIZE (because the coefficients are already standardized, sometimes in a different manner)
		
	gen se_treat_perc = se_treatment_end
	replace se_treat_perc = se_treatment_end/controlmean_end  if !inlist(varname, "asset_bcbt_conz", "eexp_jork", "work_roj", "work_bat", "asp_roj_om", "asp_roj_oy", "asp_cec", "eexp_brnv", "asp_easp_ai") & varname != "asp_oasp" // MANUALLY ADD PAPERS FOR WHICH YOU DO NOT STANDARDIZE (because the coefficients are already standardized, sometimes in a different manner)
	
	
	* Generating upper and lower confidence intervals for each outcome variable
	gen norm_cl_treatment = effect_perc - 1.95996398454005 * (se_treat_perc) // Those are the values for 95% confidence intervals. I am not sure whether to use those or the ones for 90% confidence intervals
	gen norm_cu_treatment = effect_perc + 1.95996398454005 * (se_treat_perc)
	
	* Calculating z_scores and p-values
	
	gen z_stat = b_treatment_end/se_treatment_end
	gen p_value_treat = 2 * (1-normal(abs(z_stat)))
 
	* Interpretation of significance (to be used for color-coding graph)
	gen inference = ""
	replace inference = "Positive impact" if effect_perc >= 0 & ///
		p_value_treat < .05
	replace inference  = "Negative impact" if effect_perc < 0 & ///
		p_value_treat < .05
	replace inference = "Not significant" if p_value_treat >= .05
	encode inference, gen(inference_num)

	* Creating scale for x-axis, width based on upper and lower bounds of min and max
	su norm_cl_treatment
	loc lxs = min(r(min), -0.6)
	su norm_cu_treatment
	//loc rxs = max(r(max), .4)
	loc rxs = max(1, .4)

	* Area titles (-text()-)
	loc textadd text(
	forv i = 1/`areacount' {
		loc text_move_down 0.6
		loc p = `ln`i'' + `line_move_up' + `text_move_down'
		loc textadd `textadd' `p' `lxs' "`:lab area_num `i''"
	}
	loc textadd `textadd', margin(small) place(1) just(left) color(black))

	* Horizontal lines (-yline()-)
	if `areacount' != 1 {
	loc yline yline(
	forv i = 2/`areacount' {
		loc yline `yline' `ln`i''
	}
	loc yline `yline', lpattern(dash) lcolor(gs8))
	}


	* Color constants
	* "clr" suffix for "color": "posclr" for "positive (impact) color."
	loc posclr black
	loc negclr black
	* "ns" for "not significant"
	loc nsclr black
	
	* Assigning symbols to significance
	tab inference_num
	* -estopts#()- and -ciopts#()-
	forv i = 1/`r(r)' {
		loc lab`i' : lab inference_num `i'
		if "`lab`i''" == "Positive impact" {
			loc color `posclr'
			loc msymbol D // diamond
		}
		else if "`lab`i''" == "Negative impact" {
			loc color `negclr'
			loc msymbol D // diamond
		}
		else if "`lab`i''" == "Not significant" {
			loc color `nsclr'
			loc msymbol D // diamond
		}
		else {
			di as err "invalid inference_num value label"
			ex 9
		}

		loc estopts `estopts' estopts`i'(msymbol(`msymbol') mcolor(`color'))
		loc ciopts  `ciopts'  ciopts`i'(lpattern(solid) lcolor(`color'))
	}
	* Added text
	loc compltext " "
	loc comprtext " "
	forv j = 1/`=_N' {
		local v_adj = cond(inference[`j'] != "Not significant", "+0.1", "") 
		if study_authors[`j'] != "" {
			loc d = cond(norm_cl_treatment[`j'] - ///
				length(study_authors[`j']) / 140 > `lxs', "l", "r")
			#d ;
			loc inf =
				cond(inference[`j'] == "Positive impact",  "u",
				cond(inference[`j'] == "Negative impact",  "d",
				cond(inference[`j'] == "Not significant",  "n", "")))
			;
			#d cr
			assert "`inf'" != ""
				if strpos("`=study_authors[`j']'", "Bernard et al. 2023") == 1 {
				loc labelstext_`d'`inf' `labelstext_`d'`inf'' ///
				`=order[`j']`v_adj'' `=norm_cl_treatment[`j']' ///
				"{bf:`=study_authors[`j']'}"
			}
			else if strpos("`=study_authors[`j']'", "Bernard et al. 2023") == 0 {
				loc labelstext_`d'`inf' `labelstext_`d'`inf'' ///
				`=order[`j']`v_adj'' `=norm_cl_treatment[`j']' ///
				"`=study_authors[`j']'"
			}
		}
	}
	* `comp?text'
	loc compltext `compltext', ///
		margin(right) place(9) just(right) align(bottom) size(vsmall)
	loc comprtext `comprtext', ///
		margin(left) place(3) just(left) align(bottom) size(vsmall)
	* `labelstext_l?'
	loc opts margin(right) place(9) just(right) align(bottom) size(vsmall)
	loc labelstext_lu `labelstext_lu', color(`posclr') `opts'
	loc labelstext_ld `labelstext_ld', color(`negclr') `opts'
	loc labelstext_ln `labelstext_ln', color(`nsclr') `opts'

	* `labelstext_r?'
	loc margin(left) opts place(3) just(left) align(bottom) size(vsmall)
	loc labelstext_ru `labelstext_ru', color(`posclr') `opts'
	loc labelstext_rd `labelstext_rd', color(`negclr') `opts'
	loc labelstext_rn `labelstext_rn', color(`nsclr') `opts'


	
	/* -------------------------------------------------------------------------- */
						/* export graph			*/

	

	loc gtitle `num': `theme_title'

	
	loc caption ""
	
	#d cr
	foreach lcl in gtitle caption {
		mata: st_local("`lcl'", stritrim(st_local("`lcl'")))
	}
	
	
	graph drop _all
	#d ;
	eclplot effect_perc norm_cl_treatment norm_cu_treatment order,
		supby(inference_num, spaceby(0.1)) `estopts' `ciopts'
		horizontal plotregion(style(none) color(white))
		graphregion(style(none) color(white)) scale(.5)
		/* title, etc. */
		//title("`gtitle'", margin(medlarge) align(top) size(medlarge) color(gs1*10))
		caption(`caption', size(small)) legend(off)
		/* y-axis */
		ytitle("") yscale(noline) ylab(none, noticks)
		/* x-axis */
		//xtitle("Effect size expressed as a fraction of the control group mean",	margin(small) color(gs3))
		xtitle("",	margin(small) color(gs3))
		xscale(range(`lxs'/`rxs') lcolor(gs3))
		xlab(#15, labcolor(gs3) format(%9.1f)) //MD changed back to #15 instead of `xlabel' 8/26/2014
		/* added lines */
		`yline' xline(0 `midpoint', lpattern(dash) lwidth(vthin) lcolor(gs8*1.2))
		/* added text */
		`textadd'
		text(`labelstext_lu') text(`labelstext_ld')
		text(`labelstext_ln') text(`labelstext_ru') 
		text(`labelstext_rd') text(`labelstext_rn')
		text(`compltext')     text(`comprtext')
		name(graph_`cat', replace)
		saving(graph_`cat', replace)
	;
	
	
	#d cr
	global sgtitle \Figure_`num'_`cat'
	graph save "`figures'\$sgtitle.gph", replace 
	
	graph export "`figures'$sgtitle.ps", ///
		logo(off) pagesize(letter) mag(185) orientation(landscape) ///
		tmargin(.5) lmargin(.4) replace
	graph export "`figures'$sgtitle.wmf", ///
			fontface("Times New Roman") replace
	graph export "`figures'$sgtitle.pdf", ///
		replace
		

}



graph combine  "graph_assets"  "graph_work" "graph_aspirations" "graph_education", cols(2) name(combinedGraph, replace) graphregion(style(none) color(white))


graph save "`figures'\combined_graph.gph", replace 
graph export "`figures'\combined_graph.pdf", replace
