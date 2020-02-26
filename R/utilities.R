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

safe_harbor_transformation <- function(microdata,unique_identifers=c(),dates=c(), dob=c(),zipcode=c(),masking = F){

  if(length(unique_identifers)!=0&!masking){

    for(pii in unique_identifers){

      microdata[[pii]]=NULL

    }

  }else{
    if(length(unique_identifers)!=0){

      for(pii in unique_identifers){

        microdata[[pii]]=microdata[[pii]][sample(x = 1:nrow(microdata),1)]

    }




    }
  }

  if(length(zipcode)!=0){
    ############handeling the zip###############
    #load('../../data/uszips.rda')
    uszips=MedOrionanonymizingtoolBOX::uszips_population
    uszips$zip=as.integer(uszips$zip)
    names(uszips)[which(names(uszips)=="zip")]=zipcode


    #The initial three digits of a ZIP code
    microdata[[zipcode]]= sapply(X = microdata[[zipcode]],FUN = MedOrionanonymizingtoolBOX::return_3_digit)
    microdata%<>%dplyr::left_join(uszips[,c(zipcode,"total_population")],by = zipcode)

    #for all such geographic units containing 20,000 or fewer people is changed to 000
    microdata$MEMBER_ZIP_CODE[microdata$total_population<20000]="000"


  }


  if(length(dob)!=0){

    #####################age####

    #year supression +age above 90
    microdata[[dob]]=lubridate::year(lubridate::now())-lubridate::year(microdata[[dob]])
    microdata[[dob]][microdata[[dob]]>90]=90

  }

  if(length(dates)!=0){

    for(date_col in dates){

      microdata[[date_col]]=lubridate::year(microdata[[date_col]])

    }


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


#' this split a dataframe into lowrisk patients and highrisk patients
#'
#'
#' @param microdata sdc_data_frame sdc object or microdata
#' @param k_anon_number integer -  number of anonmity to decide our split at
#' @return list - two elements: 1) low_risk_patients 2)high_risk_patients
#'
#' @export


detect_low_sample_frequency <- function(sdc_data_frame,k_anon_number=2){

  result=list()
  get_frequencies=sdc_data_frame@risk$individual%>%data.frame()
  get_frequencies=get_frequencies$fk
  low_risk=(get_frequencies>k_anon_number)
  low_risk_patients=sdc_data_frame@origData[low_risk,]
  high_risk_patients=sdc_data_frame@origData[!low_risk,]

  result$low_risk_patients=low_risk_patients
  result$high_risk_patients=high_risk_patients
  return(result)

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


anonymize_dataframe <- function(sdc_data_frame ,anony_methods=c("divide","Suppression","microaggregation"),k_anon_number=2,aggregation_number=3){



  if("Suppression" %in% anony_methods){
    sdc <- sdcMicro::localSuppression(sdc_data_frame, k = k_anon_number)
    print(sdc)
    print(sdc,"risk")

  }

  if("microaggregation" %in% anony_methods){

    ###need to fix#####
    # sdc <- sdcMicro::globalRecode(sdc, column="birthday",
    #                     breaks=c(64,70,75,80), labels=c(67,72,77))

    sdc <- sdcMicro::microaggregation(sdc, aggr =aggregation_number)
    print(sdc, "numrisk")

    }

  #releasing the data
  df_disclosure =cbind(sdc@manipNumVars,sdc@manipKeyVars)
  df_disclosure =cbind(df_disclosure,sdc_data_frame@origData[,
                                                             setdiff(names(sdc_data_frame@origData),
                                                                     names(df_disclosure))])

  df_disclosure = df_disclosure[,names(df_safe_harbor)]

  for(name in names(df_disclosure)){

    if(is.numeric(df_disclosure[[name]])){
      df_disclosure[[name]]=as.integer(df_disclosure[[name]])

    }
  }

  return(df_disclosure)

}



#' @export
return_3_digit=function(num){

  while(num >= 1000)
  {

    num = num / 10 ;
  }
  return(as.integer(num))
}



