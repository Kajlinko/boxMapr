#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(dplyr)
library(readxl)
library(purrr)
library(tidyr)
library(stringr)


source("R/utils.R")

# Define UI for the application
ui <- fluidPage(
  titlePanel("boxMapr"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Choose Excel file", accept = c(".xlsx")),
      tags$hr(),
      uiOutput("file_info"),
      textInput("study_id", "Choose study prefix", value = "",
                placeholder = "eg. IMPAC"),
      textInput("sample_type", "Sample type", value = "", 
                placeholder = "eg. Plasma / Cytodelics")
    ),
    mainPanel(
      h3("Data View"),
      tabsetPanel(
        tabPanel("Boxes", tableOutput("boxes_ui")),
        tabPanel("Find Aliquots", 
                 textInput("sample_filter", "Filter by sample ID or timepoint", 
                           value = "", 
                           placeholder = "eg. IMPAC200 or 1M"),
                 tableOutput("index_display")),
        tabPanel("No. Aliquots", tableOutput("aliquots")),
        tabPanel("Search", 
                 textInput("search", "Enter participant ID", value = "", 
                           placeholder = "eg. IMPAC201"),
                 uiOutput("dynamic_timepoints"),
                 verbatimTextOutput("search_result"))
        
      )
    )
  )
)


server <- function(input, output) {
  output$file_info <- renderUI({
    req(input$file)
    tags$div(
      tags$p("File uploaded: ", input$file$name),
      tags$p("File size: ", input$file$size, " bytes")
    )
  })
  
  ## EXTRACT BOX DATA FROM EXCEL FILES
  data <- reactive({
    req(input$file)
    sheets <- readxl::excel_sheets(input$file$datapath)
    
    box_list <- lapply(sheets, FUN = function(sheet) {
      box_list <- list()
      xl <- readxl::read_xlsx(input$file$datapath, sheet = sheet, 
                              col_names = FALSE)
      box_list <- append(box_list, xl)
      return(box_list)
    })
    names(box_list) <- sheets
    
    for(box in seq_along(box_list)) {
      box_list[[box]] <- as.data.frame(box_list[[box]])
    }
    
    for(box in seq_along(box_list)) {
      if(ncol(box_list[[box]]) == 9) {
        colnames(box_list[[box]]) <- 1:9
        nr <- 1:nrow(box_list[[box]])
        rn <- 1 + 9*(nr-1)
        rownames(box_list[[box]]) <- rn
      } else if(ncol(box_list[[box]]) == 12) {
        colnames(box_list[[box]]) <- LETTERS[1:12]
        rownames(box_list[[box]]) <- 1:nrow(box_list[[box]])
      } else {
        colnames(box_list[[box]] <- 1:ncol(box_list[[box]]))
        rownames(box_list[[box]] <- NULL)
      }
    }
    
    prefix <- input$study_id
    box_list <- lapply(box_list, prepend_df, prefix)
    
    box_list
    
  })
  
  ## COMPUTE BOX INFORMATION FOR DISPLAYS
  box_data <- reactive({
    get_data_from_boxes(data())
  })
  
  ## SEARCHING FOR ALIQUOTS
  # dynamically display all timepoints
  output$dynamic_timepoints <- renderUI({
    radioButtons("timepoints", "Select which time point", 
                 choices = box_data()$box_times)
  })
  
  search_result <- reactive({
    req(input$search, input$timepoints)
    find_index_in_dfs(data(), paste(input$search, input$timepoints))
  })
  
  output$search_result <- renderPrint({
    search_result()
  })
 
  output$aliquots <- renderTable({
    req(box_data())
    box_data()[[3]]
  })
  
  ## BOX DISPLAY
  # generate UI for box display dynamically
  output$boxes_ui <- renderUI({
    req(data())
    lapply(names(data()), function(box_name) {
      box_table <- data()[[box_name]]
      tagList(
        h4(paste0(input$sample_type, " ", box_name)),
        #if(is.null(rownames(data()[[box_name]]))){
        #  h5("This box may be disorganised. Review and consider consolidating.")
        #},
        tableOutput(paste0("table_", box_name))
      )
    })
  })
  
  # render tables for each box
  observe({
    req(data())
    lapply(names(data()), function(box_name) {
      output[[paste0("table_", box_name)]] <- renderTable({
        data()[[box_name]]
      }, rownames = TRUE)
    })
  })
  
  ## GENERATE INDEX DATAFRAME
  # generate table of indices
  df_indices <- reactive({
    req(data())
    req(box_data())
    
    index_lists <- lapply(box_data()[[1]], function(target) {
      find_indices_in_dfs(data(), target)
    })
    
    names(index_lists) <- box_data()[[1]]
    
    df_indices <- convert_list_to_df(index_lists)
    df_indices <- arrange(df_indices, sample)
    
    df_indices
  })
  
  # display table of indices
  output$index_display <- renderTable({
    req(df_indices)
    order_df(filter_data(df_indices(), input$sample_filter))
  })
  
}

# Run the application
shinyApp(ui = ui, server = server)

## still to do: import and concatenate multiple files
## still to do: add a button to select whether prefix is added to all or numeric
## still to do: make radio buttons in order I choose
## still to do: create new boxmaps from ordered samples (export function)
## still to do: modify data frames to update box maps
