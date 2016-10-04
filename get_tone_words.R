library(dplyr)
category <- c("positive", "negative", "uncertainty",
                "litigious", "modal_strong", "modal_weak")
base_url <- "http://www3.nd.edu/~mcdonald/Data/Finance_Word_Lists/LoughranMcDonald_"
cats <- c("Positive", "Negative", "Uncertainty",
         "Litigious", "ModalStrong", "ModalWeak")
urls <- paste0(base_url, cats, ".csv")

getWords <- function(url) {

    library(readr)
    url %>%
        read_csv(col_names="words", col_types="c") %>%
        .[,1] %>%
        .[[1]] %>%
        paste(collapse=",")
}

df <-
    data_frame(category, urls) %>%
    rowwise %>%
    mutate(words=getWords(urls))

library(RPostgreSQL)

pg <- dbConnect(PostgreSQL())
rs <- dbWriteTable(pg, "lm_tone", df %>%  as.data.frame(), row.names=FALSE, overwrite=TRUE)

rs <- dbGetQuery(pg, "ALTER TABLE lm_tone ADD COLUMN word_list text[];")
rs <- dbGetQuery(pg, "UPDATE lm_tone SET word_list = regexp_split_to_array(words, ',')")
rs <- dbGetQuery(pg, "ALTER TABLE lm_tone DROP COLUMN words;")
rs <- dbDisconnect(pg)
