/*
	Checking the Appending Worked Well. 
	
	First Pass: 
		- April 2, 2020. 
			Start: 1230
			End: April 3, 17:30
		
	
	Objective:
		- Check that the variables are correctly named and uniformly constructed. 
		- Get sociodemographic variables and economic information by province and
			CMA. 
	
	
	Initial Comments:
		- The initial dataset is ordered (rows) backwards: 2020 ->(desecending) 2016
			**** This was changed later. 
		- In 2016 (row == 3, 866,134), we have more columns (starting from yaway)
		
		
	Final Comments: 
		- May 2016 was coded as being the 6th month. This exception was captured
			in the previous do-file.
			
		- I Have assumed that Ottawa and Ottawa-Gatineau (Ontario side) are both Ottawa.
		
		- variables with the word "best" (bestEducation or bestNaics_18) in them 
			indicate they are a summation across different variables which 
			capture the same thing in different times. 
			
		- Information about Spouses is only contained in 2016
		
		- NAICS, we have to make the following aggregations for a consistent variables:
			2016 aggregates Forest, fishing and mining where as 2017 - 2020 have them separate.
			2016 aggregates finance with real estate where as 2017 - 2020 have them separate. 
			
		- NOC is not provided for 2016. This is in agreement with odesi's documentation. 
		
		
	LEGEND FOR PREFIXES
		E_ := encoded variables
		D_ := decoded variables 
		
		beta* := indicates an intermediate variable		
		C_ := constructed variables 

		K_ := variables which are to be kept 
		
*/

// clear all 
clear  

/* Open the appended file */ 
use "ReplicationFolder_CJE_Covid/Data/dtaFiles/lfs_2016jan_to_2020december.dta"

// How many observations are we dealing with?
count 

********************************************************************************
/*
OUTLINE

	I've now appended everything into one dataset. Stata's Append merges based 
		on some weird algorithm of labels which can be different across different 
		years, months, values of variables in each LFS. 
	
	How I've Decided To Get Around The Above Problem:
	
	Part *1. Construct variable values which are the value labels from the
			respective month/year of the lfs (THIS WAS DONE IN THE PREVIOUS FILE)
			
			- These are namely those variables that are prefixed with D_*
			
	Part 2. We are going to ENCODE all of the CATEGORIES for every variable with 
			a "D_*" prefix.
				
			- NOTE! This doesn't include continuous variables. 
			
	Part 3. We are then going to inspect those variables we care about and construct
			our own definitions of the variables. 
*/

********************************************************************************
/* OUTLINE Part 1. - Done in LFS_append */


********************************************************************************
/* OUTLINE Part 2. - Encode all variables with D_* prefix */

ds D_* 

display "`r(varlist)'"

capture: confirm file "ReplicationFolder_CJE_Covid/Data/dtaFiles/lfs_2016Jan_to_2020december_withE.dta"

if (_rc != 0){
	foreach x in `r(varlist)'{
		di `x'
		quietly local varname = substr("`x'", 3,. )
		quietly encode `x', gen( E_`varname')
	}

	save "ReplicationFolder_CJE_Covid/Data/dtaFiles/lfs_2016Jan_to_2020december_withE.dta"
}
else{
    display "The variables with E prefix (Dataset) has already been created."
}

********************************************************************************
/* OUTLINE Part 3. - Inspect those variables that we care about */

capture: confirm file "ReplicationFolder_CJE_Covid/Data/dtaFiles/lfs_2016Jan_to_2020december_checkedData.dta"

