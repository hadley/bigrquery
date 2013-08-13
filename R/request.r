base_url <- "https://www.googleapis.com/bigquery/v2/"

#' @importFrom httr GET config
bq_get <- function(url, config = NULL, ..., sig = get_sig()) {
  if (is.null(config)) {
    config <- config()
  }
  config <- c(config, sig)
  req <- GET(paste0(base_url, url), config, ...)
  process_request(req)
}

#' @importFrom httr POST add_headers config
#' @importFrom RJSONIO toJSON
bq_post <- function(url, body, config = NULL, ..., sig = get_sig()) {
  if (is.null(config)) {
    config <- config()
  }
  json <- toJSON(body)
  config <- c(config, sig, add_headers("Content-type" = "application/json"))

  req <- POST(paste0(base_url, url), config, body = json, ...)
  process_request(req)
}

#' @importFrom httr http_status content parse_media
process_request <- function(req) {
  if (http_status(req)$category == "success") {
    return(content(req, "parsed", "application/json"))
  }

  type <- parse_media(req$headers$`Content-type`)
  if (type$complete == "application/json") {
    out <- content(req, "parsed", "application/json")
    stop(out$err$message, call. = FALSE)
  } else {
    out <- content(req, "text")
    stop("HTTP error [", req$status, "] ", out, call. = FALSE)
  }
}
