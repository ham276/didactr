
# get script path and number of paragraphs
paragraph_from_script <- function(x) {
  if (file.exists(x)) {
    para = readLines(x, warn = FALSE)
    para = trimws(para)
    para = para[!para %in% c("", " ")]
    return(para)
  } else{
    return(NA)
  }
}

n_para = function(x) {
  x = paragraph_from_script(x)
  ifelse(all(is.na(x)), NA, length(x))
}

length0 = function(x) {
  length(x) == 0
}

length0_to_NA = function(x) {
  if (length0(x)) {
    x <- NA
  }
  x
}


drive_information = function(id,
                             timezone = "America/New_York",
                             ...) {
  name = gs_name = NULL
  rm(list = c("name", "gs_name"))

  authorized = check_didactr_auth(...)
  drive_info = googledrive::drive_get(id = id)

  if (nrow(drive_info) > 0) {
    drive_info = drive_info %>%
      rename(gs_name = name) %>%
      mutate(course_info = gs_name)

    mod_time_gs = sapply(drive_info$drive_resource,
                         function(x) {
                           x$modifiedTime
                         })
    drive_info$mod_time_gs = lubridate::ymd_hms(
      mod_time_gs)
    drive_info$mod_time_gs = lubridate::with_tz(
      drive_info$mod_time_gs,
      tzone = timezone)
    drive_info$drive_resource = NULL
  } else {
    return(NULL)
  }
  return(drive_info)
}



gs_id_from_slide = function(fname) {
  if (!file.exists(fname)) {
    return(NA)
  }
  x = readLines(fname, warn = FALSE)
  x = grep(x, pattern = "\\[(S|s)lides\\]", value = TRUE)
  x = sub(".*\\((http.*)\\).*", "\\1", x)
  x = unlist(sapply(x, function(r) parse_url(r)$path))
  x = sub("/edit$", "", x)
  x = basename(x)
  x = unique(x)
  if (length(x) > 1) {
    warning(paste0("Multiple sheets identified! Taking first.",
                   "  Please check ",
                   fname))
    x = x[1]
  }
  if (length(x) == 0 || grepl("\\(\\)", x)) {
    return(NA)
  }
  return(x)
}

######################################
# this returns the actual links in the text
######################################
get_image_link_from_slide = function(fname) {
  x = readLines(fname, warn = FALSE)
  x = grep(x, pattern = "!\\[.*\\]\\((images.*)\\)", value = TRUE)
  x = sub(x, pattern = "!\\[(.*)\\]\\((images.*)\\)", replacement = "\\1")
  return(x)
}

######################################
# this returns the actual image filenames referenced
# we will check to see if all images referenced exist
######################################
get_image_from_slide = function(fname) {
  x = readLines(fname, warn = FALSE)
  x = grep(x, pattern = "!\\[.*\\]\\((images.*)\\)", value = TRUE)
  x = sub(x, pattern = "!\\[.*\\]\\((images.*)\\)", replacement = "\\1")
  return(x)
}


list_one_file = function(x, ending = "pdf") {
  pdfs = list.files(
    pattern = paste0("[.]", ending),
    path = x,
    full.names = TRUE)
  if (length(pdfs) > 1) {
    warning(paste0(x, " had more than one ", ending, "! ",
                   "Only grabbing first"))
    pdfs = pdfs[1]
  }
  pdfs = length0_to_NA(pdfs)
  return(pdfs)
}



mod_time_to_tz_time = function(x, timezone) {
  mod_times = file.info(x)$mtime
  mod_times = lubridate::ymd_hms(mod_times, tz = Sys.timezone())
  mod_times = lubridate::with_tz(mod_times, tzone = timezone)
  return(mod_times)
}





png_pattern = function() {
  paste0("^!\\[.+\\]\\((?!\\.png)\\)|",
         "^!\\[\\]\\((?!\\.png)\\)|",
         "^!\\[.+\\]\\((?!\\.png)\\)|",
         "!\\[.+\\]\\(.+[^.png]\\)|",
         "^!\\[.+\\]\\(https\\:\\/\\/www\\.youtu.+\\)")
}


is.Token = function(token) {
  inherits(token, "Token")
}


na_false = function(test) {
  test[ is.na(test)] = FALSE
  test
}

na_true = function(test) {
  test[ is.na(test)] = TRUE
  test
}