if (_rc != 0){

	clear 

	/* timer */
		timer on 5
	
	/* Change directory to the correct folder*/
	use "ReplicationFolder_CJE_Covid/Data/dtaFiles/lfs_2016Jan_to_2020december_withE.dta"

	// The below is only temporary to make things faster. 
	// keep E*

	/*
		Variables that we care about and that are categorical: 
		
		Identifiers:
			- survyear
			- surmonth
			- prov
			- cma
		
		Demographic:
			- age
			- sex
			- education 
			- marital status		
			- spouse questions
			- family questions
			
		Labour 
			- Labour Force Status
			- Labour Force Participation
			- Unemployment Status
			- Usual Hours Worked
			- Actual Hours Worked 
			- Immigration Status
			- Flows into unemployment 
	*/

	********************************************************************************

	local correctListOfVariables ""

	/* survey year */
	tab survyear, m  



	********************************************************************************
	/* survyear is correctly coded */
	local correctListOfVariables `correctListOfVariables' "survyear"


	********************************************************************************
	/* survey month */
	tab survmnth, m

	/*

	May 2016 is coded incorrectly in the lfs from Odesi. This was corrected in 
	in the previous file as an exception, in the innermost loop.

	survmnth is correctly coded.

	*/
	local correctListOfVariables `correctListOfVariables' "survmnth"



	********************************************************************************
	/* province */
	tab E_prov, nolab m
	tab prov, nolab

	/* 
	The numerical value is always the same for Quebec - (24) independent of the correct. 
	prov variable is correctly codded. 
	*/
	local correctListOfVariables `correctListOfVariables' "prov"



	********************************************************************************
	/* cma */
	tab E_cma, m
	tab E_cma, nolab m 
	tab cma, m


	/* Unicode has completely messed everything up. A quick clean will help */
	replace E_cma = 7 if E_cma == 5 | E_cma == 6
	replace E_cma = 9 if E_cma == 8
	replace E_cma = 13 if E_cma == 12
	/*

	cma is NOT correctly coded. We will construct a new variable called
	C_cma (Corrected) which will recode the E_cma into the correct categories. 

	* I Have assumed that Ottawa and Ottawa-Gatineau (Ontario side) are both Ottawa. 
	* 2016 is a weird year and only has the three largest CMAs 

	*/

	recode E_cma (4 = 100 "Other CMA or non-CMA") (1 = 102 "Montreal") ///
		(2 = 104 "Toronto") (3 = 109 "Vancouver") (missing = .) ///
		if survyear == 2016, gen(betaCma_1)
		
	tab betaCma_1

		
	recode betaCma_1 (100 = 0 "Other CMA or non-CMA") (102 = 462 "Montreal") ///
		(104 = 535 "Toronto") (109 = 933 "Vancouver") (missing = .), gen(C_cma_1)	
			
	label variable C_cma_1 "Nine Largest Census Metropolitan Areas (CMAs)"	
			
	tab C_cma_1, m


		
	/* THIS WORKS */
	recode E_cma (1 8 9 = 100 "Other CMA or non-CMA") (12 13 = 101 "Quebec City") (5 6 7 = 102 "Montreal") ///
		///
		(10 11 = 103 "Ottawa") (14 = 104 "Toronto") (4 = 105 "Hamilton") (16 = 106 "Winnipeg") ///
		///
		(2 = 107 "Calgary") (3 = 109 "Edmonton") (15 = 109 "Vancouver") (missing = .) ///
		if survyear > 2016, gen(betaCma_2)

		
	recode betaCma_2 (100 = 0 "Other CMA or non-CMA") (101 = 421 "Quebec City") (102 = 462 "Montreal") ///
		///
		(103 = 505 "Ottawa") (104 = 535 "Toronto") (105 = 537 "Hamilton") (106 = 602 "Winnipeg") ///
		///
		(107 = 825 "Calgary") (108 = 832 "Edmonton") (109 = 933 "Vancouver") (missing = .), gen(C_cma_2)	
		
		
	label variable C_cma_2 "Nine Largest Census Metropolitan Areas (CMAs)"	
		
	tab C_cma_2, m 
	tab C_cma_2, nolab

	gen C_cma = C_cma_2 
	/* This looks good! One can verify that this composition is similar to a given month of the LFS*/
	local correctListOfVariables `correctListOfVariables' "C_cma"




	** CHECK! **

	/* How are we doing ? */
	foreach x of loc correctListOfVariables{
		display "`x'"
	}


	********************************************************************************
	/* age */ 
	tab E_age_12, m 
	tab E_age_6, m

	/*

	 Both of the above are coded INCORRECTLY. Same process as the cma. 
	 
	*/
	tab E_age_12, nolab m
	recode E_age_12 (1 2 = 1 "15 to 19") (3 4 = 2 "20 to 24") (5 6 = 3 "25 to 29") ///
		///
		( 7 8 = 4 "30 to 34") (9 10 = 5 "35 to 39")  (11 12 = 6 "40 to 44") (13 14 = 7 "45 to 49" ) ///
		///
		(15 16 = 8 "50 to 54") (17 18 = 9 "55 to 59") (19 20 = 10 "60 to 64") (21 22 = 11 "65 to 69") ///
		///
		(23 24 = 12 "70+") (missing = .) , gen(C_age_12) 
		
	label variable C_age_12 "Five-year age group of respondent"

	tab C_age_12, m 	
	local correctListOfVariables `correctListOfVariables' "C_age_12"


	tab E_age_6, nolab m 
	recode E_age_6 (1 2 = 1 "15 to 16") (3 4 = 2 "17 to 19") (5 6 = 3 "20 to 21") ///
		/// 
		(7 8 = 4 "22 to 24") (9 10 = 5 "25 to 26") (11 12 = 6 "27 to 29") ///
		///
		(missing = .), gen(C_age_6) 

	label variable C_age_6 "Age in 2 and 3 year groups, 15 to 29"	
		
	tab C_age_6, nolab m 
	local correctListOfVariables `correctListOfVariables' "C_age_6"


	********************************************************************************
	/* sex */
	tab E_sex, m
	tab sex, m 

	/* Both are correctly constructed*/
	local correctListOfVariables `correctListOfVariables' "sex"


	********************************************************************************
	/* education */
	tab E_schooln, m
	/*
		This is not correctly coded, as one can see. 
		Are there any patterns? 
	*/
	bysort survyear: tab E_schooln
	/*
	2017 - 2020 are coded as full-time, part-time, or non-student
	2016 has many different categories which will be mapped as follows:

		Full-Time: anything with full-time or FT
		Part-Time: anything with part-time or PT
		non-student: anything not in the above two.
	*/
	tab E_schooln, m 
	tab E_schooln, nolab m

	recode E_schooln ( 1 3/6 8 14 16 = 101 "Full-time student") ( 2 9/13 15 17= 103 "Part-time Student") ///
		( 7 = 102 "Non-student") (missing = .) ,gen(betaSchooln)
		
	recode betaSchooln ( 101 = 1 "Full-time student") ( 102 = 2 "Non-student") ///
		( 103 = 3 "Part-time Student") (missing = .), gen(C_schooln)
		
	label variable C_schooln "Current student status"

	tab C_schooln, m
	tab schooln, m 

	/* This looks good*/
	local correctListOfVariables `correctListOfVariables' "C_schooln"




	********************************************************************************
	/* Respondent's Eduation */ 
	tab E_educ, m 
	tab E_educ, nolab m 

	recode E_educ (1 = 101 "0 to 8 years") (8 = 102 "Some highschool") (5 = 103 "Highschool graduate") ///
		///
		(9 = 104 "Some postsecondary") (6 7 = 105 "Postsecondary certificate or diploma") ///
		///
		(4 = 106 "Bachelor's") (2 3 = 107 "Above bachelor's") (missing = .) ///
		///
		, gen(betaEduc)
		
		
	recode betaEduc (101 = 1 "0 to 8 years") (102 = 2 "Some highschool") (103 = 3 "Highschool graduate") ///
		///
		(104 = 4 "Some postsecondary") (105 = 5 "Postsecondary certificate or diploma") ///
		///
		(106 = 6 "Bachelor's") (107 = 7 "Above bachelor's") (missing = .) ///
		///
		, gen(C_educ)

	label variable C_educ "Highest educational attainment"	

	tab C_educ, m 

	/* This looks good*/
	local correctListOfVariables `correctListOfVariables' "c_educ"



	********************************************************************************
	tab E_educ90, m 

	/*
		NOTE! This is for 2016 data. Therefore, we will have to add the above variable with
		this variable in order to get the correct education for the whole popultion
		
		NOTE! 
		I am assuming that 11 to 13, grad means "Highschool graduate"
	*/

	recode E_educ90 (1 = 101 "0 to 8 years") (5 = 102 "Some highschool") (2 = 103 "Highschool graduate") ///
		///
		(4 = 104 "Some postsecondary") (3 = 105 "Postsecondary certificate or diploma") ///
		///
		(6 = 106 "Bachelor's") (7 = 107 "Above bachelor's") (missing = .) ///
		///
		, gen(betaEduc90)
		

	recode betaEduc90 (101 = 1 "0 to 8 years") (102 = 2 "Some highschool") (103 = 3 "Highschool graduate") ///
		///
		(104 = 4 "Some postsecondary") (105 = 5 "Postsecondary certificate or diploma") ///
		///
		(106 = 6 "Bachelor's") (107 = 7 "Above bachelor's") (missing = .) ///
		///
		, gen(C_educ90)

	label variable C_educ90 "Highest educational attainment (1990 -)"	

	tab C_educ90, m 
	tab C_educ90

	/* This looks good*/
	local correctListOfVariables `correctListOfVariables' "c_educ90"



	********************************************************************************
	** We will add the two education variables together to make a single one. 
	gen bestEducation = .
	replace bestEducation = C_educ 
	replace bestEducation = C_educ90 if bestEducation == .

	tab bestEducation

	label variable bestEducation "Highest educational attainment for all LFS"

	label define bestEd 1 "0 to 8 years" 2 "Some highschool" 3 "Highschool graduate" ///
		4 "Some postsecondary" 5 "Postsecondary certificate or diploma" ///
		6 "Bachelor's" 7 "Above bachelor's"
		
	label values bestEducation bestEd

	tab bestEducation

	/* This looks good*/
	local correctListOfVariables `correctListOfVariables' "bestEducation"



	********************************************************************************
	/* Spouse's Education */
	rename E_sped1990 E_sp_educ90
	tab E_sp_educ90, m 
	tab E_sp_educ90, m nolab

	recode E_sp_educ90 (1 2 = 101 "0 to 8 years") (6 = 102 "Some highschool") (3 = 103 "Highschool graduate") ///
		///
		(5 = 104 "Some postsecondary") (4 = 105 "Postsecondary certificate or diploma") ///
		///
		(7 = 106 "University Degree") (missing = .) ///
		///
		, gen(betasp_educ90)
		
		
	recode betasp_educ90 (101 = 1 "0 to 8 years") (102 = 2 "Some highschool") (103 = 3 "Highschool graduate") ///
		///
		(104 = 4 "Some postsecondary") (105 = 5 "Postsecondary certificate or diploma") ///
		///
		(106 = 6 "University Degree") (missing = .) ///
		///
		, gen(C_sp_educ90)

	label variable C_sp_educ90 "Spouse education (1990 -)"	

	tab C_sp_educ90, m

	/* It appears as if we only have spouse education for 2016, confirmed by the line below */
	bysort survyear: tab C_sp_educ90, m
	local correctListOfVariables `correctListOfVariables' "C_sp_educ90"



	********************************************************************************
	/* marital status */
	tab E_marstat 
	tab E_marstat, nolab m

	recode E_marstat (1 = 1 "Divored") (2 = 2 "Living in Common-law") ///
		(3 = 3 "Married") (4 = 4 "Separated") (5 6 = 5 "Single, never married") ///
		(7 = 6 "Widowed") (missing = .), gen(C_marstat) 
		
	tab C_marstat, m
	tab marstat, m 

	label variable C_marstat "Marital status of respondent"

	local correctListOfVariables `correctListOfVariables' "C_marstat"

	/* 
	Spouse Questions

	Correctly coded and indistinguishable across variable names,
		HOWEVER, it only appears in LFS for 2016 and no other times. 
		
		/* Spouse's Age */
		bysort srvyear: tab E_sp_age
		gen C_sp_age = E_sp_age 

		/* Spouse's Labour Force Status */
		bysort survyear: tab E_sp_lfsst

		/* Spouse Occupation */
		bysort survyear: tab sp_soc80
		/* Note, this doesn't even appear to have any values */
		
		/* Usual Hours of Work, Main */
		bysort survyear: tab sp_uhrsm 
		/* Only for 2016 */
		
		/* Usual Hours of Work, All Jobs */
		bysort survyear: tab sp_uhrst
		/* Only for 2016 */	
	*/


	/* Immigration Status */
	tab E_immig, m nolab

	recode E_immig (1 3 = 1 "Immigration =< 10 years ago") ( 2 4 = 2 "Immigration > 10 years ago") ///
		(5 = 3 "Non-immigrant") (missing = .), gen(C_immig)
		
	label var C_immig "Immigration status"

	tab C_immig, m
	tab immig, m

	/* Looks good */
	local correctListOfVariables `correctListOfVariables' "C_immig"

	/* How are we doing ? */
	foreach x of loc correctListOfVariables{
		display "`x'"
	}



	********************************************************************************
	/* Labour Force Status */
	tab E_lfsstat, m
	tab E_lfsstat, m nolab
	bysort survyear: tab E_lfsstat, nolab

	recode E_lfsstat (1 3 = 1 "Employed, absent from work") (2 4 = 2 "Employed, at work") ///
		(5 = 3 "Not in labour force") (6/9 = 4 "Unemployed") (missing = .), gen(C_lfsstat)
		
	label variable C_lfsstat "Labour force status"

	tab C_lfsstat, m 
	tab lfsstat, m

	/* Looks good */
	local correctListOfVariables `correctListOfVariables' "C_lfsstat"


	********************************************************************************
	/* Unemployment Status */
	bysort survyear: tab E_union, nolab
	bysort survmnth: tab E_union if survyear == 2016

	recode E_union (4 5 7 = 101 "Non-unionized") (1 2 6 8 = 102 "Not a member, covered by collective aggrement") ///
		(3 9 = 103 "Union Member") (missing = .), gen(betaUnion)
		
	recode betaUnion (101 = 1 "Non-unionized") (102 = 2 "Not a member, covered by collective aggrement") ///
		(103 = 3 "Union Member") (missing = .), gen(C_union)
		
	tab C_union, m 
	tab union, m

	/* Looks good */
	local correctListOfVariables `correctListOfVariables' "C_union"



	********************************************************************************
	/* Class of Worker */
	tab E_cowmain
	bysort survyear: tab E_cowmain, m nolab

	recode E_cowmain (1 8 9 = 101 "Private Sector Employee") (2 10 11 = 102 "Public Sector Employee") ///
		(3 12 17 = 103 "Self Employed, incorp, no paid") (4 13 18 = 104 "Self Employed, incorp, w paid") ///
		(5 14 16 = 105 "Self Employed, unincorp, no paid") (6 15 19= 106 "Self Employed, unincorp, w paid") ///
		(7 20 = 107 "Unpaid family work") (missing =.) , gen(betaCowmain)
		
	recode betaCowmain (101 = 1 "Private Sector Employee") (102 = 2 "Public Sector Employee") ///
		(103 = 3 "Self Employed, incorp, no paid") (104 = 4 "Self Employed, incorp, w paid") ///
		(105 = 5 "Self Employed, unincorp, no paid") (106 = 6 "Self Employed, unincorp, w paid") ///
		(107 = 7 "Unpaid family work") (missing =.) , gen(C_cowmain)
		
	label variable C_cowmain "Class of worker, main job"
		
	tab C_cowmain, m 
	tab cowmain, m 

	/* Looks good */
	local correctListOfVariables `correctListOfVariables' "C_cowmain"
		

	********************************************************************************
	/* Multiple Job Holders */
		
	tab E_mjh
	bysort survyear: tab E_mjh, m	
	bysort survyear: tab E_mjh, m nolab
		
	recode E_mjh (1 3 4 = 1 "Multiple jobholder") (2 5 6 7 = 2 "Single jobholder, including job changer") ///
			(missing = .), gen(C_multipleJobs)
			
	label var C_multipleJobs "Single or multiple jobholder"		
			
	tab C_multipleJobs, m
	tab mjh, m

	/* Looks good */
	local correctListOfVariables `correctListOfVariables' "C_multipleJobs"


	********************************************************************************
	/* 
	Usual Hours Worked main and Usual Hours Worked All

	Actual Hours Worked Main and ACtual Hours Worked All

	tenure 

		- are continuous 
	*/
	tab ahrsmain, m 
	tab atothrs, m
	tab uhrsmain, m 
	tab utothrs, m 
	tab tenure, m 

	/* Looks good */
	local correctListOfVariables `correctListOfVariables' "ahrsmain atothrs uhrsmain utothrs tenure"



	********************************************************************************
	/*
	 Hourly Earnings are also well-defined 
	*/

	tab hrlyearn, m 

	/* Looks good */
	local correctListOfVariables `correctListOfVariables' "hrlyearn"



	/* How are we doing ? */
	foreach x of loc correctListOfVariables{
		display "`x'"
	}



	********************************************************************************
	/* Firm Size */
	tab E_firmsize, m 
	tab E_firmsize, m nolab

	recode E_firmsize (7 11 13 14 = 101 "Less than 20") ( 4/6 10 = 102 "20 to 99") ///
		(1/3 9 = 103 "100 to 500") ( 8 12 15 16 = 104 "Greater than 500" ) (missing = .) ///
		, gen(betaFirmsize) 
		
	recode betaFirmsize (101 = 1 "Less than 20") ( 102 = 2 "20 to 99") ///
		(103 = 3 "100 to 500") ( 104 = 4 "Greater than 500") (missing = .), gen(C_firmsize)

	label variable C_firmsize "Firm Size"

	tab C_firmsize, m 
	tab firmsize, m 

	/* Looks good */
	local correctListOfVariables `correctListOfVariables' "C_firmsize"



	********************************************************************************
	/* Establishment Size */
	bysort survyear: tab E_estsize, m 
	tab E_estsize, m 
	tab E_estsize, m nolab

	recode E_estsize (7 11 13 14 = 101 "Less than 20") ( 4/6 10 = 102 "20 to 99") ///
		(1/3 9 = 103 "100 to 500") ( 8 12 15 16 = 104 "Greater than 500" ) (missing = .) ///
		, gen(betaestsize) 
		
	recode betaestsize (101 = 1 "Less than 20") ( 102 = 2 "20 to 99") ///
		(103 = 3 "100 to 500") ( 104 = 4 "Greater than 500") (missing = .), gen(C_estsize)

	label variable C_estsize "Establishment Size"

	tab C_estsize, m 
	tab estsize, m 

	/* Looks good */
	local correctListOfVariables `correctListOfVariables' "C_estsize"


	********************************************************************************
	/* Family Questions */
	tab E_efamtype, m 
	bysort survyear: tab E_efamtype, m 

	// Looked this one up across the years, they are consistent. 
	// And things correctly sum. 

	/* Looks good */
	local correctListOfVariables `correctListOfVariables' "efamtype"


	********************************************************************************
	/* NAICS */
	tab naics_21
	tab E_naics_21, m

	/*
	Things correctly sum across groups and exist for all observations.
	HOWEVER! This is only good for 2017 - 2020. We need to add them correctly to 2016. 

	Moreover, the 2016 version only has 18 groups.

	The variable called " naics_18 "  gives the correct naics categories, but are incorrectly labelled. 
	This was verified on odesi's portal. 

	We will aggregate the 2017 - 2020 up to the same as that of the 2016 variables.
	*/
	bysort survyear: tab naics_18
	tab naics_18 if survyear == 2016, m nolabel
	tab naics_21, m 


	/*
	2016 aggregates Forest, fishing and mining where as 2017 - 2020 have them separate.
	2016 aggregates finance with real estate where as 2017 - 2020 have them separate. 
	*/

	recode naics_21 (2 3 4 = 2 "Forest/Fish/Mine + Oil&Gas") (12 13 = 12 "Finance / Real Estate") ///
		, gen(betaNaics_21)

	tab betaNaics_21, nolab

	forval i = 5/12{
		replace betaNaics_21 = `i'-2 if betaNaics_21 == `i'
	}

	tab betaNaics_21, nolab

	forval i = 14/21{
		replace betaNaics_21 = `i'-3 if betaNaics_21 == `i'
	}

	tab betaNaics_21, nolab

	clonevar betaNaics_18 = betaNaics_21

	tab betaNaics_18, nolab

	tab naics_18
	tab naics_18, nolab

	gen bestNaics_18 = .
	replace bestNaics_18 = naics_18
	replace bestNaics_18 = betaNaics_18 if bestNaics_18 == . 

	tab bestNaics_18 

	label define naics18 ///
		1 "Agriculture" 2 "Forest/Fish/Mine/Oil&Gas" 3 "Utilities" 4 "Construction"	///
		5 "Manufacture-durables"	///
		6 "Manufact non-durables"	///
		7 "Wholesale Trade"	///
		8 "Retail Trade" ///
		9 "Transport/Warehousing" ///
		10 "Finance/Insur/R.Estate&Lea"	///
		11 "Prof/Scient/Technical"	///
		12 "Mngmnt/Admin/Other Support" ///
		13 "Educational Services"	///
		14 "Health Care/Soc Assist" ///
		15 "Info/Culture/Rec" ///
		16 "Accomm/Food Services" ///
		17 "Other Services" ///
		18 "Public Administration" 
		
	label values bestNaics_18 naics18

	tab bestNaics_18, m 
	bysort survyear: tab bestNaics_18, m

		/* looks good! */
	local correctListOfVariables `correctListOfVariables' "bestNaics_18"

	********************************************************************************
	/* Occupation 

	NOTE! 2016 doesn't have occupational codes. 
	*/
	tab noc_10
	tab noc_10 if survyear == 2016

	tab E_noc_10, m 
	tab E_noc_10, m nolab

	bysort survyear: tab E_noc_10, m 

	bysort survmnth: tab E_noc_10 if survyear == 2017, m 
	/* January of 2017 is incorrectly coded as seen by the below without labels*/
	bysort survmnth: tab E_noc_10 if survyear == 2017, m nolab

	recode E_noc_10 (6 = 16) (7 = 1) (8 = 17) (9 = 2) (10 = 3) ///
		(11 = 18) (12 = 4) (13 = 19) (14 = 5) (15 = 20), gen(C_noc_10)

	tab C_noc_10

	forval i = 16/20{
		replace C_noc_10 = `i'-10 if C_noc_10 == `i'
	}

	tab C_noc_10

		label define noc10 ///
	1 "Business, finance and administration oc" ///
	2 "Health occupations" ///
	3 "Management occupations" ///
	4 "Natural and applied sciences and relate" /// 
	5 "Natural resources, agriculture and rela" ///
	6 "Occupations in art, culture, recreation" ///
	7 "Occupations in education, law and socia" /// 
	8 "Occupations in manufacturing and utili" ///
	9 "Sales and service occupations" ///
	10 "Trades, transport and equipment operato" ///


	label values C_noc_10 noc10

	tab C_noc_10

		/* look good! */
	local correctListOfVariables `correctListOfVariables' "C_noc_10"

	********************************************************************************
	/* Full-time / Part-time */
	tab ftptmain
	tab E_ftptmain 

	/* They are both the same and therefore correctly coded */
	local correctListOfVariables `correctListOfVariables' "E_ftptmain"


	/* How are we doing ? */
	foreach x of loc correctListOfVariables{
		display "`x'"
	}


	/* 
	NOC_40 are coded the same across the LFS surveys. We just need to replace them
	with the correct labels. 
	*/ 

