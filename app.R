source('global.R', local = TRUE)
# Line chart data
shinyApp(
  ui <- dashboardPage(skin = "black",
          dashboardHeader(title = "Twitter Dashboard",

#### Dropdown Menu
            dropdownMenu(type = "messages",
              messageItem(from = "Database", message = p("Last update:", file.info("data.csv")[, 4], br(), p("Number of observations:", nrow(data))))
            )
          ),

#### Sidebar Menu
        dashboardSidebar(
          sidebarMenu(
            h5("Control Panel", align = "left"),
            hr(),

            # Inputs
            dateInput("date", "Select a start date", value = "2019-02-18", min = "2019-02-18", max = "2019-05-02", format = "dd-mm-yyyy"),
            sliderInput("slider", "Add interval", min = 0, max = 7, value = 0),
            selectInput("select", "Limit dataset to language:", langlist),
            h5("Navigation", align = "left"),
            hr(),

            # Tab Menu
            menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
            menuItem("About", tabName = "about", icon = icon("th"))
                    )
                  ),

       dashboardBody(tags$head(

      # Include custom css
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),

#### Dashboard Content
      tabItems(
        tabItem(tabName = "dashboard",
          fluidRow(
            box(highchartOutput("line")),
            box(highchartOutput("bar")),
            box(highchartOutput("words")),
            box(highchartOutput("net")),
            box(h3("Random Tweet for selected interval"), p(img(src="twitter.svg", width="50px", height="50px", align = "left"), textOutput("text"))),
            box(p("All plots are created with Highcharts under a Non-Commercial License.", a("Highcharts", href="https://www.highcharts.com/"), "is a Highsoft software product which is not free for commercial and Governmental use."))
          )
        ),

#### About Content
    tabItem(tabName = "about",
            h2("About this dashboard"),
            p("This dashboard is intended for educational use. It visualizes data which is publicly available through Twitter.")
          )
        )
      )
    ),

#### Define server logic ####
  server <- function(input, output) {

#### Bar chart
    output$bar <- renderHighchart({

      # Create a Progress object
      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(message = "creating bar chart", value = 0.5)
      #-------------------------

      # Date Sorting
        if (input$slider == "0" & input$select != "all") {
          selection <- data[created_at == input$date & lang == input$select, c("type", "person"), with=FALSE]
        } else if (input$slider >= "1" & input$select != "all") {
          selection <- data[created_at >= input$date & created_at <= input$date + input$slider & lang == input$select,c("type", "person"), with=FALSE]
        } else if (input$slider == "0" & input$select == "all") {
          selection <- data[created_at == input$date, c("type", "person"), with=FALSE]
        } else if (input$slider >= "1" & input$select == "all") {
          selection <- data[created_at >= input$date & created_at <= input$date + input$slider, c("type", "person"), with=FALSE]
        }

      # Prep bar chart
      hc <- as.data.table(table(selection$type, selection$person))
      date_b <- paste("Traffic:", input$date, "to", input$date + input$slider, sep = " ")

      # Render Charts

      if (nrow(hc) <= "1"){
        hc_b1 <- highchart() %>%
          hc_add_series_list(list()) %>%
          hc_title(text = "No data for selection") %>%
          hc_add_theme(hc_theme_smpl())
        progress$inc(0.5, detail = paste("bar chart finished"))
        return(hc_b1)
      } else {
        hc_b2 <- hchart(hc, "column", hcaes(x = V2, y = N,  group = V1)) %>%
          hc_title(text = date_b) %>%
          hc_subtitle(text = "Tweets, Retweets and Comments") %>%
          hc_xAxis(title = list(text = "Twitter User")) %>%
          hc_yAxis(title = list(text = "Number of")) %>%
          hc_add_theme(hc_theme_smpl())
        progress$inc(0.5, detail = paste("bar chart finished"))
        return(hc_b2)
      }
    })

  #### Line chart
    output$line <- renderHighchart({

      # Create a Progress object
      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(message = "creating line chart", value = 0.5)
      #-------------------------

      # Date Sorting
      if (input$select != "all") {
        line <- data[lang == input$select, c("created_at", "person"), with=FALSE]
        line <- as.data.table(table(line$person, line$created_at))
      } else {
        line <- as.data.table(table(data$person, data$created_at))
      }

        # Render Chart

      hc_l <- hchart(line, "line", hcaes(x = V2, y = N,  group = V1)) %>%
              hc_title(text = "Traffic for the entire Dataset") %>%
              hc_subtitle(text = "Tweets, Retweets and Comments combined") %>%
              hc_xAxis(title = list(text = "Date")) %>%
              hc_yAxis(title = list(text = "Combined Count")) %>%
              hc_add_theme(hc_theme_smpl())
      progress$inc(1, detail = paste("line chart finished"))
      return(hc_l)
    })

  #### Wordcloud
    output$words <- renderHighchart({

      # Create a Progress object
      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(message = "creating wordcloud", value = 0.5)
      #-------------------------

        # Date Sorting

      if (input$slider == "0" & input$select != "all") {
        text <- data[created_at == input$date & lang == input$select & type == "Comments", "text", with=FALSE]
      } else if (input$slider >= "1" & input$select != "all") {
        text <- data[created_at >= input$date & created_at <= input$date + input$slider & lang == input$select & type == "Comments", "text", with=FALSE]
      } else if (input$slider == "0" & input$select == "all") {
        text <- data[created_at == input$date & type == "Comments", "text", with=FALSE]
      } else if (input$slider >= "1" & input$select == "all") {
        text <- data[created_at >= input$date & created_at <= input$date + input$slider & type == "Comments", "text", with=FALSE]
      }

      # Prep wordcount
      tidy_text <- text %>% unnest_tokens(word, text)
      sw <- tibble(word = stop_de)
      swm <- data.frame(word = c("rt", "t.co", "https", "sebastiankurz", "spoe_at", "peter_pilz", "hcstrachefp", "bmeinl", "für"))
      sw <- rbind(sw, swm)
      tidy_text <- tidy_text %>% anti_join(sw)
      tidy_text <- tidy_text %>% anti_join(stop_words)
      words <- tidy_text %>%
        count(word, sort = TRUE) %>%
        filter(n > nrow(text)/30) %>%
        mutate(word = reorder(word, n))
        date_w = paste("Comments Wordcloud:", input$date, "to", input$date + input$slider, sep = " ")

      # Render Chart

        if (nrow(words) <= "1"){
          hc_w1 <- highchart() %>%
            hc_add_series_list(list()) %>%
            hc_title(text = "No data for selection") %>%
            hc_add_theme(hc_theme_smpl())
            progress$inc(0.5, detail = paste("wordcloud finished"))
          return(hc_w1)
        } else {
          hc_w2 <- hchart(words, "wordcloud", hcaes(x = word, weight = n)) %>%
            hc_title(text = date_w) %>%
            hc_subtitle(text = "Size is based on frequency") %>%
            hc_add_theme(hc_theme_smpl())
            progress$inc(0.5, detail = paste("wordcloud finished"))
          return(hc_w2)
        }
    })

  #### Networkgraph
    output$net <- renderHighchart({

      # Create a Progress object
      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(message = "creating network graph", value = 0.2)
      #-------------------------

        # Date Sorting

      if (input$slider == "0" & input$select != "all") {
        net1 <- data[data$created_at == input$date & data$lang == input$select, ]
      } else if (input$slider >= "1" & input$select != "all") {
        net1 <- data[data$created_at >= input$date & data$created_at <= input$date + input$slider & data$lang == input$select, ]
      } else if (input$slider == "0" & input$select == "all") {
        net1 <- data[data$created_at == input$date, ]
      } else if (input$slider >= "1" & input$select == "all") {
        net1 <- data[data$created_at >= input$date & data$created_at <= input$date + input$slider, ]
      }

      # Prep network graph
      net <- table(x = net1$person, y = net1$user)
      net <- as.data.frame(net)
      net <- net[net$Freq >= 1, ]
      net <- graph_from_data_frame(net)
      wc <- cluster_walktrap(net)
      V(net)$color <- colorize(membership(wc))
      V(net)$size <- degree(net)
      progress$set(message = "creating nodes", value = 0.3)

     # Render Chart

      if (nrow(net1) <= "1"){
        hc_n1 <- highchart() %>%
          hc_add_series_list(list()) %>%
          hc_title(text = "No data for selection") %>%
          hc_add_theme(hc_theme_smpl())
        progress$inc(0.5, detail = paste("network graph finished"))
        return(hc_n1)
      } else {
        hc_n2 <- hchart(net, zoomType= "xy", layout = layout_with_fr) %>%
        hc_boost(enabled = FALSE) 
        progress$inc(0.5, detail = paste("network graph finished"))
        return(hc_n2)
      }
    })

  #### Sample a Tweet
    output$text <- renderText({

        # Date Sorting
        if (input$slider == "0") {
          selection <- data[data$created_at == input$date, ]
        } else {
          selection <- data[data$created_at >= input$date & data$created_at <= input$date + input$slider, ]
        }
        if (nrow(selection) <= "1"){
          selection <- data[data$created_at == input$date - 1, ]
        }
      sample(selection$text, 1)
    })
  }
)
