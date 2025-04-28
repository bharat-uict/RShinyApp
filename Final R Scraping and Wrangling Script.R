setwd("C:/Users/bhara/OneDrive/Desktop/Biostatistics/R Course/R Shiny")

# R Code to scrape a table from a website

# Installing the required libraries
install.packages(c("rvest", "dplyr", "tidyr", "stringr", "janitor",
                   "writexl"))


# Loading the libraries

library(rvest)
library(dplyr)
library(tidyr)
library(stringr)
library(janitor)
library(writexl)

# Loading the webpage

url <- "https://www.cdc.gov/mmwr/volumes/73/wr/mm7341a2.htm?s_cid=mm7341a2_w"
page <- read_html(url)

# Scrape Table 1 and Table 2

tables <- page %>% html_elements("table")
table1 <- tables[[1]] %>% html_table(fill = TRUE)
table2 <- tables[[2]] %>% html_table(fill = TRUE)


# Set proper headers from row 2

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

# Retain only the tobacco_product, gender and estimated total cols

table1_clean <- table1_clean[,-c(4:11)]
table2_clean <- table2_clean[,-c(4:10)]

# Resetting the indices

rownames(table1_clean) <- NULL
rownames(table2_clean) <- NULL

# Removing the 'overall' section of the data & resetting indices

table1_clean <- table1_clean[-c(1:13), ]
rownames(table1_clean) <- NULL


table2_clean <- table2_clean[-c(1:13), ]
rownames(table2_clean) <- NULL

# Writing data to .xlsx to maintain a copy

write_xlsx(table1_clean, "ever_use_1.xlsx")
write_xlsx(table2_clean, "current_use_1.xlsx")

# Data Wrangling of table1_clean i.e., ever used tobacco
# Data Wrangling of table2_clean i.e., current use tobacco

# Rename table1_clean to ever_use

ever_use <- table1_clean

current_use <- table2_clean

# Removing special characters from the data frame

ever_use_clean <- ever_use

current_use_clean <- current_use

ever_use_clean[] <- lapply(ever_use_clean, function(x) {
  if (is.character(x)) {
    gsub("[¶§†]", "", x)
  } else {
    x
  }
})

current_use_clean[] <- lapply(current_use_clean, function(x) {
  if (is.character(x)) {
    gsub("[¶§†]", "", x)
  } else {
    x
  }
})

# Renaming the last column

names(ever_use_clean)[4] <- "estimated_total"

names(current_use_clean)[4] <- "estimated_total"

# Removing rows 1 and 14

ever_use_clean <- ever_use_clean[-c(1,14), ]
rownames(ever_use_clean) <- NULL

current_use_clean <- current_use_clean[-c(1,14), ]
rownames(current_use_clean) <- NULL


# Extracting the 95% CI values from the parenthesis into new cols

ever_use_clean <- ever_use_clean %>%
  mutate(
    # Extract and create new CI columns
    CI_95_min_male = as.numeric(str_extract(Male, "(?<=\\().*?(?=–)")),
    CI_95_max_male = as.numeric(str_extract(Male, "(?<=–).*?(?=\\))")),
    
    CI_95_min_female = as.numeric(str_extract(Female, "(?<=\\().*?(?=–)")),
    CI_95_max_female = as.numeric(str_extract(Female, "(?<=–).*?(?=\\))")),
    
    # Clean Male and Female columns by removing parentheses and inside values
    Male = as.numeric(str_remove(Male, "\\s*\\(.*\\)")),
    Female = as.numeric(str_remove(Female, "\\s*\\(.*\\)"))
  )


current_use_clean <- current_use_clean %>%
  mutate(
    # Extract and create new CI columns
    CI_95_min_male = as.numeric(str_extract(Male, "(?<=\\().*?(?=–)")),
    CI_95_max_male = as.numeric(str_extract(Male, "(?<=–).*?(?=\\))")),
    
    CI_95_min_female = as.numeric(str_extract(Female, "(?<=\\().*?(?=–)")),
    CI_95_max_female = as.numeric(str_extract(Female, "(?<=–).*?(?=\\))")),
    
    # Clean Male and Female columns by removing parentheses and inside values
    Male = as.numeric(str_remove(Male, "\\s*\\(.*\\)")),
    Female = as.numeric(str_remove(Female, "\\s*\\(.*\\)"))
  )



# Converting tobacco product column into a factor

ever_use_clean$tobacco_product <- as.factor(ever_use_clean$tobacco_product)

current_use_clean$tobacco_product <- 
  as.factor(current_use_clean$tobacco_product)

# Converting estimated_total column into numeric

ever_use_clean$estimated_total <- ever_use_clean$estimated_total %>%
  str_remove_all(",") %>%   # Remove all commas
  as.numeric()              # Convert to numeric


current_use_clean$estimated_total <- current_use_clean$estimated_total %>%
  str_remove_all(",") %>%   # Remove all commas
  as.numeric()              # Convert to numeric


# Rearranging columns


ever_use_clean <- ever_use_clean %>%
  select(tobacco_product, Female, CI_95_min_female, CI_95_max_female, 
         Male, CI_95_min_male, CI_95_max_male, estimated_total)


current_use_clean <- current_use_clean %>%
  select(tobacco_product, Female, CI_95_min_female, CI_95_max_female, 
         Male, CI_95_min_male, CI_95_max_male, estimated_total)

# Dividing into High School and Middle School Data

ever_use_clean_hs <- ever_use_clean[c(1:12), ]
ever_use_clean_ms <- ever_use_clean[c(13:24), ]

current_use_clean_hs <- current_use_clean[c(1:12), ]
current_use_clean_ms <- current_use_clean[c(13:24), ]

# Writing to xlsx to maintain a copy

write_xlsx(ever_use_clean_hs, "ever_use_clean_hs.xlsx")
write_xlsx(ever_use_clean_ms, "ever_use_clean_ms.xlsx")

write_xlsx(current_use_clean_hs, "current_use_clean_hs.xlsx")
write_xlsx(current_use_clean_ms, "current_use_clean_ms.xlsx")


