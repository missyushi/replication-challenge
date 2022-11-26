/* 
Version 1
	
	Merging Additional Data, Creating New Variables, etc.
														   Wednesday May 5, 2020
														   
Objective:

The point is to get rid of all the fluff at the beginnig of the analysis do-files
which have gotten out of hand and are actually slowing the computer down. 

So we'll make one fluff file, and save it as a .dta so we don't have to creat it
5000 times. 


1. Define the four economic outcomes and their conditions  

2. Define Variables of Interest 

3. Different Control Variables and Heterogeneity 
	- Version 2: UPDATED MARCH 4, 2021 
		TO INCLUDE DIFFERENT VARIABLE DEFINITONS 
		- AgeCats
		- Married
		- Weekly Earnings
		- Child Measures 
		- Above/below median indexes 
		- UnionXAge
		
	- Version 3: UPDATED MARCH 5, 2021 
		INCLUDES LABELLING VARIABLES FOR THE INDEXES 
		
4. Short-term variables 

5. A Summary of Most Conditions Which enter successive programs 
	- MARCH 4, 2021
		- Using the mainDataset_Prov_
		- AGE RESTRICTIONC ARE 15 - 64
		
6. March 8, 2021.
	- Women with kids/no kids 
	
7. March 30, 2021
	- Adding the correct CPI values 

VERSION 4
	- Adding the essential workers index 
	
	
*/

//
clear 

di "ADDITIONAL MEASURES BEING ADDED "

/* Time */
	timer on 7 
	
/* 
clear all 

args pathway 
cd "`pathway'"

clear all 
*/

local today = subinstr(c(current_date), " ", "", .)
di "`today'"


/*
 MARCH 4, 2020.
	- There are issues calling the files to download from Esha's Github
	Until changed, we will just use the do-file from 20Jan2021
	
// use "Covid-19 Canada\Data\dtaFiles\mainDataset_Prov_`today'.dta"	
*/

use "ReplicationFolder_CJE_Covid/Data/dtaFiles/lfs_2016Jan_to_2020december_checkedData.dta"

// Add the CPI 
merge m:1 K_prov K_year K_month using "ReplicationFolder_CJE_Covid/Data/dtaFiles/toBeMerged_allItemsCPI_Jan2018_Dec2020.dta"
drop if _merge == 2
drop _merge 

// Adding the Proximity Measures 
merge m:1 K_noc_40 using "ReplicationFolder_CJE_Covid/Data/dtaFiles/twoDigit_indices.dta"



/* 1. Define the four economic outcomes and their conditions  */ 

/* Individual Unemployment  */
	local  regConditions1 "if K_lfsstat != 3" // If you want only those in LF
	
	gen w_unemp = 0 + 1*(K_lfsstat == 4)
	label variable w_unemp "Unemployed"

	
/* Individual Labour Force Participation */ 
	local  regConditions2 "" // There are no conditions on LFP
	
	gen w_lfpartic = 0 + 1*(K_lfsstat != 3)
	label variable w_lfpartic "Labour For Participation"

	
/* Generate Indicators for top/bottom 1-percentile */
	summarize K_hrlyearn, detail 
	gen hourlyWage_p1top99 = 0 + 1*(inrange(K_hrlyearn, r(p1), r(p99)))
	
	summarize K_utothrs, detail 
	gen hoursOfWork_p1top99 = 0 + 1*(inrange(K_utothrs, r(p1), r(p99)))
	
	
/* Hourly Wage  */ 	
	local  regConditions3 "if K_age_12 <= 11 & K_cowmain <= 2 & K_lfsstat <= 2"
		
	
	
*** IMPORTANT! *** We are going to use the March CPI because the April one isn't out yet? 
	sort K_prov K_year K_month 
	order K_prov K_year K_month allItemsCPI_Jan2018
	by K_prov: replace allItemsCPI_Jan2018 = allItemsCPI_Jan2018[_n-1] if allItemsCPI_Jan2018 == . 
	
	
	
	
// Original hourly wages 
	gen hourlyWage_real = K_hrlyearn/(allItemsCPI_Jan2018)
	
	label variable hourlyWage_real "Real Hourly Wage"
	
	
