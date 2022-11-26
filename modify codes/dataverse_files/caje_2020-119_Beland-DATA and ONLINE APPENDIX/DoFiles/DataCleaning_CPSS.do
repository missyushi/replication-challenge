
clear

/* timer */
	timer on 8 

infix using "ReplicationFolder_CJE_Covid/Data/CPSS/Pumf2020_cpss_sepc_s1.dct", ///
	using("ReplicationFolder_CJE_Covid/Data/CPSS/PUMF2020_CPSS_SEPC_S1.txt") clear

do "ReplicationFolder_CJE_Covid/Data/CPSS/Pumf2020_cpss_sepc_s1_infmt.do"
do "ReplicationFolder_CJE_Covid/Data/CPSS/Pumf2020_cpss_sepc_s1_lbe.do"
do "ReplicationFolder_CJE_Covid/Data/CPSS/Pumf2020_cpss_sepc_s1_vale.do"
do "ReplicationFolder_CJE_Covid/Data/CPSS/Pumf2020_cpss_sepc_s1_fmt.do"

codebook 

rename *, lower

foreach x in pbh_65a bh_65b bh_65c pbh_70_c dwelcodc educ_lvc pempstc haschild hhldsizc immigrnc lm_30 lm_40 plm_45 lm_35a lm_35b lm_35cde lm_35f marstatc sex ptelewsc{
	tab `x'
}


/*
1. Generating good control variables. 
*/
recode agegrp (1 2 = 1 "15 to 34") (3 4 = 2 "45 to 55") (5 6 7 = 3 "55+"), gen(ageCats)
label variable ageCats "Age Groups"
tab ageCats 

recode sex (1 = 0 "Male") (2 = 1 "Female"), gen(female)
tab female
label variable female "Female"

recode haschild (0 = 0 "No") (1 = 1 "Yes"), gen(hasChildUnder18InDwelling)
label variable hasChildUnder18InDwelling "Does a child under the age of 18 reside in the dwelling?"

recode marstatc (1 2 = 1 "Married or Common Law") (3 4 = 0 "Single, widowed, separated or divorced") ///
	, gen(marStat)
label variable marStat "Is the individual married or common-law?"

recode educ_lvc (1 = 1 "Less than High School") (2 = 2 "High School Diploma or equivalent") ///
	(3/7 = 3 "Above High School"), gen(educ)


/*
2. Labour Economics Measures 
*/
 
// Covid Absence
tab pempstc
tab pempstc, nolab
recode pempstc (9 = . ) ///
	, gen(empStat) copy
label define emp 1 "Employed, at work at least part" 2 "Employed but absent, not COVID" 3 "Employed but absent due to COVID" 4 "Unemployed"
label values empStat emp

recode pempstc (1 2 = 0 "Employed or absent (unrelated to COVID)") (3 = 1 "Employed but absent from work due to COVID-19") (4 9 = . ) ///
	, gen(employedCovidAbsence)
	
recode pempstc (1 2 3 = 0 "Employed or employed but absent due to COVID 19") (4 = 1 "Unemployed") (9 = . ) ///
	, gen(unemployed)
	
recode pempstc (1 2 = 0 "Employed or absent(unrelated to COVID)") (3 = 1 "Employed but absent from work due to COVID-19") (4 = 2 "Unemployed" ) ///
	, gen(unemployedFull)	
	
	
// Might lose job
recode lm_30 (1 = 1 "Strongly Agree") ///
	(2/5 = 0 "Agree, Agree or Disagree, Disagree, Strongly Disagree") (6 9 = .) ///
	, gen(mightLoseJob_1)
label variable mightLoseJob_1 "Might Lose Job in Next 4 Weeks, 1"
	
recode lm_30 (1 2 = 1 "Agree or Strongly Agree") ///
	(3/5 = 0 "Neither Agree or Disagree, Disagree, Strongly Disagree") (6 9 = .) ///
	, gen(mightLoseJob_2)
label variable mightLoseJob_2 "Might Lose Job in Next 4 Weeks, 2"
	
recode lm_30 (1/3 = 1 "Agree, Strongly Agree, Neither Agree or Disagre ") ///
	(4/5 = 0 "Disagree or Strongly Disagree") (6 9 = .) ///
	, gen(mightLoseJob_3)
label variable mightLoseJob_3 "Might Lose Job in Next 4 Weeks, 3"	

recode lm_30 (1/4 = 1 "Agree, Strongly Agree, Neither Agree or Disagre, Disagree ") ///
	(5 = 0 "Disagree or Strongly Disagree") (6 9 = .) ///
	, gen(mightLoseJob_4)
label variable mightLoseJob_3 "Might Lose Job in Next 4 Weeks, 3"


// Financial Responsibility 
recode lm_40 (1 = 1 "Major Impact") (2/5 = 0 "Moderate, Minor or No impact; Too soon to tell ") (9 = .) ///
	, gen(impactOnFinResp_1)

	
recode lm_40 (1/2 = 1 "Major or Moderate Impact") (3/5 = 0 "Minor or No impact; Too soon to tell") (9 = .) ///
	, gen(impactOnFinResp_2)
	
	
recode lm_40 (1/3 = 1 "Major, Moderate or Minor Impact") (4/5 = 0 "No impact; Too soon to tell") (9 = .) ///
	, gen(impactOnFinResp_3)
	
	
recode lm_40 (1/4 = 1 "Major, Moderate, Minor, No impact") (5 = 0 "Too soon to tell") (9 = .) ///
	, gen(impactOnFinResp_4)


// Perceived Mental Health 
recode bh_30 (1 = 0 "Excellent") (2/5 = 1 "Very Good, Good, Fair or Poor") (9=.),gen(mentalHealth_4)
recode bh_30 (1/2 = 0 "Excellent or Very Good") ( 3/5 = 1 "Good, Fair or Poor") (9=.), gen(mentalHealth_3)
recode bh_30 (1/3 = 0 "Excellent, Very Good or Good") (4/5 = 1 "Fair or Poor") (9=.), gen(mentalHealth_2)
recode bh_30 (1/4 = 0 "Excellent, Very Good or Good") (5 = 1 "Fair or Poor") (9=.), gen(mentalHealth_1)	

gen rev_mentalHealth = .
replace rev_mentalHealth = 1 if bh_30 == 5
replace rev_mentalHealth = 2 if bh_30 == 4
replace rev_mentalHealth = 3  if bh_30 == 3
replace rev_mentalHealth = 4 if bh_30 ==  2
replace rev_mentalHealth = 5 if bh_30 == 1

label define revExcellentScale 1 "Poor" 2 "Fair" 3 "Good" 4 "Very Good" 5 "Excellent"
label values rev_mentalHealth revExcellentScale

// Perceived Health 
recode bh_25 (1 = 0 "Excellent") (2/5 = 1 "Very Good, Good, Fair or Poor") (9=.),gen(health_4)
recode bh_25 (1/2 = 0 "Excellent or Very Good") ( 3/5 = 1 "Good, Fair or Poor") (9=.), gen(health_3)
recode bh_25 (1/3 = 0 "Excellent, Very Good or Good") (4/5 = 1 "Fair or Poor") (9=.), gen(health_2)
recode bh_25 (1/4 = 0 "Excellent, Very Good or Good") (5 = 1 "Poor") (9=.), gen(health_1)	

gen rev_health = .
replace rev_health = 1 if bh_25 == 5
replace rev_health = 2 if bh_25 == 4
replace rev_health = 3  if bh_25 == 3
replace rev_health = 4 if bh_25 ==  2
replace rev_health = 5 if bh_25 == 1

label values rev_health revExcellentScale

	
// Received Relief from Financial Obligations 
recode plm_45 ( 1 = 1 "Yes") (2/3 = 0 "No or Not Required") (9 = .), gen(finRelief_1)
recode plm_45 ( 1 = 1 "Yes") (2 = 0 "No") (9 = .), gen(finRelief_2)

// Telework Status
tab ptelewsc
tab ptelewsc, nolab 
recode ptelewsc (9 = .), gen(telework) copy
label define workFromHome 1 "Work Location Changed from Oustide" 2 "Work remains at home" 3 "Work remains outside home" 4 "Absent from Work"
label values telework workFromHome

recode ptelewsc (1 = 1 "Changed from outside home to home") ///
	(2/3 = 0 "Work Location is unchanged") (4 9 = .), gen(workFromHome)

// immigration Status 
recode immigrnc (1 = 0 "Born in Canada") (2 = 1 "Immigrant"), gen(immig)


/* Save the dataset */ 
save "ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset_CPSS.dta", replace 

/* timer off */
	timer off 8
	timer list 
		