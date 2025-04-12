# R Shiny App: Youth Tobacco Product Use – NYTS 2024

An interactive R Shiny application visualizing tobacco product use among U.S. middle and high school students, based on 2024 data from the CDC’s National Youth Tobacco Survey (NYTS).

---

## Project Overview

This project extracts, cleans, and visualizes data from the following CDC report:

📄 [Tobacco Product Use Among Middle and High School Students — United States, 2024](https://www.cdc.gov/mmwr/volumes/73/wr/mm7341a2.htm?s_cid=mm7341a2_w)

The final goal is to develop a web-based tool to explore usage statistics for various tobacco products (e.g., e-cigarettes, hookahs, cigarettes) across student demographics.

---

## Data Extracted

The following tables were scraped from the CDC MMWR HTML report:

- Table 1: Percentage of students who have **ever used** tobacco products.
- Table 2: Percentage of students who have **used tobacco products in the past 30 days** ("current use").

---

## Data Cleaning & Transformation

The raw tables were processed as follows:

- Merged header rows were resolved; proper column names assigned.
- Only data stratified by gender and school level (Middle School and High School) was retained.
- All Race and ethnicity sections and columns were excluded.
- Percentage estimates and 95% confidence intervals (CIs) were parsed for visualization.
- Data was reshaped to a tidy format, facilitating use in `ggplot2` and `shiny`.

---

## Shiny App Goals

The Shiny app (in development) will allow users to:

- Filter data by:
  - Use type: _Ever used_ vs. _Current use_
  - School level: _Middle School_ vs. _High School_
- Visualize usage rates for each product type with **error bars** (95% CI)
- Hover over bars to see the estimated total number of students (computed from weighted percentages and national enrollment estimates)




