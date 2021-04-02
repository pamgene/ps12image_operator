library(tercen)
library(dplyr)

# options("tercen.serviceUri"="http://tercen:5400/api/v1/")
# options("tercen.workflowId"= "050e773677ecc404aa5d5a7580016b7d")
# options("tercen.stepId"= "712a71ec-3fa3-49c6-820e-655a7a25e20f")
# options("tercen.username"= "admin")
# options("tercen.password"= "admin")

TAG_NAMES <- c("DateTime", "Barcode", "Col", "Cycle", "Exposure Time", "Filter", "PS12", "Row", "Temperature", "Timestamp", "Instrument unit", "Protocol ID")
IMAGE_COL <- "Image"

get_file_tags <- function(filename) {
  tag_dump <- system(paste0("tiffdump '", filename, "'"), intern = TRUE)
  tags     <- tag_dump[grepl("^DateTime|650", tag_dump)]
  tags     <- unlist(lapply(tags, FUN = function(tag) {
    tag_name <- unlist(strsplit(tag, " "))[1]
    tag_value <- unlist(strsplit(tag, "<"))[2]
    res <- substr(tag_value, 1, nchar(tag_value) - 3)
    names(res) <- tag_name
    res
  }))
  # replace names
  names(tags) <- TAG_NAMES
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
  result <- do.call(rbind, lapply(f.names[1:10], FUN = function(filename) {
    tags <- get_file_tags(filename)
    
    # image
    filename_parts <- unlist(strsplit(filename, "/"))
    image <- gsub(".tif", "", filename_parts[length(filename_parts)])
    names(image) <- IMAGE_COL
    
    # merge result
    as.data.frame(t(as.data.frame(c(image, tags))))
  })) 
  result %>% 
    mutate(path = "ImageResults") %>% 
    mutate(documentId = docId) %>%
    select(documentId, path, IMAGE_COL, TAG_NAMES)
}

ctx = tercenCtx()

if (!any(ctx$cnames == "documentId")) stop("Column factor documentId is required") 

ctx$cselect() %>%
  doc_to_data() %>%
  ctx$addNamespace() %>%
  ctx$save()