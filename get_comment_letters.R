# Some functions to download comment letters ----
readPDF <- function(url) {

    # Download PDF
    library(curl)
    t <- tempfile()
    curl::curl_download(url, t)

    # Create a .txt file from PDF (requires installation of a free program)
    system(paste("pdftotext", t), intern=TRUE)

    # Read text and remove pagebreaks from text
    text <- paste(readLines(paste0(t, ".txt"), warn = FALSE), collapse="\n")
    gsub("\f", "\n", text)
}

getFilingURL <- function(file_name) {
     file.path("http://www.sec.gov/Archives",
               gsub("(\\d{10})-(\\d{2})-(\\d{6})\\.txt", "\\1\\2\\3", file_name),
               "filename1.pdf")

}

getCommentLetter <- function(file_name) {
    url <- getFilingURL(file_name)
    readPDF(url)
}

# Get a list of 100 comment letters submitted by the SEC ----
library(dplyr)
Sys.setenv(PGHOST = "iangow.me", PGDATABASE = "crsp")
pg <- src_postgres()
filings <- tbl(pg, sql("SELECT * FROM filings.filings"))

com_letts <-
    filings %>%
    filter(form_type=='UPLOAD') %>%
    collect(n=10) %>%
    rowwise() %>%
    mutate(text=getCommentLetter(file_name))

library(RPostgreSQL)
dbWriteTable(pg$con, "comment_letters", com_letts %>% as.data.frame(),
             overwrite=TRUE, row.names=FALSE)
