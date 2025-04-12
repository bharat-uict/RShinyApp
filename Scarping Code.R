setwd("C:/Users/Bharat.Wagh/OneDrive - FDA/Desktop/Personal Documents/R Shiny/Ver 2")

install.packages(c("rvest", "dplyr", "tidyr", "stringr", "janitor", "writexl"))

library(rvest)
library(dplyr)
library(tidyr)
library(stringr)
library(janitor)
library(writexl)

# load the webpage

url <- "https://www.cdc.gov/mmwr/volumes/73/wr/mm7341a2.htm?s_cid=mm7341a2_w"
page <- read_html(url)

# Scrape Table 1 and Table 2

tables <- page %>% html_elements("table")
table1 <- tables[[1]] %>% html_table(fill = TRUE)
table2 <- tables[[2]] %>% html_table(fill = TRUE)

# Set proper headers from row 2 (assuming row 1 is "Sex", "Race and ethnicity", etc.)
table1_raw <- as.data.frame(table1)
table2_raw <- as.data.frame(table2)


# Use second row as headers
colnames(table1_raw) <- table1_raw[2, ]
colnames(table2_raw) <- table2_raw[2, ]

# Remove the first 2 rows (merged header info)
table1_clean <- table1_raw[-c(1, 2), ]
table2_clean <- table2_raw[-c(1, 2), ]

# Rename first column
names(table1_clean)[1] <- "tobacco_product"
names(table2_clean)[1] <- "tobacco_product"

table1_clean = table1_clean[,-c(4:11)]
table2_clean = table2_clean[,-c(4:10)]

rownames(table1_clean) = NULL
rownames(table2_clean) = NULL

table1_clean <- table1_clean[-c(1:13), ]
rownames(table1_clean) <- NULL


table2_clean <- table2_clean[-c(1:13), ]
rownames(table2_clean) <- NULL

write_xlsx(table1_clean, "ever_use_1.xlsx")
write_xlsx(table2_clean, "current_use_1.xlsx")