// Giving the unemployed 0 dollars as income 
	gen alt_wages = hourlyWage_real
	replace alt_wages = 0 if hourlyWage_real == . 
	label variable alt_wages "Real Hourly Wage"
	
	
/* TOTAL Hours of Work */ 
	local  regConditions4 "if K_age_12 <= 11 & K_cowmain <= 2 & K_lfsstat <= 2"

	gen alt_hours = K_utothrs
	replace alt_hours = 0 if K_utothrs == . 
	
	label variable alt_hours "Total Usual Hours of Work"
	label variable K_utothrs "Total Usual Hours of Work"
	
	
/* Actual Hours of Work */ 
	gen alt_hours_actual = K_atothrs
	replace alt_hours_actual = 0 if K_atothrs == . 
	
	label variable alt_hours_actual "Total Actual Hours of Work"		
	
************
	
	
/* 2. Define Variables of Interest  */
	
	/* 2. Post Covid */ 
	gen postCovid = 0 
	replace postCovid = 1 if K_month >= 3 & K_year >= 2020
	
	label variable postCovid "Post COVID"
	label define post 0 "Pre COVID" 1 "Post COVID"
	label values postCovid post

	/* 2. Number of Cases and Number of Deaths 
	replace cumCasesPer10000_prov_15to64 = 0 if cumCasesPer10000_prov_15to64 == . 
	label variable cumCasesPer10000_prov_15to64  "Cases (per 10000)"

	gen casesSq = cumCasesPer10000_prov_15to64*cumCasesPer10000_prov_15to64
	label variable casesSq "Cases (per 10000) squared"	
	 */
	
************

	
/* 3. Different Control Variables and Heterogeneity */

	/* Marital Status */
	tab K_marstat	
	recode K_marstat (1/2 4/6 = 0 "Not Married") (3 = 1 "Married"), gen(bin_marstat)

	/* Age Groups */
	recode K_age_12 (1/4 = 1 "15 to 34") (5/8 = 2 "35 to 54") (9/12 =3 "55+"), gen(tern_ages)

	/* Self-Employed_Incorporated V Unincorporated */
	recode K_cowmain (1 2 7 = . )(5/6 = 0 "Self-employed, unincorporated") (3/4 = 1 "Self-employed, incorporated"), ///
		gen(selfEmp_AndIncorp)

	/* Immigrant Status */ 
	recode K_immig (3 = 0 "Not Immigrant") (1 2 = 1 "Immigrant"), gen(immigrant)

	/* Education */
	recode K_bestEducation (1 2 = 0 "Less than highschool") ( 3/4 = 1 "Highschool or some college") (5/7 = 2 "Postsecondary Accreditation"), gen(tern_bestEduc)

	/* Women with and without children */
	gen womanWithKids = .
	replace womanWithKids = 1 if K_sex == 2 & K_agyownk > 0 
	replace womanWithKids = 0 if K_sex == 2 & (K_agyownk == .)
	
	label define wwk 1 "Woman with Kids" 0 "Woman, no kids" 
	label values womanWithKids wwk

	/* rename the variables */
	rename (K_sex tern_ages bin_marstat immigrant K_ftptmain K_union selfEmp_AndIncorp tern_bestEduc K_immig K_schooln) ///
		(sex ageCats marStat immig ftpt union selfEmpIncorp Educ ysm_immig student)
		
// Generate Parents V non-Parents 
	gen parents = . 
	replace parents = 0 if K_agyownk == .
	replace parents = 1 if K_agyownk != . 
	
	label define pars 0 "Not parents" 1 "Parents"
	label values parents pars
	
