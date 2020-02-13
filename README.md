

## Overview

The aim of the package to give tools for anonymizing microdata i.e  to transform the datasets in order  to achieve an “acceptable level” of disclosure risk. the packge should provide function in order to achive  the following path


![anonymizing microdata proccess](https://sdcpractice.readthedocs.io/en/latest/_images/image20.png)


##  Installation

In CMD
```bash
git clone https://github.com/medorion/medorion-anonymizing-toolbox.git

```
In R
```r
# Install devtools from CRAN
if(!require(devtools)){
  
  install.packages("devtools")
  
}



# Or the development version from GitHub:
devtools::install_github("r-lib/devtools")

#cd to the parent_dir_of_package/MedOrionanonymizingtoolBOX
setwd("parent_dir_of_package")

# Install MedOrionanonymizingtoolBOX
devtools::install("MedOrionanonymizingtoolBOX")

# load the package to your envirement
library(MedOrionanonymizingtoolBOX)

```
## Methods

###  The “Safe Harbor” method

**Description**

this function perform safe habor guidelines on the data

**Usage**

*safe_harbor_transformation(microdata, unique_identifers, dates, dob, zipcode)*

|                |Arguments|Value|
|----------------|-------------------------------|-----------------------------|
||microdata	          |dataframe           |
|          |unique_identifers	          |vector of columns names -unique identifying number, characteristic, or code.Certificate/license numbers
|       |dates|vector of columns names - admission date, discharge date, death date|
||dob	|columns name - birth date
||zipcode	|columns name - geographic subdivisions

#### example
```r

# input unanonymized dataset and perform safe_harbor on it 
microdata_anonymized=safe_harbor_transformation(microdata,                   
unique_identifers ,
dates ,
dob ,
zipcode)


```

#### details on how to pick the unique_identifers	 dates dob zip



The following identifiers of the individual or of relatives, employers, or household members of the individual, are removed:

(A) Names

(B) All geographic subdivisions smaller than a state, including street address, city, county, precinct, ZIP code, and their equivalent geocodes, except for the initial three digits of the ZIP code if, according to the current publicly available data from the Bureau of the Census:
(1) The geographic unit formed by combining all ZIP codes with the same three initial digits contains more than 20,000 people; and
(2) The initial three digits of a ZIP code for all such geographic units containing 20,000 or fewer people is changed to 000

(C) All elements of dates (except year) for dates that are directly related to an individual, including birth date, admission date, discharge date, death date, and all ages over 89 and all elements of dates (including year) indicative of such age, except that such ages and elements may be aggregated into a single category of age 90 or older

(D) Telephone numbers

(L) Vehicle identifiers and serial numbers, including license plate numbers

(E) Fax numbers

(M) Device identifiers and serial numbers

(F) Email addresses

(N) Web Universal Resource Locators (URLs)

(G) Social security numbers

(O) Internet Protocol (IP) addresses

(H) Medical record numbers

(P) Biometric identifiers, including finger and voice prints

(I) Health plan beneficiary numbers

(Q) Full-face photographs and any comparable images

(J) Account numbers

(R) Any other unique identifying number, characteristic, or code, except as permitted by paragraph (c) of this section [Paragraph (c) is presented below in the section “Re-identification”]; and

(K) Certificate/license numbers

(ii) The covered entity does not have actual knowledge that the information could be used alone or in combination with other information to identify an individual who is a subject of the information.




