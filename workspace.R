library(tercen)
library(dplyr)
library(ijtiff)

library(tim)
# http://127.0.0.1:5402/test-team/w/cc41c236da58dcb568c6fe1a320140d2/ds/fc1751eb-fe65-4c62-875f-c32339f6bdbb
# Set appropriate options
#options("tercen.serviceUri"="http://tercen:5400/api/v1/")
options("tercen.workflowId"= "cc41c236da58dcb568c6fe1a320140d2")
options("tercen.stepId"= "fc1751eb-fe65-4c62-875f-c32339f6bdbb")


TAG_LIST  <- list("date_time" = "DateTime", "barcode" = "Barcode", "col" = "Col", "cycle" = "Cycle", "exposure time" = "Exposure Time", "filter" = "Filter", 
                  "ps12" = "PS12", "row" = "Row", "temperature" = "Temperature", "timestamp" = "Timestamp", "instrument unit" = "Instrument Unit", "run id" = "RunId")
TAG_NAMES <- as.vector(unlist(TAG_LIST))
IMAGE_COL <- "Image"

get_file_tags <- function(filename) {
  tags <- NULL
  all_tags <- ijtiff::read_tags(filename)
  if (!is.null(all_tags) && !is.null(names(all_tags)) && "frame1" %in% names(all_tags)) {
    tags <- all_tags$frame1
    tags <- tags[names(TAG_LIST)]
    tags <- lapply(tags, FUN = function(x) ifelse(is.null(x), "", x))
    names(tags) <- TAG_NAMES
  }
  tags
}


doc_to_data <- function(df){
  #1. extract files
  docId = df$documentId[1]
  
  f.names <- tim::load_data(ctx, docId, force_load=FALSE)
  f.names <- grep('*/ImageResults/*', f.names, value = TRUE )

  # read tags
  result <- do.call(rbind, lapply(f.names, FUN = function(filename) {
    tags <- get_file_tags(filename)
    
    # image
    filename_parts <- unlist(strsplit(filename, "/"))
    image <- gsub(".tif", "", filename_parts[length(filename_parts)])
    names(image) <- IMAGE_COL
    
    as.data.frame(t(as.data.frame(c(image, unlist(tags)))))
  }))
  
  result %>% 
    mutate(path = "ImageResults") %>% 
    mutate(documentId = docId) %>%
    mutate_at(vars(Col, Cycle, 'Exposure Time', Row, Temperature), .funs = function(x) { as.numeric(as.character(x)) }) %>%
    select(documentId, path, all_of(IMAGE_COL), all_of(TAG_NAMES))
}

ctx = tercenCtx()

if (!any(ctx$cnames == "documentId")) stop("Column factor documentId is required") 

ctx$cselect() %>%
  doc_to_data() %>%
  mutate(.ci = 0, .ri = 0) %>%
  ctx$addNamespace() %>%
  ctx$save()