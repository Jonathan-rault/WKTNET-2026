#' Title
#'
#' need checks on argument format
#' 
#' it seems that datatype = "CS" require a hierarchy value 
#'
#' @param azure_token description
#' @param datatype description
#' @param year description
#' @param hierarchy description
#' @param country description
#' @param export_format description
#'
#' @return result
#'
#' @export
#'
RDBES_API_download <- function(azure_token, datatype, year, hierarchy = NULL, country = "FR", export_format = "TableWithIdsFormat") {

  # azure_token <- az
  # datatype <- "CS"
  # year <- 2022
  # hierarchy <- "H1"
  # country <- "FR"
  # export_format <- "TableWithIdsFormat"

  base_url <- "https://sboxrdbes.ices.dk/api/taf/export/data"

  access_token <- azure_token$credentials$access_token

  year_qry <- paste0("?year=", year)
  country_qry <- paste0("&country=", country)
  export_format_qry <- paste0("&exportformat=", export_format)
  datatype_qry <- paste0("&datatype=", datatype)

  mandatory_params <- paste0(year_qry, country_qry, datatype_qry, export_format_qry)

  url <- NULL

  if(datatype %in% c("CE", "CL", "VD", "SL")) {
    url <- paste0(base_url, mandatory_params)
  }

  if(datatype == "CS" && !is.null(hierarchy) && hierarchy %in% paste0("H", seq(1, 13))) {
    hierarchy_qry <- paste0("&cshierarchy=", hierarchy)
    url <- paste0(base_url, mandatory_params,  hierarchy_qry)
  } 

  if(!is.null(url)) {
    response <- httr::GET(
      url = url,
      httr::add_headers(Authorization = paste("Bearer", access_token))
    )
  }else{
    warning("no url has been generated, check your parameters")
    return(NULL)
  }

  return(response)

}


#' Title
#'
#' Description
#'
#' @param rdbes_api_result description
#' @param path_outputs description
#' @param file_name without .zip extension / if NULL automatically generated
#' @param verbose description
#'
#' @return result
#'
#' @export
#'
RDBES_API_save_zip <- function(rdbes_api_result, path_outputs, file_name = NULL, verbose = FALSE) {

  if(!httr::status_code(rdbes_api_result) == 200) {
    cat("Failed to download:\n")
    cat("  Status code      :", httr::status_code(rdbes_api_result), "\n")
    cat("  Http status      :", httr::http_status(rdbes_api_result)$reason, "\n")
    cat("  Detailed message :", httr::content(rdbes_api_result, "text"), "\n")
    return(FALSE)
  }

  params_request <- httr::parse_url(rdbes_api_result$url)$query

  if(is.null(file_name)) {
    file_name <- paste0(params_request$datatype, "_", params_request$country, "_", params_request$year)
    if("cshierarchy" %in% names(params_request)) {
      file_name <- paste0(file_name, "_", params_request$cshierarchy)
    }
  }
  
  saving_file <- paste0(path_outputs, "/", file_name, ".zip")

  base::writeBin(httr::content(rdbes_api_result, "raw"), saving_file)
  
  if(verbose) {
    cat("Downloaded:", saving_file, "\n")
    cat("  Status code      :", httr::status_code(rdbes_api_result), "\n")
    cat("  Http status      :", httr::http_status(rdbes_api_result)$reason, "\n")
  }

  return(saving_file)

}