label define NOC40 ///
1 "Senior management occupations" ///
2 "Specialized middle management occupatio"  ///
3 "Middle management occupations in retail"  ///
4 "Middle management occupations in trades"  ///
5 "Professional occupations in business an"  ///
6 "Administrative and financial supervisor"  ///
7 "Finance, insurance and related business" ///
8 "Office support occupations" ///
9 "Distribution, tracking and scheduling c"  ///
10 "Professional occupations in natural and"  ///
11 "Technical occupations related to natura" ///
12 "Professional occupations in nursing"  ///
13 "Professional occupations in health (exc" ///
14 "Technical occupations in health"  ///
15 "Assisting occupations in support of hea"  ///
16 "Professional occupations in education s"  ///
17 "Professional occupations in law and soc"  ///
18 "Paraprofessional occupations in legal,"   ///
19 "Occupations in front-line public protec"  ///
20 "Care providers and educational, legal a"  ///
21 "Professional occupations in art and cul"  ///
22 "Technical occupations in art, culture,"   ///
23 "Retail sales supervisors and specialize"  ///
24 "Service supervisors and specialized ser"  ///
25 "Sales representatives and salespersons"   ///
26 "Service representatives and other custo"  ///
27 "Sales support occupations"  ///
28 "Service support and other service occup"  ///
29 "Industrial, electrical and construction"  ///
30 "Maintenance and equipment operation tra" ///
31 "Other installers, repairers and service"  ///
32 "Transport and heavy equipment operation"  ///
33 "Trades helpers, construction labourers"  ///
34 "Supervisors and technical occupations i"  ///
35 "Workers in natural resources, agricultu" ///
36 "Harvesting, landscaping and natural res" ///
37 "Processing, manufacturing and utilities"  ///
38 "Processing and manufacturing machine op" ///
39 "Assemblers in manufacturing" ///
40 "Labourers in processing, manufacturing "  ///


