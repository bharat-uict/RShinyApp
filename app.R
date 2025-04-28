# Load libraries
library(shiny)
library(ggplot2)
library(dplyr)
library(readxl)

# UI
ui <- fluidPage(
  
  titlePanel("Tobacco Product Use Among Students - NYTS 2024"),
  
  sidebarLayout(
    sidebarPanel(
      h4("Select Options"),
      
      selectInput("use_type", "Tobacco Use Category:",
                  choices = c("Ever Used Tobacco Products", "Current Use of Tobacco Products")),
      
      selectInput("school_level", "School Level:",
                  choices = c("High School", "Middle School")),
      
      uiOutput("product_selector"),
      
      radioButtons("gender", "Select Group to Plot:",
                   choices = c("Female", "Male"))
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Table View", tableOutput("data_table")),
        tabPanel("Plot View", plotOutput("bar_plot"))
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Load all four datasets
  ever_hs <- read_excel("ever_use_clean_hs.xlsx")
  ever_ms <- read_excel("ever_use_clean_ms.xlsx")
  current_hs <- read_excel("current_use_clean_hs.xlsx")
  current_ms <- read_excel("current_use_clean_ms.xlsx")
  
  # Dataset selection logic
  selected_data <- reactive({
    req(input$use_type, input$school_level)
    
    if (input$use_type == "Ever Used Tobacco Products" && input$school_level == "High School") {
      ever_hs
    } else if (input$use_type == "Ever Used Tobacco Products" && input$school_level == "Middle School") {
      ever_ms
    } else if (input$use_type == "Current Use of Tobacco Products" && input$school_level == "High School") {
      current_hs
    } else {
      current_ms
    }
  })
  
  # Generate product checkboxes dynamically
  output$product_selector <- renderUI({
    data <- selected_data()
    checkboxGroupInput("products", "Select Tobacco Products:",
                       choices = unique(data$tobacco_product),
                       selected = unique(data$tobacco_product))
  })
  
  # Filter based on selected products
  filtered_data <- reactive({
    req(selected_data(), input$products)
    selected_data() %>% filter(tobacco_product %in% input$products)
  })
  
  # Render Table
  output$data_table <- renderTable({
    filtered_data()
  })
  
  # Render Plot
  output$bar_plot <- renderPlot({
    data <- filtered_data()
    req(nrow(data) > 0)
    
    y_var <- if (input$gender == "Female") "Female" else "Male"
    ci_lower <- if (input$gender == "Female") "CI_95_min_female" else "CI_95_min_male"
    ci_upper <- if (input$gender == "Female") "CI_95_max_female" else "CI_95_max_male"
    
    data_clean <- data %>%
      mutate(
        y_value = as.numeric(.data[[y_var]]),
        y_min = as.numeric(.data[[ci_lower]]),
        y_max = as.numeric(.data[[ci_upper]])
      )
    
    ggplot(data_clean, aes(x = tobacco_product, y = y_value)) +
      geom_col(fill = "lightblue", color = "black") +  # lighter color
      geom_errorbar(aes(ymin = y_min, ymax = y_max), width = 0.2, size = 1) +  # thicker error bars
      geom_text(aes(label = paste0("Est: ", estimated_total)), 
                vjust = -2, size = 3.5, color = "red", fontface = "bold") +  # text higher and bold
      labs(x = "Tobacco Product", y = "Percentage (%)", 
           title = paste(input$school_level, "-", input$use_type, "-", input$gender)) +
      theme_minimal(base_size = 14) +
      theme(
        axis.text.x = element_text(angle = 60, hjust = 1, size = 10, 
                                   face = "bold"),
        axis.text.y = element_text(size = 12),
        plot.title = element_text(hjust = 0.5, size = 16, face = "bold")
      )
  })
}

# Run the app
shinyApp(ui = ui, server = server)