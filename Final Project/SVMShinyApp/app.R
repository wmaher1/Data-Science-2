library(shiny)
library(palmerpenguins)
library(dplyr)
library(ggplot2)
library(e1071)
library(DT)

penguins_full <- penguins %>%
    select(species, bill_length_mm, bill_depth_mm) %>%
    rename(bill_len = bill_length_mm, 
           bill_dep = bill_depth_mm) %>%
    na.omit()

# Define UI for application that draws a histogram
ui <- fluidPage(titlePanel("SVM Decision Boundaries"),
                
                sidebarLayout(
                    sidebarPanel(
                        # input 1
                        checkboxGroupInput(
                            "species_filter",
                            "Select Species to Include:",
                            choices = c("Adelie", "Chinstrap", "Gentoo"),
                            selected = c("Adelie", "Chinstrap", "Gentoo")
                        ),
                        
                        helpText("Filter which penguin species to analyze"),
                        
                        hr(),
                        
                        
                        # input 2
                        selectInput(
                            "kernel",
                            "Kernel:",
                            choices = c("radial", "linear", "polynomial", "sigmoid"),
                            selected = "radial"
                        ),
                        
                        
                        # input 3
                        sliderInput(
                            "cost",
                            "Cost:",
                            min = 0.1,
                            max = 10,
                            value = 1,
                            step = 0.1
                        ),
                        
                        helpText("Higher cost means less regularization, fits training data more closely"),
                        
                        
                        # input 4 (conditional)
                        conditionalPanel(
                            condition = "input.kernel == 'polynomial'",
                            sliderInput(
                                "degree",
                                "Polynomial Degree:",
                                min = 2,
                                max = 5,
                                value = 3,
                                step = 1
                            )
                        ),
                        
                        
                        # input 5 (conditional)
                        conditionalPanel(
                            condition = "input.kernel == 'radial'",
                            sliderInput(
                                "gamma",
                                "Gamma (RBF Kernel Width):",
                                min = 0.1,
                                max = 2,
                                value = 1,
                                step = 0.1
                            ),
                            helpText("Controls influence of single training example")
                        ),
                        
                        
                        hr(),
                        
                        
                        actionButton(
                            "train.btn",
                            "Train SVM Model",
                            class = "btn-primary",
                            icon = icon("play")
                        ),
                        
                        hr(),
                        
                        h4("Model Performance"),
                        verbatimTextOutput("accuracy_output"),
                        
                        
                        hr(),
                        
                        
                        # to explain support vectors
                        div(
                            style = "text-align: center; margin-top: 10px",
                            actionLink(
                                "explain_sv",
                                label = "What do the black circles mean?",
                                icon = icon("question-circle")
                            )
                        ),
                        
                        hr(),
                        
                        
                        # data source
                        p(em("Data: Palmer Penguins (Antarctica)"), style = "font-size: 12px; text-align: center;")
                        
                    ),
                    
                    mainPanel(
                        # tab 1, viz
                        tabsetPanel(
                            tabPanel("SVM Visualization",
                                     br(),
                                     plotOutput("svmPlot", 
                                                height = "700px"),
                                     br(),
                                     p("Black circled points = Support Vectors", style = "text-align: center; color: #555;")
                            ),
                        
                        # tab 2, results and statistics
                        tabPanel(
                            "Model Results & Statistics",
                            br(),
                            h4("Confusion Matrix (Training Data)"),
                            DTOutput("confusion_matrix"),
                            br(),
                            h4("Summary Statistics by Species"),
                            DTOutput("species_summary"),
                            br(),
                            h4("Support Vector Breakdown"),
                            DTOutput("sv_summary")
                        ),
                        
                        
                        # tab 3, about
                        tabPanel(
                            "About & Methods",
                            
                            br(),
                            
                            h3("Research Question"),
                            p(
                                strong(
                                    "How do bill length and bill depth distinguish between Adelie, Chinstrap, and Gentoo penguins using Support Vector Machine classification?"
                                )
                            ),
                            p(
                                "Which SVM kernel (radial, linear, polynomial, or sigmoid) provides the best separation of these three penguin species?"
                            ),
                            
                            hr(),
                            
                            h3("Key Takeaways"),
                            tags$ul(
                                tags$li(
                                    strong("Gentoo penguins"),
                                    " have distinctly longer bill (45-55 mm) compared to Adelie and Chinstrap (35-45 mm)"
                                ),
                                tags$li(
                                    strong("The radial kernel"),
                                    " typically provides the most flexible
                                     and accurate decision boundaries for this dataset"
                                ),
                                tags$li(
                                    strong("Support vectors"),
                                    " (circled points) are the critical data
                                     points that define the classification boundary - only ",
                                    em(nrow(penguins_full)),
                                    " points determine the boundary!"
                                ),
                                tags$li(
                                    strong("Higher cost values"),
                                    " may lead to overfitting, reducing
                                     the model's ability to generalize to new data"
                                ),
                                tags$li(
                                    "Bill length is the primary distinguishing feature, while bill depth
                                     helps separate Adelie from the other two species"
                                )
                            ),
                            
                            hr(),
                            
                            h3("Data Source"),
                            p(
                                "The ",
                                strong("Palmer Penguins Dataset"),
                                " is an excellent alternative to
                           the classic Iris dataset, containing measurements for three penguin species
                           observed at the Palmer Station Antarctica LTER."
                            ),
                            tags$ul(
                                tags$li(
                                    strong("Source:"),
                                    " Dr. Kristen Gorman and the Palmer Station
                                     Antarctica Long Term Ecological Research (LTER) station"
                                ),
                                tags$li(
                                    strong("URL:"),
                                    a("https://allisonhorst.github.io/palmerpenguins/", 
                                      href = "https://allisonhorst.github.io/palmerpenguins/")
                                ),
                                tags$li(
                                    strong("Case:"),
                                    "344 penguins observed in the Palmer Archipelago, Antarctica"
                                ),
                                tags$li(strong("Time Period:"), "2007-2009")
                            ),
                            
                            
                            
                            h3("Variable Definitions"),
                            tags$ul(
                                tags$li(
                                    strong("species:"),
                                    "Penguin species (Adelie, Chinstrap, or Gentoo) - the response variable"
                                ),
                                tags$li(
                                    strong("bill_len:"),
                                    "Bill length in millimeters (culmen length)"
                                ),
                                tags$li(strong("bill_dep:"), "Bill depth in millimeters (culmen depth)")
                            ),
                            
                            
                            h3("Scope of inference"),
                            p("These data represent three specific penguin species in the Palmer Archipelago region of Antarctica. Statistical inferences can only be generalized to: (1) These three specific species, (2) This geographic region, (3) The time period 2007-2009. Caution should be used when generalizing to other penguin species, regions, or time periods."),
                            
                            
                            h3("Methods"),
                            p("This app uses a ",
                              strong("Support Vector Machine (SVM)"),
                              " classifier from the ",
                              code("e1071"),
                              " package in R. SVM works by finding the hyperplane (or decision boundary) that maximizes the margin between different classes. The key features are:"
                            ),
                            tags$ul(
                                tags$li(
                                    strong("Kernel functions:"),
                                    " Transform the data into higher dimensions to allow for non-linear decision boundaries"
                                ),
                                tags$li(
                                    strong("Cost parameter:"),
                                    " Controls the trade-off between maximizing the margin and minimizing classification error"
                                ),
                                tags$li(
                                    strong("Support Vectors:"),
                                    " The data points closest to the decision boundary that determine its position"
                                )
                            ),
                            
                            p(
                                "The user can interactively explore how different kernels and parameters impact the decision boundaries and classification accuracy."
                            ),
                            
                            
                            hr(),
                            
                            
                            h4("Project Information"),
                            p(
                                "This Shiny app was created as a final project for Data Science 2 (Spring 2026)."
                            ),
                            p("All code is available in the accompanying GitHub repository.")
                            
                            
                        )
                    )
                )
            )
)