label values noc_40 NOC40 

gen C_noc_40 = noc_40

label values C_noc_40 NOC40 

/* They are both the same and therefore correctly coded */
local correctListOfVariables `correctListOfVariables' "c_noc_40"


/* Flows into unemployment */
bysort survyear survmnth: tab flowunem
bysort survyear survmnth: tab E_flowunem
/* As one can verify, they are coded the same across time */ 

rename flowunem C_flowUnem

local correctListOfVariables `correctListOfVariables' "C_flowUnem"

/* Why part-time? */
bysort survyear survmnth: tab E_whypt // ONLY LOOKS GOOD FROM 2017 onwards LEGITIMATELY, there was no variable before 2017 
rename E_whypt C_whypt
local correctListOfVariables `correctListOfVariables' "C_whypt"

/* Why part-week absence? */
bysort survyear survmnth: tab E_yaway // ONLY LOOKS GOOD FROM 2017 onwards LEGITIMATELY, there was no variable before 2017 
rename E_yaway C_yaway
local correctListOfVariables `correctListOfVariables' "C_yaway"

/* Why full week absence? */
// yabsent looks good  


/* Reasons for leaving job during previous year */
bysort survyear survmnth: tab whylefto 
bysort survyear survmnth: tab whylefto 
rename whylefto C_whylefto // Statistics Canada linked this pre and post 

