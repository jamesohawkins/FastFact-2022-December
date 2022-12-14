cd "$raw_data"
use cumulative_2006-2021.dta, clear

// Weight
global weight weight_cumulative

// Years
keep if inlist(year, 2006, 2008, 2010, 2012, 2014, 2016, 2018, 2020)

// Top-code for age
replace age = 75 if age >= 75

// Presidential approval measure
keep if citizen == 1
gen approved = 1 if inlist(approval_pres, 1, 2)
replace approved = 0 if inlist(approval_pres, 3, 4)
drop if approved == . // drop individuals who do not strongly/somewhat approve or disapprove

// Regressions
reg approved age [pw = $weight] if year == 2006, vce(robust)
reg approved age [pw = $weight] if year == 2008, vce(robust)

// Calculate measure by age and year
collapse (mean) approved [pw = $weight], by(year age)
reshape wide approved, i(age) j(year)

// Regressions
forvalues yr = 2006(2)2020 {
	reg approved`yr' age, vce(robust)
	local approved`yr' = round(_b[age], .0001)
	display _b[_cons]
	local y`yr' = (_b[age] * 75) + _b[_cons]
	display `y`yr''
}
local y2014 = `y2014' + .004

// Visualization
* chart notes
linewrap, maxlength(155) name("notes") stack longstring("In this analysis, we define approval rates as the proportion of the weighted sample who strongly approve and approve/somewhat approve of the president, while excluding any respondent who has never heard/not sure or neither approve nor disapprove. Data weighted in Stata using probability weights and the weight cumulative variable.")
local notes = `" "Notes: {fontface Lato:`r(notes1)'}""'
local y = r(nlines_notes)
forvalues i = 2/`y' {
	local notes = `"`notes' "{fontface Lato:`r(notes`i')'}""'
}
if `y' < 5 {
	local notes = `"`notes' """'
}
cd "$output"
colorpalette hue, n(2) hue(0 50)
twoway (lfit approved2020 age, lpattern(dash) lcolor("`r(p1)'")) ///
(scatter approved2020 age, msymbol(circle) mcolor("`r(p1)'%25") mlcolor(white%0)) ///
(lfit approved2018 age, lpattern(solid) lcolor("`r(p2)'")) ///
(scatter approved2018 age, msymbol(circle) mcolor("`r(p2)'%25") mlcolor(white%0)) ///
, ///
scheme(plotplain) ///
subtitle("Trump", size(small) pos(12)) ///
xtitle(Age, size(small)) xscale(lcolor(gs10) lwidth(thin)) ///
xlabel(18 "18" 30 "30" 45 "45" 60 "60" 75 "75+", gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor(gs6) labsize(2.5) tlength(1) tlcolor(gs9%50)) ///
xtick(20(15)75, tlength(1) tlcolor(gs9%50)) ///
xmtick(20(5)75, ticks tlength(1) tlcolor(gs9%50)) ///
yscale(lstyle(none)) ///
ytitle("") ///
ylabel(.1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .6 "60%" .7 "70%" .8 "80%", gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor(gs6) labsize(2.5) tlength(0) tlcolor(gs9%15)) ///
legend(order(3 "2018" 1 "2020") pos(6) rows(1) bmargin(t-3)) ///
text(`y2020' 75 " `approved2020'", color("`r(p1)'") size(tiny) placement(n) justification(left) orient(horizontal)) ///
text(`y2018' 75 " `approved2018'", color("`r(p2)'") size(tiny) placement(n) justification(left) orient(horizontal)) ///
graphregion(margin(0 0 0 1) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
graphregion(margin(l r+3)) ///
plotregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
plotregion(margin(t+2))
graph save approved_trump.gph, replace

colorpalette hue, n(4) hue(150 300)
twoway (lfit approved2016 age, lpattern(shortdash) lcolor("`r(p1)'")) ///
(scatter approved2016 age, msymbol(circle) mcolor("`r(p1)'%25") mlcolor(white%0)) ///
(lfit approved2014 age, lpattern(solid) lcolor("`r(p2)'")) ///
(scatter approved2014 age, msymbol(circle) mcolor("`r(p2)'%25") mlcolor(white%0)) ///
(lfit approved2012 age, lpattern(shortdash) lcolor("`r(p3)'")) ///
(scatter approved2012 age, msymbol(circle) mcolor("`r(p3)'%25") mlcolor(white%0)) ///
(lfit approved2010 age, lpattern(solid) lcolor("`r(p4)'")) ///
(scatter approved2010 age, msymbol(circle) mcolor("`r(p4)'%25") mlcolor(white%0)) ///
, ///
scheme(plotplain) ///
subtitle("Obama", size(small) pos(12)) ///
xtitle(Age, size(small)) xscale(lcolor(gs10) lwidth(thin)) ///
xlabel(18 "18" 30 "30" 45 "45" 60 "60" 75 "75+", gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor(gs6) labsize(2.5) tlength(1) tlcolor(gs9%50)) ///
xtick(20(15)75, tlength(1) tlcolor(gs9%50)) ///
xmtick(20(5)75, ticks tlength(1) tlcolor(gs9%50)) ///
yscale(lstyle(none)) ///
ytitle("") ///
ylabel(.1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .6 "60%" .7 "70%" .8 "80%", gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor(gs6) labsize(2.5) tlength(0) tlcolor(gs9%15)) ///
legend(order(7 "2010" 5 "2012" 3 "2014" 1 "2016") pos(6) rows(1) bmargin(t-3)) ///
text(`y2016' 75 " `approved2016'", color("`r(p1)'") size(tiny) placement(s) justification(left) orient(horizontal)) ///
text(`y2014' 75 " `approved2014'", color("`r(p2)'") size(tiny) placement(n) justification(left) orient(horizontal)) ///
text(`y2012' 75 " `approved2012'", color("`r(p3)'") size(tiny) placement(s) justification(left) orient(horizontal)) ///
text(`y2010' 75 " `approved2010'", color("`r(p4)'") size(tiny) placement(s) justification(left) orient(horizontal)) ///
graphregion(margin(0 0 0 1) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
graphregion(margin(l r+3)) ///
plotregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
plotregion(margin(t+2))
graph save approved_obama.gph, replace

colorpalette hue, n(2) hue(0 50)
twoway (lfit approved2008 age, lpattern(dash) lcolor("`r(p1)'")) ///
(scatter approved2008 age, msymbol(circle) mcolor("`r(p1)'%25") mlcolor(white%0)) ///
(lfit approved2006 age, lpattern(solid) lcolor("`r(p2)'")) ///
(scatter approved2006 age, msymbol(circle) mcolor("`r(p2)'%25") mlcolor(white%0)) ///
, ///
scheme(plotplain) ///
subtitle("Bush", size(small) pos(12)) ///
xtitle(Age, size(small)) xscale(lcolor(gs10) lwidth(thin)) ///
xlabel(18 "18" 30 "30" 45 "45" 60 "60" 75 "75+", gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor(gs6) labsize(2.5) tlength(1) tlcolor(gs9%50)) ///
xtick(20(15)75, tlength(1) tlcolor(gs9%50)) ///
xmtick(20(5)75, ticks tlength(1) tlcolor(gs9%50)) ///
yscale(lstyle(none)) ///
ytitle("") ///
ylabel(.1 "10%" .2 "20%" .3 "30%" .4 "40%" .5 "50%" .6 "60%" .7 "70%" .8 "80%", gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor(gs6) labsize(2.5) tlength(0) tlcolor(gs9%15)) ///
legend(order(3 "2006" 1 "2008") pos(6) rows(1) bmargin(t-3)) ///
text(`y2008' 75 " `approved2008'", color("`r(p1)'") size(tiny) placement(n) justification(left) orient(horizontal)) ///
text(`y2006' 75 " `approved2006'", color("`r(p2)'") size(tiny) placement(n) justification(left) orient(horizontal)) ///
graphregion(margin(0 0 0 1) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
graphregion(margin(l r+3)) ///
plotregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
plotregion(margin(t+2))
graph save approved_bush.gph, replace

graph combine approved_bush.gph approved_obama.gph approved_trump.gph, ycommon col(3) ///
title("How has presidential approval varied by age?", color("0 50 98") size(medium) pos(11) justification(left)) ///
subtitle("Presidential approval", color("59 126 161") size(small) pos(11) justification(left)) ///
note("Source: {fontface Lato:Authors' analysis of Cumulative CCES Common Content, Harvard Dataverse, V7.}" ///
`notes', color(gs7) span size(tiny) position(7)) ///
graphregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
plotregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
graphregion(margin(0))
graph export presidential_approval.png, replace