// Generate Alternative for women with kids.
// ** Corrections made to this code (March 8 ,2021)
	tab K_agyownk, generate(kidGroups)

	gen women_kidsLessThan6 = .
	replace women_kidsLessThan6 = 0 if sex == 2 & K_agyownk == . & kidGroups1 != 1
	replace women_kidsLessThan6 = 1 if sex == 2 & kidGroups1 == 1
	
	label define wwk1 1 "Woman, kids under 6" 0 "Woman, no kids" 
	label values women_kidsLessThan6 wwk1
	
	gen women_kids6to12 = .
	replace women_kids6to12 = 0 if sex == 2 & K_agyownk == . & kidGroups2 != 1
	replace women_kids6to12 = 1 if sex == 2 & kidGroups2 == 1

	label define wwk2 1 "Woman, kids 7 to 12" 0 "Woman, no kids" 
	label values women_kids6to12 wwk2
	
	gen women_kids13to17 = .
	replace women_kids13to17 = 0 if sex == 2 & K_agyownk == . & kidGroups3 != 1
	replace women_kids13to17 = 1 if sex == 2 & kidGroups3 == 1

	label define wwk3 1 "Woman, kids 13 to 17" 0 "Woman, no kids" 
	label values women_kids13to17 wwk3
	
	gen women_kids18to24 = .
	replace women_kids18to24 = 0 if sex == 2 & K_agyownk == . & kidGroups4 != 1
	replace women_kids18to24 = 1 if sex == 2 & kidGroups4 == 1	
	
	label define wwk4 1 "Woman, kids 18 to 24" 0 "Woman, no kids" 
	label values women_kids18to24 wwk4
	
/* Generate new variable for wome with kids under the age of 13*/
	gen women_kidsUnder13 = . 
	replace women_kidsUnder13 = 0 if sex == 2 & inlist(K_agyownk,3,4)
	replace women_kidsUnder13 = 0 if sex == 2 & K_agyownk ==. 
	replace women_kidsUnder13 = 1 if sex == 2 &  K_agyownk == 1	
	replace women_kidsUnder13 = 1 if sex == 2 &  K_agyownk == 2	
	
	label define wwk5 1 "Woman, kids under 13" 0 "Woman, no kids or older kids" 
	label values women_kidsUnder13 wwk5
	
	
// For the weeklyEarningsGraphs 
	gen weekEarnQuart = . 	

	gen weeklyEarnings = alt_wages * alt_hours_actual if alt_wages != 0 

	summ weeklyEarnings, detail 

	replace weekEarnQuart = 1 if inrange(weeklyEarnings, r(p1), r(p25) ) & weeklyEarnings != 0 
	replace weekEarnQuart = 2 if inrange(weeklyEarnings, r(p25), r(p50) ) & weeklyEarnings != 0
	replace weekEarnQuart = 3 if inrange(weeklyEarnings, r(p50), r(p75) ) & weeklyEarnings != 0
	replace weekEarnQuart = 4 if inrange(weeklyEarnings, r(p75), r(p99) ) & weeklyEarnings != 0

	bysort weekEarnQuart: summ weeklyEarnings
		
	label define quart 1 "First Quartile" 2 "Second Quartile" 3 "Third Quartile" 4 "Fourth Quartile"
	label values weekEarnQuart quart


// Label Variables: Above/Below Median 
	label define aboveBelow 0 "Below Median" 1 "Above Median"
	label values median_proximity aboveBelow
	label values median_exposure aboveBelow 
	label values median_critNumber aboveBelow 
	label values median_HomeWork aboveBelow
	label values median_essWorker aboveBelow
	
// For the UnionXAge Graphs 
	clonevar othUnion = union
	label define othU 1 "Non-Unionized," 2 "Collective Agreement," 3 "Union"
	label values othUnion othU
	egen ageByUnion = group(othU ageCats), label 

	
	
/*
// FEBRUARY 26, 2021 - ALTERNATIVE AGE GROUPS 	
*/
	tab K_age_12
	tab K_age_12, nolab 
	// If K_age_12 < 12 or K_age_12 <= 10

/* 
* MARCH 5, 2021 - NEW MARRIAGE VARIABLE 
*/	
/* Generate female variable */
	recode sex (1 = 0 "Male") (2 = 1 "Female"), gen(female)

/* Label the variable for females */
	label variable female "Female"		

/* 
* MARCH 4, 2021 - NEW MARRIAGE VARIABLE 
*/
	tab K_marstat
	tab K_marstat, nolab
	
	label variable marStat "Married"	
	
	recode K_marstat (1 4 5 6 = 0 "Neither married nor common-law") ///
		(2/3 = 1 "Married or common-law") ///
		,	gen(marStat_2)
		
	label variable marStat_2 "Married or common-law"	
	
	
