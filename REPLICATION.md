# [10.1111/caje.12543] [The short-term economic consequences of COVID-19: Occupation tasks and mental health in Canada] Validation and Replication results


## SUMMARY


### Action Items (manuscript) 10.1111/caje.12543

### Action Items (openICPSR) https://doi.org/10.5683/SP3/M4H6WC


## General

- [X] Data Availability and Provenance Statements
  - [ ] Statement about Rights
  - [ ] License for Data
  - [ ] Details on each Data Source
- [X] Dataset list
- [X] Computational requirements
  - [ ] Software Requirements
  - [ ] Controlled Randomness
  - [ ] Memory and Runtime Requirements
- [X] Description of programs/code
  - [ ] (Optional, but recommended) License for Code
- [X] Instructions to Replicators
  - [ ] Details
- [ ] List of tables and programs
- [X] References


## Data description

### Data Sources

#### Labor Force Survey, Statistics Canada

- Public available data set.
- The raw data set is not provided, but the cleaning code is provided.
- The data is cited in the README, but not in the references section of the manuscript.


#### Canadian Perspective Survey Series

- Public available data set.
- The raw data set is not provided, but the cleaning code is provided.
- The data is cited in the README, but not in the references section of the manuscript.

#### O*NET Indexes
- public available data set.
- The raw data set is provided.
- The data is cited in the README, but not in the references section of the manuscript.

#### Dingel and Neiman Work from Home Index
- The data set is provided.
- The data set is cited.

#### LMI Critical Workers Index
- The data set is provided.
- The data is cited in the README, but not in the references section of the manuscript.

#### Crosswalk between NOC and O*NET
- The data set is provided.
- The data is cited in the README, but not in the references section of the manuscript.

#### LMiC Index
- The data set is provided.
- The data is cited in the README, but not in the references section of the manuscript.

#### Canadian National Occupation Classification Class of Worker (2016)
- The data set is provided.
- The data is cited in the README, but not in the references section of the manuscript.

#### Canadian All-Items CPI
- The data set is provided.
- The data is cited in the README, but not in the references section of the manuscript.

#### COVID-19 Mortality and Case Counts
- The data set is provided.
- The data set is cited.



### Analysis Data Files

- [ ] No analysis data file mentioned
- [ ] Analysis data files mentioned, not provided (explain reasons below)
- [X] Analysis data files mentioned, provided. File names listed below.


```
./ReplicationFolder_CJE_Covid/Data/dtaFiles/DingleNieman_workFromHome_onet.dta
./ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset_CPSS.dta
./ReplicationFolder_CJE_Covid/Data/dtaFiles/onetExposure_diseaseAndInfection.dta
./ReplicationFolder_CJE_Covid/Data/dtaFiles/onetExposure_physicalProximity.dta
./ReplicationFolder_CJE_Covid/Data/dtaFiles/onetToNoc.dta
./ReplicationFolder_CJE_Covid/Data/dtaFiles/SOC_criticalInfrastructureWorkers.dta
./ReplicationFolder_CJE_Covid/Data/dtaFiles/toBeMerged_allItemsCPI_Jan2018_Dec2020.dta
./ReplicationFolder_CJE_Covid/Data/dtaFiles/twoDigit_indices.dta
./ReplicationFolder_CJE_Covid/Data/dtaFiles/EventStudy.dta
./ReplicationFolder_CJE_Covid/Data/dtaFiles/mainDataset.dta
```

## Data deposit