# Define server logic required to draw a histogram
server <- function(input, output, session) {
    
    penguins_data <- reactive({
        req(input$species_filter)
        penguins_full |> 
            filter(species %in% input$species_filter)
    })
    
    svm_results <- reactiveValues(
        model = NULL,
        grid_predictions = NULL,
        accuracy = NULL,
        training_time = NULL
    )
    
    
    # explaining support vectors
    observeEvent(input$explain_sv, {
        showModal(
            modalDialog(
                title = div(
                    span(icon("info-circle"), style = "color: #FF9800;"),
                    "What are the black circles (Support Vectors)?"
                ),
                size = "m",
                easyClose = TRUE,
                footer = modalButton("Got it!"),
                
                tagList(
                    h4("Support Vectors Explained"),
                    p("The ", strong("black circled points"), " on the plot are called ", strong("Support Vectors"), ". These are the most important data points in SVM classification."),
                    hr(),
                    
                    h5("Why are they special?"),
                    tags$ul(
                        tags$li(strong("They define the decision boundary"),
                                " - The boundary is positioned to maximize the distance to these points"),
                        tags$li(strong("Only they matter"),
                                " - If you remove any non-support vector point, the boundary wouldn't change"),
                        tags$li(strong("Critical for classification"),
                                " - Removing a support vector would change the boundary"),
                        tags$li(strong("Usually few in number"),
                                paste0(" - In this model, only ",
                                       ifelse(is.null(svm_results$accuracy), 
                                              "?", 
                                              length(svm_results$model$index)),
                                       " out of ", 
                                       nrow(penguins_data()), 
                                       " total points are support vectors"))
                    ),
                    
                    hr(),
                    
                    h5("The analogy I was taught"),
                    p("Imagine drawing the widest possible street between two groups of houses. ",
                      "The support vectors are the houses closest to the street, they determine",
                      "where the street goes. All other houses further back don't affect the street's position."),
                    
                    hr(),
                    
                    p("Number of support vectors for the current model: ",
                      strong(ifelse(is.null(svm_results$accuracy), "Train the model first",
                                    length(svm_results$model$index))),
                      style = "text-align: center; font-size: 16px;")
                )
            )
        )
    })
    
    observeEvent(input$train.btn, {
        
        req(nrow(penguins_data()) >= 3)
        
        showNotification("Training SVM Model...", 
                         type = "default",
                         duration = 3)
        
        start_time <- Sys.time()
        
        tryCatch({
            svm_args <- list(formula = species ~ bill_len + bill_dep,
                             data = penguins_data(),
                             kernel = input$kernel,
                             cost = input$cost
                             )
            
            # only when poly and radial are specified
            if(input$kernel == "polynomial") {
                svm_args$degree <- input$degree
            }
            if(input$kernel == "radial") {
                svm_args$gamma <- input$gamma
            }
            
            
            # debugging...
            print("SVM Arguments:")
            print(names(svm_args))
            
            
            # training model
            svm_results$model <- do.call(svm, svm_args)
            
            
            # to check if model was created successfully
            if(is.null(svm_results$model)) {
                stop("Model creation failed")
            }
            
            
            # accuracy
            predictions <- predict(svm_results$model, 
                                   newdata = penguins_data())
            svm_results$accuracy <- mean(predictions == penguins_data()$species)
            
            # recording training time
            svm_results$training_time <- difftime(Sys.time(),
                                                  start_time, 
                                                  units = "secs")
            
            
            x_range <- seq(min(penguins_data()$bill_len) - 1,
                           max(penguins_data()$bill_len) + 1,
                           length.out = 150)
            
            y_range <- seq(min(penguins_data()$bill_dep) - 1,
                           max(penguins_data()$bill_dep) + 1,
                           length.out = 150)
            
            grid <- expand.grid(bill_len = x_range, 
                                bill_dep = y_range)
            
            grid$pred <- predict(svm_results$model, 
                                 newdata = grid)
            
            svm_results$grid_predictions <- grid
            
            showNotification("Model training successfully!",
                             type = "default",
                             duration = 2)
            
        }, error = function(e) {
            error_msg <- e$message
            showNotification(paste("Error training model:",
                                   error_msg),
                             type = "error", 
                             duration = 8)
            print(paste("Detailed error:", error_msg))
            svm_results$model <- NULL
        })
    })
    
    # displaying accuracy
    output$accuracy_output <- renderPrint({
        req(svm_results$accuracy)
        cat(sprintf("Training Accuracy: %.1f%%\n", 
                    svm_results$accuracy * 100))
        cat(sprintf("Training Time: %.2f seconds",
                    svm_results$training_time))
    })
    

    # confusion matrix table
    output$confusion_matrix <- renderDT({
        req(svm_results$model, svm_results$accuracy)
        
        predictions <- predict(svm_results$model, 
                               newdata = penguins_data())
        
        cm <- as.data.frame.matrix(table(Predicted = predictions, 
                                         Actual = penguins_data()$species))
        
        cm_total <- rbind(cm, Total = colSums(cm))
        
        datatable(cm_total,
                  options = list(dom = 'Bfrtip',
                                 pageLength = 10,
                                 searching = FALSE,
                                 ordering = FALSE
                  ),
                  caption = htmltools::tags$caption(
                      style = 'caption-side: bottom; text-align: center;',
                      'Table 1: Confusion matrix of SVM predictions on training data'
                  )
        )  
    })
    
    
    # species summary stats
    output$species_summary <- renderDT({
        summary_stats <- penguins_data() %>%
            group_by(species) %>%
            summarise(Count = n(),
                      `Mean Bill Length (mm)` = round(mean(bill_len), 2),
                      `SD Bill Length` = round(sd(bill_len), 2),
                      `Min Bill Length` = round(min(bill_len), 2),
                      `Max Bill Length` = round(max(bill_len), 2),
                      `Mean Bill Depth (mm)` = round(mean(bill_dep), 2),
                      `SD Bill Depth` = round(sd(bill_dep), 2)
            )
        
        datatable(summary_stats,
                 options = list(dom = 'Bfrtip',
                                pageLength = 10,
                                searching = FALSE),
                 caption = "Table 2: Summary Statistics of bill measurements by species",
                 rownames = FALSE) |> 
            formatStyle("Count",
                        background = styleColorBar(summary_stats$Count,
                                                   'lightblue'),
                        backgroundSize = '100% 90%',
                        backgroundRepeat = 'no-repeat',
                        backgroundPosition = 'center')
    })
    
    # support vector breakdown
    output$sv_summary <- renderDT({
        req(svm_results$model)
        
        sv_indices <- svm_results$model$index
        sv_data <- penguins_data()[sv_indices, ]
        
        sv_summary <- sv_data %>%
            group_by(species) %>%
            summarise(
                `Support Vector Count` = n(),
                `Avg Bill Length (mm)` = round(mean(bill_len), 2),
                `Avg Bill Depth (mm)` = round(mean(bill_dep), 2)
            ) %>%
            arrange(desc(`Support Vector Count`))
        
        datatable(sv_summary,
                  options = list(dom = 't', pageLength = 10),
                  caption = htmltools::tags$caption(
                      style = 'caption-side: bottom; text-align: center;',
                      paste0('Table 3: Support vector breakdown (',
                             length(sv_indices),
                             ' total support vectors out of ',
                             nrow(penguins_data()),
                             ' total points)'
                      )
                  ),
                  rownames = FALSE
        )
    })
    
    
    output$svmPlot <- renderPlot({
        req(svm_results$grid_predictions, svm_results$model)
        
        n_sv <- length(svm_results$model$index)
        
        p <- ggplot() +
            geom_tile(data = svm_results$grid_predictions,
                      aes(x = bill_len, y = bill_dep, fill = pred),
                      alpha = 0.4) +
            geom_point(data = penguins_data(),
                       aes(x = bill_len, y = bill_dep,
                           color = species, shape = species),
                       size = 3, alpha = 0.9) +
            geom_point(data = penguins_data()[svm_results$model$index, ],
                       aes(x = bill_len, y = bill_dep),
                       size = 5, shape = 1, stroke = 1.5, color = "black") +
            scale_fill_manual(values = c("Adelie" = "#F8766D",
                                         "Chinstrap" = "#00BA38",
                                         "Gentoo" = "#619CFF"),
                              name = "Predicted Region") +
            scale_color_manual(values = c("Adelie" = "#F8766D",
                                          "Chinstrap" = "#00BA38",
                                          "Gentoo" = "#619CFF"),
                               name = "Actual Species") +
            scale_shape_manual(values = c("Adelie" = 16,
                                          "Chinstrap" = 17,
                                          "Gentoo" = 18),
                               name = "Actual Species") +
            labs(title = paste("SVM Decision Boundaries -",
                               toupper(input$kernel), "Kernel"),
                 subtitle = paste0(
                     "Cost = ",
                     input$cost,
                     if (input$kernel == "polynomial")
                         paste0(" | Degree = ", input$degree)
                     else if (input$kernel == "radial" && 
                              !is.null(input$gamma))
                         paste0(" | Gamma = ", input$gamma)
                     else
                         "",
                     " | Support Vectors: ",
                     n_sv
                 ),
                 x = "Bill Length (mm)",
                 y = "Bill Depth (mm)") +
            theme_minimal() + 
            theme(legend.position = "right",
                  plot.title = element_text(size = 16,
                                            face = "bold"),
                  plot.subtitle = element_text(size = 12),
                  legend.box = "vertical")
        
        # decision boundaries if linear kernel
        if (input$kernel == "linear" &&
            !is.null(svm_results$model$coefs)) {
            p <- p + geom_abline(
                slope = -svm_results$model$coefs[1] / svm_results$model$coefs[2],
                intercept = svm_results$model$rho / svm_results$model$coefs[2],  
                linetype = "dashed",
                color = "black",
                size = 1
            )
        }
        
        p
    })
    
    output$model_summary <- renderUI({
        req(svm_results$model)
        
        summary_text <- capture.output(print(svm_results$model))
        
        tags$div(
            h5("Model Details:"),
            pre(paste(summary_text[1:min(10, length(summary_text))],
                      collapse = "\n"))
        )
    })
        
    
}

# Run the application 
shinyApp(ui = ui, server = server)
