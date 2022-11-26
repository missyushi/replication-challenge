/*
Version 4
Weighting NOC 
	
FINALLY, we got the employment shares from Stats Can 	

Version 4
	- Add the LMiC indexes 
	
*/


/* First, create the .dta files from the excel files. */



/* Merge all the .dta files and then aggregate */
clear

/* timer */
	timer on 13 

import delimited "ReplicationFolder_CJE_Covid/Data/Cleaner_NOC500_2016Census.csv"

drop v9

rename occupationnationaloccupationalcl noc500
replace noc500 = strtrim(noc500)
gen numberNOC = strtrim(substr(noc500, 1, strpos(noc500, " ")))

count if strlen(numberNOC) == 4

gen noc = numberNOC if strlen(numberNOC) == 4

keep if noc !=""


/* VERSION 4 - adding the LMiC indexes - there are only 274 */
	preserve 
	
		clear 
		
		import excel "ReplicationFolder_CJE_Covid/Data/PanCanadianEssentialServicesList.xlsx" ///
			, 	sheet("THISONE") firstrow allstring
			
		replace noc = "0" + noc if strlen(noc)==3
		replace noc = "00" + noc if strlen(noc)==2
		
		rename binary essentialWorkers 
		
		// Suss out the duplicates 
		duplicates report name noc essentialWorkers 
		duplicates tag, gen(hadDuplicates_flag)
		duplicates drop noc, force 
		
		// Drop irrelevant variables
			drop hadDuplicates_flag
		
		
		tempfile lmic
		save `lmic'
	
	restore

// ADD the essentialWorkers from the LMiC 	
merge 1:1 noc using `lmic'
drop _merge 

// Assume that if the individual occupation is omitted, then they are  
// not considered essential 
replace essentialWorkers = "No" if essentialWorkers == ""
gen essWorker = .
replace essWorker = 0 if essentialWorkers == "No"
replace essWorker = 1 if essentialWorkers == "Yes"
	
// ADD THE ONET-SOC CODES
merge 1:m noc using "ReplicationFolder_CJE_Covid/Data/dtaFiles/onetToNoc.dta"
drop if _merge != 3 //These were all Not available or missing rows

unique noc 
drop _merge

// ADD THE PROXIMITY MEASURE
merge m:1 onet using  "ReplicationFolder_CJE_Covid/Data/dtaFiles/onetExposure_physicalProximity.dta"
unique noc if _merge == 3 //484
drop _merge

// ADD EXPOSURE MEASURE 
merge m:1 onet using  "ReplicationFolder_CJE_Covid/Data/dtaFiles/onetExposure_diseaseAndInfection.dta"
unique noc if _merge == 3 //484 
drop _merge

sort exposure*
drop if exposureToDisezOrInfx_index == "Not available"
destring exposure*, replace 

// ADD CRITICAL WORKERS 
merge m:1 onetSplits1 using  "ReplicationFolder_CJE_Covid/Data/dtaFiles/SOC_criticalInfrastructureWorkers.dta"
unique noc if _merge == 3 //446 
drop _merge

// ADD WORK FROM HOME NIEMAN
merge m:1 onet using "ReplicationFolder_CJE_Covid/Data/dtaFiles/DingleNieman_workFromHome_onet.dta"
unique noc if _merge == 3 //478
drop _merge 

sort noc500

bysort noc500: egen mean_physProx_index = mean(physicalProximity_index)
bysort noc500: egen min_physProx_index = min(physicalProximity_index)
bysort noc500: egen max_physProx_index = max(physicalProximity_index)
bysort noc500: gen range_physProx_index = max_physProx_index - min_physProx_index

bysort noc500: egen mean_exp_index = mean(exposureToDisezOrInfx_index)
bysort noc500: egen min_exp_index = min(exposureToDisezOrInfx_index)
bysort noc500: egen max_exp_index = max(exposureToDisezOrInfx_index)
bysort noc500: gen range_exp_index = max_exp_index - min_exp_index

bysort noc500: egen mean_critNum = mean(criticalNumber)
bysort noc500: egen min_critNum = min(criticalNumber)
bysort noc500: egen max_critNum = max(criticalNumber)
bysort noc500: gen range_critNum = max_critNum - min_critNum

bysort noc500: egen mean_HomeWork = mean(binary_workFromHome_onet)
bysort noc500: egen min_HomeWork = min(binary_workFromHome_onet)
bysort noc500: egen max_HomeWork= max(binary_workFromHome_onet)
bysort noc500: gen range_HomeWork = max_HomeWork - min_HomeWork

// Essential Worker 
bysort noc500: egen mean_essWorker = mean(essWorker)
bysort noc500: egen min_essWorker = min(essWorker)
bysort noc500: egen max_essWorker = max(essWorker)
bysort noc500: gen range_essWorker = max_critNum - min_critNum