/* 
March 4, 2021 - Generate Age Group dummies 
*/ 
	recode K_age_12 (1/4 = 1 "15 - 34") (5/8 = 2 "35 - 54") (9 10 = 3 "55 - 64") ///
		(11 12 = .), gen(ageCats_alt)		
		
		
*************


// Reasons for leaving job?
gen unemp_losersIllness = 0 + 1*(K_whylefto == 1) + 1*(K_whylefto == 4) if K_whylefto != . 

// Related part-time absences, yaway
recode K_yaway (1=1 "Other Reasons") (2 = 2 "Own illness of Disability") ///
	(3/5 = 3 "Personal or Family Responsibility") (6/7 = 4 "Vacation or Civic Holidy") ///
	(8 = 5 "Working short-time"), gen(better_yaway)
		
// The categories are mutually exclusive
gen partWeekAbsence = 0 + 1*(better_yaway == 0) + 1*(better_yaway == 1) if better_yaway != . 
tab partWeekAbsence

// The categories are mutually exclusive
tab K_yabsent // , nolab
gen fullWeekAbsence = 0 +1*(K_yabsent == 0)+ 1*(K_yabsent == 1) if K_yabsent != . 
tab fullWeekAbsence


/* 
Version 3: March 5, 2021 
	- This cleans up definitions in March_analysis_summaryStatistics_v3
*/

/* Labeling Variables which might not have otherwise been labelled */
	label variable K_utothrs "Total Usual Hours of Work"
	
	label variable exposure_weightedIndex  "Exposure to Infection/Disease Index"
	label variable physProx_weightedIndex "Physical Proximity to Coworkers Index"
	label variable critNumber_weightedIndex "Critical Worker Index"
	label variable HomeWork_weightedIndex "Work from Home Index"
	label variable essWorker_weightedIndex "Essential Worker Index (LMiC)"
	
/*
Version 3: March 5, 2021 
	- Creating standardized variables for the indexes 
*/
/* Standardized Indices*/
	egen stdzd_PhysProx = std(physProx_weightedIndex)
	label variable stdzd_PhysProx "Physical Proximity (Standardized)"

	egen stdzd_Exposure = std(exposure_weightedIndex)
	label variable stdzd_Exposure "Exposure (Standardized)"

	egen stdzd_Critical = std(critNumber_weightedIndex)
	label variable stdzd_Critical "Critical Worker (Standardized)"

	egen stdzd_Homework = std(HomeWork_weightedIndex)
	label variable stdzd_Homework "Work from Home (Standardized)"
	
	egen stdzd_essWorker = std(essWorker_weightedIndex)
	label variable stdzd_essWorker "Essential Worker (Standardized)"

************


/* 5. What should go into most loops */
// What is varying in the loop
	local outcomes "w_unemp w_lfpartic alt_wages alt_hours"
	local varOfInt "postCovid cumCasesPer10000_prov_15to64"
	local x_het "sex marStat_2 ageCats_alt"
	local allControls "sex marStat_2 ageCats_alt Educ immig ysm_immig ftpt union selfEmpIncorp student"
	
	// Fixed Effects, Weights and Options
	local spec3 "i.(sex marStat_2 ageCats_alt Educ immig K_prov K_year K_month) i.K_year#i.K_prov" 
	local weights "[pw = K_finalwt]"
	local options ", vce(cluster K_prov)"
	
/* Just a reminder of the conditions that will be imposed on the regressions */
	local  regConditions1 "if (K_age_12 <= 10) & (K_lfsstat != 3)" // restricted age + in the labour force 
	local  regConditions2 "if (K_age_12 <= 10)" // restricted age 
	local  regConditions3 "if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)" // only observations we have $ for 
	local  regConditions4 "if (K_age_12 <= 10) & (K_lfsstat != 3) & (K_cowmain <= 2)" // only observations we have $ for
	
/* Save the dataset */ 
save "ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset.dta", replace

/* timer off */
	timer off 7
	timer list 
