#' Title
#'
#' Description
#'
#' @return result
#'
#' @export
#'
path_system_boot <- function() {

  path <- list(
    rdbes = "./boot/data/RDBES",
    references = "./boot/data/REFERENCES",
    ices_stocks = "./boot/data/referentiel_stocks_ices.xlsx"
  )

  return(path)

}


#' Title
#'
#' Description
#'
#' @param stock_infos description
#' @param years description
#'
#' @return result
#'
#' @export
#'
path_system_stock <- function(stock_infos, years) {

  sub_folder <- paste(stock_infos$EXPERT_GROUP, stock_infos$STOCK_NAME, sep = "/")

  res <- list(
    data = paste("data", sub_folder, sep = "/"),
    model = paste("model", sub_folder, sep = "/"),
    output = paste("output", sub_folder, sep = "/"),
    report = paste("report", sub_folder, sep = "/")
  )

  folder_name <- paste(range(years), collapse = "-")

  res$output_series <- paste(res$output, folder_name, sep = "/")

  return(res)

}