// drop onet* 
drop onet*
unique noc*

duplicates drop noc500, force

// Now, aggregate up with weights 
gen thirdAggregateNOC = substr(noc,1,3)

bysort thirdAggregateNOC: egen threeDigitSum = sum(allclassesofworkers5)
gen threeDigitProp = allclassesofworkers5/threeDigitSum
// A CHECK! : bysort thirdAggregateNOC: egen threeDigitSumCheck = sum(threeDigitProp)


*** NOTE! NOW WE ARE ASSUMING ANY MISSING VALUES ARE ASSIGNED THEIR MEAN
bysort thirdAggregateNOC: egen unweightedScore_phys = mean(mean_physProx_index) 
bysort thirdAggregateNOC: replace mean_physProx_index = unweightedScore_phys if mean_physProx_index == . 

bysort thirdAggregateNOC: egen unweightedScore_exp = mean(mean_exp_index) 
bysort thirdAggregateNOC: replace mean_exp_index = unweightedScore_exp if mean_exp_index == . 

bysort thirdAggregateNOC: egen unweightedScore_critNum = mean(mean_critNum) 
bysort thirdAggregateNOC: replace mean_critNum = unweightedScore_critNum if mean_critNum == . 

bysort thirdAggregateNOC: egen unweightedScore_HomeWork = mean(mean_HomeWork) 
bysort thirdAggregateNOC: replace mean_HomeWork = unweightedScore_HomeWork if mean_critNum == . 

bysort thirdAggregateNOC: egen unweightedScore_essWorker = mean(mean_essWorker) 
bysort thirdAggregateNOC: replace mean_essWorker = unweightedScore_essWorker if mean_essWorker == . 

// Collapse down to three-digit
bysort thirdAggregateNOC: egen mean_weighted_phys = sum(mean_physProx_index*threeDigitProp)
bysort thirdAggregateNOC: egen mean_weighted_exp = sum(mean_exp_index*threeDigitProp)
bysort thirdAggregateNOC: egen mean_weighted_critNum = sum(mean_critNum*threeDigitProp)
bysort thirdAggregateNOC: egen mean_weighted_HomeWork = sum(mean_HomeWork*threeDigitProp)
bysort thirdAggregateNOC: egen mean_weighted_essWorker = sum(mean_essWorker*threeDigitProp)

bysort thirdAggregateNOC: egen thirdAggregateSum_AllClass = sum(allclassesofworkers5)


keep noc500 totalclassofworker3 classofworkernotapplicable4 allclassesofworkers5 employee selfemployed selfemployed6 unpaidfamilyworker numberNOC noc noc_title physicalProximity_index exposureToDisezOrInfx_index OccupationDescription Critical criticalNumber binary_workFromHome_onet thirdAggregateNOC mean_weighted_phys mean_weighted_exp mean_weighted_critNum mean_weighted_HomeWork  mean_weighted_essWorker thirdAggregateSum_AllClass

bysort thirdAggregateNOC: gen uniqueVals = _n

// Every higher aggregate group has the same value, just keep one row from the group. 
keep if uniqueVals == 1 

// Drop everything which isn't necessary 
drop noc500 totalclassofworker3 classofworkernotapplicable4 allclassesofworkers5 employee selfemployed selfemployed6 unpaidfamilyworker numberNOC noc noc_title physicalProximity_index exposureToDisezOrInfx_index OccupationDescription Critical criticalNumber binary_workFromHome_onet

// An odd first row 
drop if _n == 1

// Collapse to two-digit 
gen secondAggregateNOC = substr(thirdAggregateNOC,1,2)
bysort secondAggregateNOC: egen twoDigitSum = sum(thirdAggregateSum_AllClass)
gen twoDigitProp = thirdAggregateSum_AllClass/twoDigitSum

// Construct the Mean for two-digit groups mean_weighted_phys mean_weighted_exp mean_weighted_critNum
bysort secondAggregateNOC: egen mean_weighted_phys_2 = sum(mean_weighted_phys*twoDigitProp)
bysort secondAggregateNOC: egen mean_weighted_exp_2 = sum(mean_weighted_exp*twoDigitProp)
bysort secondAggregateNOC: egen mean_weighted_critNum_2 = sum(mean_weighted_critNum*twoDigitProp)
bysort secondAggregateNOC: egen mean_weighted_HomeWork_2 = sum(mean_weighted_HomeWork*twoDigitProp)
bysort secondAggregateNOC: egen mean_weighted_essWorker_2 = sum(mean_weighted_essWorker*twoDigitProp)


order thirdAggregateNOC secondAggregateNOC mean_weighted*

