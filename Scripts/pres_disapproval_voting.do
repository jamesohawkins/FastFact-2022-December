// Presidential disapproval (2020 vs 2018 vs 2016 vs 2014)
// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
// Opening dataset
cd "$raw_data"
use cumulative_2006-2021.dta, clear

// Years of interest
keep if inlist(year, 2014, 2016, 2018, 2020)

// Weight
global weight weight_cumulative

// Voter turnout measure
keep if citizen == 1
fre vv_turnout_gvm
gen voted = (vv_turnout_gvm == 1)
fre voted
tab voted vv_turnout_gvm, mi

// Presidential disapproval measure
gen disapproved = 1 if inlist(approval_pres, 3, 4)
replace disapproved = 0 if inlist(approval_pres, 1, 2)
drop if disapproved == . // drop individuals who do not strongly/somewhat approve or disapprove

// Age group
gen age_bin = 1 if age >= 18 & age <= 29
	replace age_bin = 2 if age >= 30 & age <= 39
	replace age_bin = 3 if age >= 40 & age <= 64
	replace age_bin = 4 if age >= 65
label variable age "Age (binned)"
label values age_bin age_bin_lbl
label define age_bin_lbl ///
	1 "18-29" ///
	2 "30-39" ///
	3 "40-64" ///
	4 "65+"

// Covariates of interest
* college education dummy
	tab educ, missing
	tab educ, nol missing
	gen colleged = (educ >= 5 & educ != .)
	label variable colleged "College educational attainment (dummy)"
	label values colleged colleged_lbl
	label define colleged_lbl ///
		0 "Less than a college degree" ///
		1 "College or post-graduate degree"
* race
	tab race, missing
	tab race, nol missing
	gen raced = race
		replace raced = 5 if race >= 5 & race <= 8
		/* check: Hispanic both a category in race and in a separate question */
	label variable raced "Race"
	label values raced raced_lbl
	label define raced_lbl ///
		1 "White" ///
		2 "Black" ///
		3 "Hispanic" ///
		4 "Asian" ///
		5 "Other"
* marriage dummy
	gen mard = 1 if marstat == 1 | marstat == 6 /* married */
	replace mard = 0 if marstat >= 2 & marstat <= 5 /* all other marriage categories */
	replace mard = . if marstat == .
	label variable mard "Marriage (dummy)"
	label values mard mard_lbl
	label define mard_lbl ///
		0 "Not married" ///
		1 "Married"
* gender dummy
	tab gender, missing
	tab gender, nol missing
	gen genderd = (gender == 1 & gender != .)
	label variable genderd "Gender (dummy)"
	label values genderd genderd_lbl
	label define genderd_lbl ///
		0 "Female" ///
		1 "Male"
* employment status
	tab employ, missing
	tab employ, nol missing
		/* 41 missing observations */
	gen workd = 1 if employ == 3 | employ == 4 // temporarily laid off OR unemployed
		replace workd = 2 if employ == 1 | employ == 2 // full-time OR part-time
		replace workd = 3 if employ == 5 // retired
		replace workd = 4 if employ == 8	// student
		replace workd = 5 if employ == 6 | employ == 7 | employ == 9 // permanently disabled OR homemaker OR other
		replace workd = . if employ == .
	label variable work "Employment status"
	label values work work_lbl
	label define work_lbl ///
		1 "Temporarily laid off or unemployed" ///
		2 "Full-time or part-time" ///
		3 "Retired" ///
		4 "Student" ///
		5 "Permanently disabled, homemaker, other"
* union membership
	tab union, missing
	tab union, nol missing
		/* 67 missing observations */
	gen memberd = 1 if union == 1 | union == 2 // current union member or former union member
		replace memberd = 0 if union == 3 // never a union member
		replace memberd = . if union == .
	label variable memberd "Union membership (dummy)"
	label values memberd memberd_lbl
	label define memberd_lbl ///
		0 "Not a union member currently or formerly" ///
		1 "Currently or formerly a member of a labor union"
* home ownership
	tab ownhome, missing
	tab ownhome, nol missing
		/* 206 missing observations */
	gen homed = 1 if ownhome == 1
		replace homed = 0 if ownhome == 2 | ownhome == 3
		replace homed = . if ownhome == .
	label variable homed "Home ownership (dummy)"
	label values homed homed_lbl
	label define homed_lbl ///
		0 "Rent or other" ///
		1 "Home owner"

gen model_missing1 = missing(colleged, raced, mard, genderd, workd, memberd, homed)
gen model_missing2 = missing(colleged, raced, mard, genderd, workd)
gen homed_missing = missing(homed)
tab model_missing1 year, mi
tab model_missing2 year, mi
tab homed_missing year, mi
tab homed_missing model_missing1, mi
tab colleged year, mi
tab raced year, mi
tab mard year, mi
tab genderd year, mi
tab workd year, mi
tab memberd year, mi

* remove missing observations
keep if model_missing1 == 0

// Survey analysis specifications
svyset [pw = $weight], strata(state)

// Explanatory variable and covariates
local var disapproved
local cov i.colleged i.raced i.mard i.genderd i.workd i.memberd i.homed

