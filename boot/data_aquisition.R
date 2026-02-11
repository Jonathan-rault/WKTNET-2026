library(AzureAuth)
library(httr)

library(TAF)
library(icesTAF)

library(openxlsx)
library(dplyr)

TAF::taf.library("RDBEScore", messages = TRUE, warnings = TRUE)

cat("I am here : ", getwd(), "\n")

lapply(list.files("../../../R-functions", full.names = TRUE), source)


#######################################################################
##### NEED TO ADD TAF RUN GLOBAL PARAMETERS ###########################
#######################################################################

source("../../../PARAMETERS.R")

year <- params$year
stocks <- params$stocks

#######################################################################
##### PATH AND DIRECTORIES ############################################
#######################################################################

path_tmp <- "../TMP"
path_rdbes <- "../RDBES"

TAF::mkdir(path_tmp)
TAF::mkdir(path_rdbes)

file_ices_stocks <- "../referentiel_stocks_ices.xlsx"


#######################################################################
##### GETTING STOCK INFORMATIONS ######################################
#######################################################################

ices_stocks <- xlsx_read_tables(file_ices_stocks)

stocks_infos <- ices_stocks$stocks_infos |>
  filter(STOCK_NAME %in% stocks)

stocks_areas <- ices_stocks$stocks_areas |>
  filter(STOCK_NAME %in% stocks)


#######################################################################
##### GETTING RDBES DATA FROM API #####################################
#######################################################################

az <- get_azure_token(
  resource = "api://18ab5ebb-1794-4e83-83f1-8fbd3dd5b152/rdbes.api.access",
  tenant = "e0b220ce-5735-4468-91df-05cae5ff1fdc",
  app = "b6347a7e-5f73-463a-81b1-3781d163de19",
  version = 2
)

CE <- RDBES_API_download(
  azure_token = az,
  datatype = "CE",
  year = year,
  hierarchy = NULL,
  country = "FR",
  export_format = "TableWithIdsFormat"
)

CL <- RDBES_API_download(
  azure_token = az,
  datatype = "CL",
  year = year,
  hierarchy = NULL,
  country = "FR",
  export_format = "TableWithIdsFormat"
)

file_saved_ce <- RDBES_API_save_zip(CE, path_outputs = path_tmp, file_name = NULL)
file_saved_cl <- RDBES_API_save_zip(CL, path_outputs = path_tmp, file_name = NULL)

CE_data <- createRDBESDataObject(file_saved_ce, castToCorrectDataTypes = TRUE) 
CL_data <- createRDBESDataObject(file_saved_cl, castToCorrectDataTypes = TRUE) 

CE_data <- CE_data |>
  filterRDBESDataObject(fieldsToFilter = "CEarea", valuesToFilter = stocks_areas$ICES_AREA)

CL_data <- CL_data |>
  filterRDBESDataObject(fieldsToFilter = "CLarea", valuesToFilter = stocks_areas$ICES_AREA) |>
  filterRDBESDataObject(fieldsToFilter = "CLspecCode", valuesToFilter = stocks_infos$ICES_APHIA_1)

RDBES_data <- combineRDBESDataObjects(CE_data, CL_data)

saveRDS(RDBES_data, file = paste0(path_rdbes, "/", "RDBES_data.rds"))