local correctListOfVariables `correctListOfVariables' "C_whylefto"

/* duration joblessness / unemployed */ 
rename (durjless durunemp) (C_durjless C_durunemp)
local correctListOfVariables `correctListOfVariables' "C_durjless C_durunemp"

/* Weights */
replace finalwt = fweight if finalwt == .
replace fweight = finalwt if fweight == .
count if finalwt != fweight

break 

clonevar yongage = agyownk 
replace agyownk = 1*(agyownkn==1 | agyownkn==2) + 2*(agyownkn==3) + 3*(agyownkn==4 | agyownkn==5) + 4*(agyownkn ==6) if survyear == 2016 & agyownk ==. & agyownkn != .

label define kids 0 "Zero or sysmiss" 1 "Youngest child less than 6 years" 2 "Youngest child 6 to 12 years" 3 "	Youngest child 13 to 17 years" 4 "Youngest child 18 to 24 years"
label values agyownk kids 

/* CHILDREN, age of youngest child */

	/*
		RENAMING ALL OF THE VARIABLES WHICH ARE GOOD. 
		
	survyear
	survmnth
	prov
	C_cma
	C_age_12
	C_age_6
	sex
	C_schooln
	C_educ
	C_educ90
	bestEducation
	C_sp_educ90
	C_marstat
	C_immig
	C_lfsstat
	C_union
	C_cowmain
	C_multipleJobs
	ahrsmain atothrs uhrsmain utothrs tenure
	hrlyearn
	C_firmsize
	C_estsize
	efamtype
	bestNaics_18
	C_noc_10
	E_ftptmain
	C_noc_40
	C_flowUnem

	*/

	rename (survyear survmnth rec_num prov C_cma C_age_12 C_age_6 sex C_schooln C_educ) ///
		(K_year K_month K_recordId K_prov K_cma K_age_12 K_age_6 K_sex K_schooln K_educ)

	rename (C_educ90 bestEducation C_sp_educ90 C_marstat C_immig C_lfsstat) ///
		(K_educ90 K_bestEducation K_sp_educ90 K_marstat K_immig K_lfsstat)
		
	rename (C_union C_cowmain C_multipleJobs ahrsmain atothrs uhrsmain utothrs) ///
		(K_union K_cowmain K_multipleJobs K_ahrsmain K_atothrs K_uhrsmain K_utothrs)

	rename (tenure hrlyearn C_firmsize C_estsize efamtype bestNaics_18) ///
		(K_tenure K_hrlyearn K_firmsize K_estsize K_efamtype K_bestNaics_18)
		
	rename (C_noc_10 E_ftptmain C_noc_40 C_flowUnem C_whylefto C_durjless C_durunemp) ///
		(K_noc_10 K_ftptmain K_noc_40 K_flowUnem K_whylefto K_durjless K_durunemp) 
	
	rename (C_whypt C_yaway yabsent agyownk fweight finalwt) (K_whypt K_yaway K_yabsent K_agyownk K_fweight K_finalwt)
	
	keep K_*

	order *, alpha
	order K_year K_month K_prov K_recordId
	sort K_year K_month K_prov K_recordId

	save "ReplicationFolder_CJE_Covid/Data/dtaFiles/lfs_2016Jan_to_2020december_checkedData.dta", replace

	/* timer off */
		timer off 5
		timer list 
	
	}
else{
    display "The lfs checked dataset has already been created."
}