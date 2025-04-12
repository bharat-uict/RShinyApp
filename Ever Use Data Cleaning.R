setwd("C:/Users/Bharat.Wagh/OneDrive - FDA/Desktop/Personal Documents/R Shiny/Ver 2")

# Load necessary libraries
library(readxl)
library(writexl)

# Load the data from the Excel file
df <- read_excel("ever_use_1.xlsx")

# Check the structure of the data to identify High school and Middle school rows
head(df)

# Manually separate the rows for High School and Middle School students
high_school_df <- df[1:13, ]  # Manually select the rows for high school students
middle_school_df <- df[14:nrow(df), ]  # The remaining rows for middle school students

# Function to extract percentage and CI (lower and upper)
extract_percentage_and_ci <- function(value) {
  parts <- unlist(strsplit(value, "\n"))
  percentage <- trimws(parts[1])  # Extract percentage
  ci <- if(length(parts) > 1) {
    ci_values <- strsplit(gsub("[()]", "", parts[2]), "–")[[1]]
    if(length(ci_values) == 2) {
      return(c(percentage, ci_values[1], ci_values[2]))  # Normal case with lower and upper CI
    } else {
      return(c(percentage, NA, NA))  # If CI is malformed, return NA
    }
  } else {
    return(c(percentage, NA, NA))  # If no CI available
  }
}

# Apply the function to the 'Female' and 'Male' columns for both dataframes
high_school_df[c("Female_Percentage", "Female_Lower_CI", "Female_Upper_CI")] <- 
  t(apply(high_school_df['Female'], 1, function(x) extract_percentage_and_ci(x)))

high_school_df[c("Male_Percentage", "Male_Lower_CI", "Male_Upper_CI")] <- 
  t(apply(high_school_df['Male'], 1, function(x) extract_percentage_and_ci(x)))

middle_school_df[c("Female_Percentage", "Female_Lower_CI", "Female_Upper_CI")] <- 
  t(apply(middle_school_df['Female'], 1, function(x) extract_percentage_and_ci(x)))

middle_school_df[c("Male_Percentage", "Male_Lower_CI", "Male_Upper_CI")] <- 
  t(apply(middle_school_df['Male'], 1, function(x) extract_percentage_and_ci(x)))

# Drop the original 'Female' and 'Male' columns
high_school_df <- high_school_df[, !names(high_school_df) %in% c("Female", "Male")]
middle_school_df <- middle_school_df[, !names(middle_school_df) %in% c("Female", "Male")]

# Drop first row

high_school_df <- high_school_df[-1,]
middle_school_df <- middle_school_df[-1,]

high_school_df[[1]] <- gsub("[^[:alnum:] ]", "", high_school_df[[1]])
middle_school_df[[1]] <- gsub("[^[:alnum:] ]", "", middle_school_df[[1]])

# Save the data into two separate sheets in an Excel file
write_xlsx(list("High School Students" = high_school_df, 
                "Middle School Students" = middle_school_df), 
           "Ever_High_and_Middle_School_Students_Separated.xlsx")
