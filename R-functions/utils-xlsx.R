#' Title
#'
#' Description
#'
#' @param file description
#' @param table_names description
#' @param unlist_single description
#'
#' @return result
#'
#' @export
#'
xlsx_read_tables <- function(file, table_names = NULL, unlist_single = TRUE) {

  sheet_names <- openxlsx::getSheetNames(file)

  if(!is.null(table_names)) {
    sheet_names <- base::intersect(sheet_names, table_names)
  }

  res <- lapply(sheet_names, function(x){
    openxlsx::read.xlsx(xlsxFile = file, sheet = x, detectDates = TRUE) |>
      dplyr::as_tibble()
  })

  names(res) <- sheet_names

  return(res)

}


#' Title
#'
#' Description
#'
#' @param tables description
#' @param file_name description
#' @param valid_fields description
#' @param halign description
#' @param use_format description
#'
#' @return result
#'
#' @export
#'
xlsx_save_tables <- function(tables, file_name = NULL, valid_fields = NULL, halign = "left", use_format = TRUE) {

  if("data.frame" %in% class(tables)) {
    tables <- list(tables)
    names(tables) <- "data"
  }

  n_tables <- length(tables)

  if(!is.null(valid_fields)){
    if(length(valid_fields) == 1) {
      valid_fields <- rep(valid_fields, n_tables)
    }
  }

  if(!is.null(file_name) && !dir.exists(dirname(file_name))) {
    dir.create(dirname(file_name), recursive = TRUE)
  }

  wb <- openxlsx::createWorkbook()

  for(k in seq(n_tables)) {
    
    if(is.null(valid_fields)){
      tmp_valid_field <- NULL
    }else{
      if(valid_fields[k] %in% names(tables[[k]])){
        tmp_valid_field <- valid_fields[k]
      }else{
        tmp_valid_field <- NULL
      }
    }
    
    if(use_format) {
      wb <- xlsx_add_single_table(wb, names(tables)[k], tables[[k]], col = "#83bafa", use_valid_field = tmp_valid_field, halign = halign)
    }else{
      openxlsx::addWorksheet(wb, names(tables)[k])
      openxlsx::writeData(wb, sheet = names(tables)[k], tables[[k]], colNames = TRUE, startRow = 1, startCol = 1)
    }
  
  }

  if(is.null(file_name)) {
    return(wb)
  }

  openxlsx::saveWorkbook(wb, file_name, overwrite = TRUE)

}


#' Title
#'
#' Description
#'
#' @param wb description
#' @param sheet_name description
#' @param data description
#' @param col description
#' @param use_valid_field description
#' @param halign description
#'
#' @return result
#'
#' @export
#'
xlsx_add_single_table <- function(wb, sheet_name, data, col = "#83bafa", use_valid_field = NULL, halign = "left") {

  col_light <- colorspace::lighten(col, amount = 0.7)

  header_style <- openxlsx::createStyle(
    fgFill = col, 
    textDecoration = "Bold",
    valign = "center", 
    halign = halign,
    border = "TopBottomLeftRight", 
    borderStyle = "medium", 
    borderColour = "#000000"
  )

  cell_style <- openxlsx::createStyle(
    fgFill = col_light,
    valign = "center", 
    halign = halign,
    border = "TopBottomLeftRight",
    borderStyle = "medium",
    borderColour = "#000000"
  )

  cell_style_valid <- openxlsx::createStyle(,
    fgFill = "#9fffb4",
    valign = "center", 
    halign = halign,
    border = "TopBottomLeftRight",
    borderStyle = "medium",
    borderColour = "#000000"
  )

  cell_style_unvalid <- openxlsx::createStyle(,
    fgFill = "#ffaa9f",
    valign = "center", 
    halign = halign,
    border = "TopBottomLeftRight",
    borderStyle = "medium",
    borderColour = "#000000"
  )

  nc <- ncol(data)
  nr <- nrow(data)

  openxlsx::addWorksheet(wb, sheet_name)

  options("openxlsx.minWidth" = 15)
  options("openxlsx.maxWidth" = 100)

  openxlsx::setColWidths(wb, sheet_name, cols = seq(1, nc), widths = "auto", ignoreMergedCells = FALSE)

  openxlsx::setRowHeights(wb, sheet_name, 1, 25)
  openxlsx::setRowHeights(wb, sheet_name, seq(2, nr+1), 20)

  openxlsx::addStyle(wb, sheet_name, style = cell_style, cols = seq(1, nc), rows = seq(2, nr+1), gridExpand = TRUE, stack = TRUE)
  openxlsx::writeData(wb, sheet = sheet_name, data, colNames = TRUE, startRow = 1, startCol = 1, headerStyle = header_style)

  if(!is.null(use_valid_field)) {
    if(!is.na(use_valid_field)) {

      valid_id = 1 + which(data[[use_valid_field]])
      unvalid_id = 1 + which(!data[[use_valid_field]])

      openxlsx::addStyle(wb, sheet_name, cell_style_valid, valid_id, cols = seq(1,nc), gridExpand = TRUE, stack = TRUE)
      openxlsx::addStyle(wb, sheet_name, cell_style_unvalid, unvalid_id, cols = seq(1,nc), gridExpand = TRUE, stack = TRUE)
      
    }
  }

  return(wb)

}


#' Title
#'
#' Description
#'
#' @param name description
#'
#' @return result
#'
#' @export
#'
xlsx_compute_column_merging_groups <- function(v) {
  
  current_value <- v[1]
  res <- c(1)
  
  for(k in seq(2, length(v))){
    if(is.na(v[k]) | v[k] != v[k-1]){
      res <- c(res, k)
    }
  }
  
  res <- c(res, length(v)+1)
  res <- cbind(res[-length(res)], res[-1]-1)

  return(res)

}


#' Title
#'
#' Description
#'
#' @param wb description
#' @param sheet description
#' @param id_cols description
#' @param offset description
#'
#' @return result
#'
#' @export
#'
xlsx_auto_merge_columns <- function(wb, sheet, id_cols, offset = 1) {
  
  table_data <- openxlsx::readWorkbook(wb, sheet) %>%
    dplyr::as_tibble()

  for(id_col in id_cols) {

    values <- table_data[,id_col] %>% 
      dplyr::pull()

    groups <- xlsx_compute_column_merging_groups(values)

    for(k in seq(nrow(groups))){
      openxlsx::mergeCells(wb, sheet, id_col, offset + c(groups[k,1], groups[k,2]))
    }

    openxlsx::setColWidths(wb, sheet, cols = id_col, widths = "auto", ignoreMergedCells = FALSE)

  }

  return(invisible(wb))

}