> INSTRUCTIONS: Most deposits will be at openICPSR, but all need to be checked for complete metadata. Detailed guidance is at [https://aeadataeditor.github.io/aea-de-guidance/](https://aeadataeditor.github.io/aea-de-guidance/). 

### Requirements 


- [X] README is in TXT, MD, PDF format
- [ ] Deposit has no ZIP files
- [X] Title conforms to guidance (starts with "Data and Code for:" or "Code for:", is properly capitalized)
- [X] Authors (with affiliations) are listed in the same order as on the paper


```
- In the deposit, there is a ZIP file called Data (1).zip, which contains all the data, programs, and results
```

> Detailed guidance is at [https://aeadataeditor.github.io/aea-de-guidance/](https://aeadataeditor.github.io/aea-de-guidance/), for non-ICPSR deposits, check out [this guidance](https://aeadataeditor.github.io/aea-de-guidance/guidelines-other-repositories).

### Deposit Metadata

- [ ] JEL Classification (required)
- [ ] Manuscript Number (required)
- [ ] Subject Terms (highly recommended)
- [ ] Geographic coverage (highly recommended)
- [ ] Time period(s) (highly recommended)
- [ ] Collection date(s) (suggested)
- [ ] Universe (suggested)
- [ ] Data Type(s) (suggested)
- [ ] Data Source (suggested)
- [ ] Units of Observation (suggested)

For additional guidance, see [https://aeadataeditor.github.io/aea-de-guidance/data-deposit-aea-guidance.html](https://aeadataeditor.github.io/aea-de-guidance/data-deposit-aea-guidance.html).

## Data checks

- Data can be read.
- Datasets are in custom formats (DTA).
- Most of the variables have variable labels.


## Code description

There are 27 provided Stata do files, plus a "master.do".
- [X] The replication package contains a "main" or "master" file(s) which calls all other auxiliary programs.

### Tables
- Table 1, Tables_SummaryStatistics_MainRegressions.do
- Table 2, Tables_SummaryStatistics_NOCMeans.do
- Table 3, Tables_SummaryStatistics_demographics.do
- Table 4 and 5, Tables_Regressions_BeforeAndAfter.do
- Table 6, Tables_Regressions_Indexes_Interacted.do
- Table 7, Tables_Regressions_Indexes_Interacted_nonHealthCareWorkers.do
- Table 8 and 9, Tables_Regressions_CPSS.do
- Table A1, not generated by the codes
- Table A2, Tables_Regressions_CPSS.do
- Table A3, Tables_ComparingLFS_And_CPSS.do
- Table A4 and A5, Tables_Regressions_BeforeAndAfter_appendix.do
- Table A6, Tables_Regressions_ReasonAwayFromWork.do
- Table A7, Tables_Regressions_Indexes_Interacted_appendix.do
- Table A8, Tables_Regressions_Indexes_Interacted_nonHealthCareWorkers_appendix.do
- Table A9, Tables_Regressions_Indexes_Interacted_AlternativeIndexForEssentialWorker.do
- Table A10, Tables_Regressions_Indexes_Interacted_AlternativeIndexForEssentialWorker_appendix.do
- Table A11-A14, Tables_Regressions_Heterogeneity_appendix.do
- Table A15, Tables_Regressions_CPSS.do
- Table A16 and A17, Tables_SummaryStatistics_NOC_Difference_BeforeAndAfter_appendix.do

### Figures
- Figure 1, Figures_CasesAndMortalities.do
- Figure 2-5, Figures_TimeSeriesAndBubbles.do
- Figure 6, Figures_Difference_Occupations.do
- Figure 7 and 8, Figures_EventStudies_Indexes.do
- Figure A1-A3, Figures_CasesAndMortalities.do
- Figure A4-A15, Figures_TimeSeriesAndBubbles.do
- Figure A16 and A17, Figures_EventStudies_Indexes.do



## Stated Requirements


- [ ] No requirements specified
- [X] Software Requirements specified as follows:
  - Stata
  - Stata packages: estout, boottest, coefplot, unique, blindschemes, grstyle, palettes, colrspace
- [X] Computational Requirements specified as follows:
  - Cluster size, etc.
- [X] Time Requirements specified as follows:
  - Length of necessary computation (hours, weeks, etc.)

- [X] Requirements are complete.


## Missing Requirements

- [ ] Software Requirements 
  - [ ] Stata
    - [ ] Version
    - Packages go here
  - [ ] Matlab
    - [ ] Version
  - [ ] R
    - [ ] Version
    - R packages go here
  - [ ] Python
    - [ ] Version
    - Python package go here
  - [ ] REPLACE ME WITH OTHER
- [ ] Computational Requirements specified as follows:
  - Cluster size, disk size, memory size, etc.
- [ ] Time Requirements 
  - Length of necessary computation (hours, weeks, etc.)



## Computing Environment of the Replicator

- Macbook Pro, MacOS 12.6, Chip Apple M2, 16 GB of memory
- Stata 17


## Replication steps

1. Downloaded code and data from the dataverse.
2. Inside the downloaded file, unzipped Data(1).zip, which contains all the data and codes.
3. Changed the pathway to my local computer. Created a log file.
4. When running the code, Stata ran into trouble related to the following four packages grstyle, boottest, palettes, colrspace. The ados for the above four packages are provided, but somehow Stata couldn't recognize them. So, I added the installation codes again.
5. Run the Main.do. Everything is now push-button reproducible.

## Findings

### Tables

- Table 1: Looks the same
- Table 2: Looks the same
- Table 3: Looks the same
- Table 4 and 5: Look the same
- Table 6: Looks the same
- Table 7: Looks the same
- Table 8 and 9: Look the same
- Table A1: Looks the same
- Table A2: Looks the same
- Table A3: Looks the same
- Table A4 and A5: Look the same
- Table A6: Looks the same
- Table A7: Looks the same
- Table A8: Looks the same
- Table A9: Looks the same
- Table A10: Looks the same
- Table A11-A14: Look the same
- Table A15: Looks the same
- Table A16 and A17, Look the same

### Figures

- Figure 1: Looks the same
- Figure 2-5: Look the same
- Figure 6: Looks the same
- Figure 7 and 8: Look the same
- Figure A1-A3: Look the same
- Figure A4-A15: Look the same
- Figure A16 and A17: Look the same




## Classification

- [X] full reproduction
- [ ] full reproduction with minor issues
- [ ] partial reproduction (see above)
- [ ] not able to reproduce most or all of the results (reasons see above)

### Reason for incomplete reproducibility

- [ ] `Discrepancy in output` (either figures or numbers in tables or text differ)
- [ ] `Bugs in code`  that  were fixable by the replicator (but should be fixed in the final deposit)
- [ ] `Code missing`, in particular if it  prevented the replicator from completing the reproducibility check
  - [ ] `Data preparation code missing` should be checked if the code missing seems to be data preparation code
- [ ] `Code not functional` is more severe than a simple bug: it  prevented the replicator from completing the reproducibility check
- [ ] `Software not available to replicator`  may happen for a variety of reasons, but in particular (a) when the software is commercial, and the replicator does not have access to a licensed copy, or (b) the software is open-source, but a specific version required to conduct the reproducibility check is not available.
- [ ] `Insufficient time available to replicator` is applicable when (a) running the code would take weeks or more (b) running the code might take less time if sufficient compute resources were to be brought to bear, but no such resources can be accessed in a timely fashion (c) the replication package is very complex, and following all (manual and scripted) steps would take too long.
- [ ] `Data missing` is marked when data *should* be available, but was erroneously not provided, or is not accessible via the procedures described in the replication package
- [ ] `Data not available` is marked when data requires additional access steps, for instance purchase or application procedure. 
- [ ] `Missing README` is marked if there is no README to guide the replicator.
