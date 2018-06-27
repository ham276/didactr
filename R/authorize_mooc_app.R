mooc_app = function() {
  httr::oauth_app(
    appname = "mooc-generator",
    key = "299711289983-km4ktlcq0mc81e5trravudt8sqcqfl3k.apps.googleusercontent.com",
    secret = "gfA5FKtuKbYP4eOFDrIFD0yt",
    redirect_uri = "http://localhost:1410/"
  )
}

#' Authorize Application for didactr
#'
#' @param cache A logical value or a string. \code{TRUE} means to cache
#' using the default cache file \code{.httr-oauth}
#' @param use_oob use a local webserver for the OAuth dance
#' @param token_file If the \code{token} has been saved, use this file
#' to load the credentials.
#'
#' @return The auth token, a Token class.
#' @export
#'
#' @importFrom httr oauth_endpoints oauth2.0_token
#' @importFrom googledrive drive_auth
#' @examples \dontrun{
#' didactr_auth()
#' }
didactr_auth = function(
  token_file = NULL,
  cache = FALSE,
  use_oob = FALSE) {

  if (is.null(token_file)) {
    token_file = tempfile(fileext = ".rds")
  }
  if (!file.exists(token_file)) {
    cred <- httr::oauth2.0_token(
      endpoint = httr::oauth_endpoints("google"),
      app = mooc_app(),
      scope = c("https://www.googleapis.com/auth/drive",
                "https://www.googleapis.com/auth/youtube.force-ssl",
                "https://www.googleapis.com/auth/presentations"),
      cache = cache,
      use_oob = use_oob)
  } else {
    cred = readRDS(token_file)
  }

  # for tuber
  options(google_token = cred)
  saveRDS(cred, token_file)
  googledrive::drive_auth(oauth_token = token_file)
  return(invisible(cred))
}


#' @param ... Arguments passed to \code{\link{didactr_auth}}
#' @rdname didactr_auth
#' @export
check_didactr_auth = function(...) {
  token = getOption("google_token")
  if (is.Token(token)) {
    appname = token$app$appname
    if (appname != mooc_app()$appname) {
      token = didactr_auth(...)
    }
    args = list(...)
    token_file = args$token_file
    if (is.null(token_file)) {
      token_file = tempfile(fileext = ".rds")
    }
    saveRDS(token, token_file)
    googledrive::drive_auth(oauth_token = token_file)
  } else {
    token = didactr_auth(...)
  }
  return(is.Token(token))
}