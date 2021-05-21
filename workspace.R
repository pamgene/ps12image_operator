library(tercen)
library(dplyr)
library(ijtiff)

# Set appropriate options
#options("tercen.serviceUri"="http://tercen:5400/api/v1/")
#options("tercen.workflowId"= "050e773677ecc404aa5d5a7580016b7d")
#options("tercen.stepId"= "6a509b68-33a3-4397-9b9c-12696ce2ffac")
#options("tercen.username"= "admin")
#options("tercen.password"= "admin")

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
  doc = ctx$client$fileService$get(docId)
  filename = tempfile()
  writeBin(ctx$client$fileService$download(docId), filename)
  on.exit(unlink(filename))
  
  # unzip if archive
  if(length(grep(".zip", doc$name)) > 0) {
    tmpdir <- tempfile()
    unzip(filename, exdir = tmpdir)
    f.names <- list.files(file.path(list.files(tmpdir, full.names = TRUE), "ImageResults"), full.names = TRUE)
  } else {
    f.names <- filename
  }
  
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