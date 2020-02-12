library(sdcMicro)
library(tidyverse)
library(magrittr)


#' this function perform safe habor guidelines on the data
#'
#'
#' @param microdata dataframe
#' @param unique_identifers vector of columns names -unique identifying number, characteristic, or code. Certificate/license numbers
#' @param dates vector of columns names -  admission date, discharge date, death date
#' @param dob columns name - birth date
#' @param zipcode columns name - geographic subdivisions
#' @return anonymized data frame with safe harbor guidlines
#'
#' @export

safe_harbor_transformation <- function(microdata,unique_identifers,dates, dob,zipcode){

  for(pii in unique_identifers){

    microdata[[pii]]=NULL

  }



  ############handeling the zip###############
  load('../data/population_by_zip.rda')
  population_by_zip$zip=as.integer(population_by_zip$zip)
  names(population_by_zip)[which(names(population_by_zip)=="zip")]=zipcode


  #The initial three digits of a ZIP code
  microdata$MEMBER_ZIP_CODE=as.integer(microdata$MEMBER_ZIP_CODE/100)
  microdata%<>%dplyr::left_join(population_by_zip[,c(zipcode,"total_population")],by = zipcode)

  #for all such geographic units containing 20,000 or fewer people is changed to 000
  microdata$MEMBER_ZIP_CODE[microdata$total_population<20000]="000"

  #year supression +age above 90
  microdata[[dob]]=lubridate::year(lubridate::now())-lubridate::year(microdata[[dob]])
  microdata[[dob]][microdata[[dob]]>90]=90


  for(date_col in dates){

    microdata[[date_col]]=lubridate::year(microdata[[date_col]])

  }

  #deleting the population variable
  microdata$total_population=NULL
  return(microdata)

}


#' this function transform the data to an SDCmicro object
#'
#'
#' @param microdata dataframe
#' @param keyVars vector of columns names - are a set of variables that, when considered together, can be used to identify individual units.
#' @param numVars vector of columns names -  ontinuous key variables
#' @param pramVars vector of columns names -  Indices or names of categorical variables considered to be pramed
#' @return sdcobject
#'
#' @export

transform_to_sdc <- function(microdata,
                             keyVars,
                             numVars
){


  if(!is.data.frame(microdata)){microdata=data.frame(microdata)}
  sdc <- sdcMicro::createSdcObj(microdata,
                      keyVars,
                      numVars)

  return(sdc)



}


#' this function transform the data to an SDCmicro object
#'
#'
#' @param microdata sdc_data_frame sdc object or microdata
#' @param anony_methods vector of procedures names - "Suppression","microaggregation"
#' @param k_anon_number integer -  number of anonmity to achive
#' @param aggregation_number integer -  number of buckets for numeric feature
#' @return anonymized SDC dataframe
#'
#' @export


anonymize_dataframe <- function(sdc_data_frame ,anony_methods=c("Suppression","microaggregation"),k_anon_number=2,aggregation_number=3){



  sdc <- sdcMicro::localSuppression(sdc_data_frame, k = k_anon_number)
  print(sdc)
  print(sdc,"risk")

  sdc <- sdcMicro::microaggregation(sdc, aggr =aggregation_number)
  print(sdc, "numrisk")

  #releasing the data
  df_disclosure =cbind(sdc@manipNumVars,sdc@manipKeyVars)
  df_disclosure =cbind(df_disclosure,sdc_data_frame@origData[,
                                                             setdiff(names(sdc_data_frame@origData),
                                                                     names(sdc_data_frame))])

  df_disclosure = df_disclosure[,names(df_safe_harbor)]

  for(name in names(df_disclosure)){

    if(is.numeric(df_disclosure[[name]])){
      df_disclosure[[name]]=as.integer(df_disclosure[[name]])

    }
  }

  return(df_disclosure)

}