keep secondAggregateNOC mean_weighted*2 twoDigitSum
bysort secondAggregateNOC: gen uniqueVals = _n

keep if uniqueVals == 1 

// Now making it match the LFS
destring secondAggregate, gen(tempNum)

// We need to further create a larger group for 01-05 and 07-09
gen tooChange = 2*inrange(tempNum,1,5) + 7*inrange(tempNum,7,9)

egen twoDigitSum_LFS = sum(twoDigitSum) if inrange(tempNum,1,5) | inrange(tempNum,7,9)
replace twoDigitSum_LFS = twoDigitSum if twoDigitSum_LFS == .

gen twoDigitProp = twoDigitSum/twoDigitSum_LFS

// Generate the new weighted average. 
egen mean_weighted_phys_3 = sum(mean_weighted_phys*twoDigitProp) if inrange(tempNum,1,5) | inrange(tempNum,7,9)
replace mean_weighted_phys_3 = mean_weighted_phys_2 if mean_weighted_phys_3 == . 

egen mean_weighted_exp_3 = sum(mean_weighted_exp*twoDigitProp) if inrange(tempNum,1,5) | inrange(tempNum,7,9)
replace mean_weighted_exp_3 = mean_weighted_exp_2 if mean_weighted_exp_3 == . 

egen mean_weighted_critNum_3 = sum(mean_weighted_critNum*twoDigitProp) if inrange(tempNum,1,5) | inrange(tempNum,7,9)
replace mean_weighted_critNum_3 = mean_weighted_critNum_2 if mean_weighted_critNum_3 == . 

egen mean_weighted_HomeWork_3 = sum(mean_weighted_HomeWork_2*twoDigitProp) if inrange(tempNum,1,5) | inrange(tempNum,7,9)
replace mean_weighted_HomeWork_3 = mean_weighted_HomeWork_2 if mean_weighted_HomeWork_3 == . 

egen mean_weighted_essWorker_3 = sum(mean_weighted_essWorker_2*twoDigitProp) if inrange(tempNum,1,5) | inrange(tempNum,7,9)
replace mean_weighted_essWorker_3 = mean_weighted_essWorker_2 if mean_weighted_essWorker_3 == . 

// Check the ordering 
order secondAggregateNOC tooChange tempNum mean_weighted_exp_3 mean_weighted_critNum_3 mean_weighted_phys_3 mean_weighted_HomeWork_3 mean_weighted_essWorker_3

replace tooChange = tempNum if tooChange == 0

// sort tooChange 
bysort tooChange: gen tempp = _n

sort secondAggregateNOC 

keep if tempp == 1 

replace secondAggregateNOC = "01-05" if _n == 2
replace secondAggregateNOC = "07-09" if _n == 4

keep secondAggregateNOC mean_weighted_phys_3 mean_weighted_exp_3 mean_weighted_critNum_3 mean_weighted_HomeWork_3  mean_weighted_essWorker_3 twoDigitSum_LFS
order secondAggregateNOC mean_weighted_phys_3 mean_weighted_exp_3 mean_weighted_critNum_3 mean_weighted_HomeWork_3  mean_weighted_essWorker_3

gen K_noc_40 = _n


sum mean_weighted_phys_3, detail 
gen median_proximity = 0 + 1*(inrange(mean_weighted_phys_3, r(p50), r(p100)))

sum  mean_weighted_exp_3, detail 
gen median_exposure = 0 + 1*(inrange( mean_weighted_exp_3, r(p50), r(p100)))

sum mean_weighted_critNum_3, detail 
gen median_critNumber = 0 + 1*(inrange(mean_weighted_critNum_3, r(p50), r(p100)))

sum mean_weighted_HomeWork_3, detail
gen median_HomeWork = 0 + 1*(inrange(mean_weighted_HomeWork_3, r(p50), r(p100)))

sum mean_weighted_essWorker_3, detail
gen median_essWorker = 0 + 1*(inrange(mean_weighted_essWorker_3, r(p50), r(p100)))

replace mean_weighted_critNum_3 = 100*mean_weighted_critNum_3
replace mean_weighted_HomeWork_3 = 100*mean_weighted_HomeWork_3
replace mean_weighted_essWorker_3 = 100*mean_weighted_essWorker_3

rename (mean_weighted_phys_3 mean_weighted_exp_3 mean_weighted_critNum_3 mean_weighted_HomeWork_3 mean_weighted_essWorker_3) (physProx_weightedIndex exposure_weightedIndex critNumber_weightedIndex HomeWork_weightedIndex essWorker_weightedIndex)

save "ReplicationFolder_CJE_Covid/Data/dtaFiles/twoDigit_indices.dta", replace

/* timer off */
	timer off 13
	timer list 