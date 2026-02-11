
#' Title
#'
#' Description
#'
#' @param path_outputs description
#'
#' @return result
#'
#' @export
#'
DATA_API_get_wgcatch_annex1 <- function(path_outputs) {

  doi <- "https://doi.org/10.17895/ices.pub.30939734"
  id <- sub("https://doi.org/10.17895/ices.pub.", "", doi)

  datacall <- jsonlite::read_json(paste0("https://api.figshare.com/v2/articles/", id))

  annex1_info <- datacall$files[[grep("Annex_1", sapply(datacall$files, "[[", "name"))]]

  file_output <- paste0(path_outputs, "/", annex1_info$name)

  TAF::download(annex1_info$download_url, destfile = annex1_info$name)

  res <- xlsx_read_tables(file_output)

  return(invisible(res))

}
