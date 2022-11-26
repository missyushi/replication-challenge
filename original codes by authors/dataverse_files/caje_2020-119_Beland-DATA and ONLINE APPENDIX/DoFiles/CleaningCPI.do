/*

	GETTING THE CORRECT CPI DATA 

*/

/*
	Adding CPI for Real Dollars
	
Objective:
	Not clutter up any of the analysis. 
	
*/

clear 

/* Timer */
	timer on 6 

import delimited "ReplicationFolder_CJE_Covid/Data/allItemsCPI_March2020.csv", encoding(UTF-8) 


foreach x in geography{
	replace `x' = `x'[_n-1] if missing(`x')
}


/* Generate the correct years and months */
split referenceperiod, parse("-") gen(parts)
rename parts2 badMonth
rename parts1 badYear 

gen betaYear = "20" + badYear
destring betaYear, gen(K_year)
generate K_month = month(date(badMonth, "M"))


/* Rename All Items CPI*/
rename allitems2002 allItemsCPI2002




/* Make sure we have compatible province numbers */
encode(geography), gen(prov)

recode prov (1 = 48 "Alberta") (2 = 59 "British Columbia") (3 = 100 "Canada") ///
	(4 = 46 "Manitoba") (10 = 24 "Quebec") (5 = 13 "New Brunswick") ///
	(6 = 10 "Newfoundland and Labrador")	(7 = 12 "Nova Scotia") ///
	(8 = 35 "Ontario") (9 = 11 "Prince Edward Island") ///
	(11 = 47 "Saskatchewan") , gen(K_prov)
	
	
/* How does it look? */
order K_prov K_year K_month allItemsCPI2002
sort K_prov K_year K_month 
	
/* Fill in the CPI for Missing Values */
bysort K_prov: replace allItemsCPI = allItemsCPI[_n-1] if allItemsCPI == . 	

/* Make and interim 2018 Real Dollars */
bysort K_prov: gen allItemsCPI_Jan2018_interim = allItemsCPI2002 if K_month == 1 & K_year == 2018
bysort K_prov: replace allItemsCPI_Jan2018_interim = allItemsCPI_Jan2018_interim[_n-1] if missing(allItemsCPI_Jan2018_interim)

gsort -K_prov -K_year -K_month 
replace allItemsCPI_Jan2018_interim = allItemsCPI_Jan2018_interim[_n-1] if missing(allItemsCPI_Jan2018_interim)


/* How does it look? */
order K_prov K_year K_month allItemsCPI2002
sort K_prov K_year K_month 


/* Make the actual 2018 real dollars */
gen allItemsCPI_Jan2018 = allItemsCPI2002/allItemsCPI_Jan2018_interim


/* Tidy the dataset */	 
keep K_prov K_year K_month allItemsCPI_Jan2018


/* How does it look? */
order K_prov K_year K_month allItemsCPI_Jan2018
sort K_prov K_year K_month 


/* Save what we need */
save "ReplicationFolder_CJE_Covid/Data/dtaFiles/toBeMerged_allItemsCPI_Jan2018_Dec2020.dta", replace

/* Timer */
	timer off 6
	timer list 