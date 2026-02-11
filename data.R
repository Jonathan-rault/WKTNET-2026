#######################################################################
##### LIBRARIES / AND USEFULL FUNCTIONS ###############################
#######################################################################

library(icesTAF)
library(dplyr)

TAF::taf.library("RDBEScore", messages = TRUE, warnings = TRUE)

lapply(list.files("./R-functions", full.names = TRUE), source)


#######################################################################
##### USEFULL PATH ####################################################
#######################################################################

path_system_boot <- path_system_boot()


#######################################################################
##### GETTING RUN PARAMETERS ##########################################
#######################################################################

source("./PARAMETERS.R")

year <- params$year
stocks <- params$stocks


#######################################################################
##### GETTING USEFULL DATA ############################################
#######################################################################

rdbes_data <- readRDS(paste0(path_system_boot$rdbes, "/RDBES_data.rds"))

ices_stocks <- xlsx_read_tables(path_system_boot$ices_stocks)


#######################################################################
##### LOOP OVER STOCKS ################################################
#######################################################################

for(stock in stocks) {

  stock_infos <- ices_stocks$stocks_infos |>
    filter(STOCK_NAME == stock)

  stock_areas <- ices_stocks$stocks_areas |>
    filter(STOCK_NAME == stock)

  path_stock <- path_system_stock(
    stock_infos = stock_infos,
    year = year
  )

  TAF::mkdir(path_stock$data)

  rdbes_stock <- rdbes_data |>
    filterRDBESDataObject(fieldsToFilter = "CEarea", valuesToFilter = stock_areas$ICES_AREA) |>
    filterRDBESDataObject(fieldsToFilter = "CLarea", valuesToFilter = stock_areas$ICES_AREA) |>
    filterRDBESDataObject(fieldsToFilter = "CLspecCode", valuesToFilter = stock_infos$ICES_APHIA_1)

  saveRDS(rdbes_stock, file = paste0(path_stock$data, "/", "rdbes_", stock_infos$STOCK_NAME, ".rds"))

}