cd "$output"
cls
// Model (2020): controls
svy: reg voted i.`var' i.age_bin i.`var'#i.age_bin `cov' if year == 2020
margins, dydx(`var') over(age_bin) post vce(unconditional)
translate @Results disapproval_2020.txt, replace
estimates store marginal_controls_2020
mat A = e(b)

cls
// Model (2018): controls
svy: reg voted i.`var' i.age_bin i.`var'#i.age_bin `cov' if year == 2018
margins, dydx(`var') over(age_bin) post vce(unconditional)
translate @Results disapproval_2018.txt, replace
estimates store marginal_controls_2018
mat B = e(b)

cls
// Model (2016): controls
svy: reg voted i.`var' i.age_bin i.`var'#i.age_bin `cov' if year == 2016
margins, dydx(`var') over(age_bin) post vce(unconditional)
translate @Results disapproval_2016.txt, replace
estimates store marginal_controls_2016
mat C = e(b)

cls
// Model (2014): controls
svy: reg voted i.`var' i.age_bin i.`var'#i.age_bin `cov' if year == 2014
margins, dydx(`var') over(age_bin) post vce(unconditional)
translate @Results disapproval_2014.txt, replace
estimates store marginal_controls_2014
mat D = e(b)

// Graph titles
local title "presidential disapproval"
local Title "presidential disapproval"

// Graph of marginal relationship between explanatory variable and voter turnout
* chart notes
linewrap, maxlength(155) name("notes") stack longstring("In this analysis, we define disapproval rates as the proportion of the weighted sample who strongly disapprove and disapprove/somewhat disapprove of the president, while excluding any respondent who has never heard/not sure or neither approve nor disapprove. Data weighted in Stata using probability weights and the weight cumulative variable. We define voter turnout based on the CCES-validated measure, such that non-voters encompass any respondent with no record of voting or no match to administrative records. We include controls for college graduation status, race/ethnicity, marital status, binary gender, work status, union membership, and home ownership")
local notes = `" "Notes: {fontface Lato:`r(notes1)'}""'
local y = r(nlines_notes)
forvalues i = 2/`y' {
	local notes = `"`notes' "{fontface Lato:`r(notes`i')'}""'
}
if `y' < 5 {
	local notes = `"`notes' """'
}
* labels
local label1 = A[1,5] + .003
display `label1'
local label2 = B[1,5] + .003
display `label2'
local label3 = C[1,5] + .003
display `label3'
local label4 = D[1,5] + .003
display `label4'
mylabels -10(5)15, local(ylab) myscale(@/100) suffix(" ppt")
* graph
coefplot ///
(marginal_controls_2020, offset(.26) msymbol(circle) ciopts(lcolor("0 165 152")) mcolor("0 165 152")) ///
(marginal_controls_2018, offset(.08) msymbol(circle) ciopts(lcolor("0 165 152")) mcolor("0 165 152")) ///
(marginal_controls_2016, offset(-.08) msymbol(circle) ciopts(lcolor("0 176 218")) mcolor("0 176 218")) ///
(marginal_controls_2014, offset(-.26) msymbol(circle) ciopts(lcolor("0 176 218")) mcolor("0 176 218")) ///
, ///
xline(1.5, lcolor(gs5%50) lpattern(dot)) ///
xline(2.5, lcolor(gs5%50) lpattern(dot)) ///
xline(3.5, lcolor(gs5%50) lpattern(dot)) ///
levels(95) ///
vertical ///
title("Is `Title' associated with voting?", color("0 50 98") size(medium) pos(11) justification(left) margin(l-11)) ///
subtitle("Marginal relationship (percentage points) between `title' and voter turnout", color("59 126 161") size(small) pos(11) justification(left) margin(l-11)) ///
yline(0, lcolor(gs10) lwidth(thin) lpattern(dash)) ///
xtitle("Age Group", color(gs6)) ///
xscale(lstyle(none)) ///
xlabel(, labcolor(gs6) tlcolor(gs6)) ///
yscale(lstyle(none)) ///
ylabel(-.10 "-10 ppt" -.05 "-5 ppt" 0 "0 ppt" .05 "+5 ppt" .10 "+10 ppt" .15 "+15 ppt", gmax gmin glcolor(gs9%15) glpattern(solid) labcolor(gs6) labsize(2.5) tlength(0) tlcolor(gs9%15)) ///
legend(off) ///
note("Source: {fontface Lato:Authors' analysis of Cumulative CCES Common Content, Harvard Dataverse, V7.}" "Sample: {fontface Lato:All citizens 18 years or older.}" ///
		`notes', color(gs7) span size(tiny) position(7)) ///
text(.002 .5 "Statistically Insignificant Relationship", color(gs10) size(vsmall) orientation(horizontal) place(ne) justification(left)) ///
text(`label1' 1.25 "Trump", color("0 165 152") size(vsmall) orientation(vertical) place(nw) justification(left)) ///
text(`label1' 1.325 "2020", color("0 165 152") size(vsmall) orientation(vertical) place(nw) justification(left)) ///
text(`label2' 1.07 "Trump", color("0 165 152") size(vsmall) orientation(vertical) place(nw) justification(left)) ///
text(`label2' 1.145 "2018", color("0 165 152") size(vsmall) orientation(vertical) place(nw) justification(left)) ///
text(`label3' .91 "Obama", color("0 176 218") size(vsmall) orientation(vertical) place(nw) justification(left)) ///
text(`label3' .985 "2016", color("0 176 218") size(vsmall) orientation(vertical) place(nw) justification(left)) ///
text(`label4' .73 "Obama", color("0 176 218") size(vsmall) orientation(vertical) place(nw) justification(left)) ///
text(`label4' .805 "2014", color("0 176 218") size(vsmall) orientation(vertical) place(nw) justification(left)) ///
graphregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
plotregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium))
* export graph
graph export `var'.png, replace height(2500) width(3700)