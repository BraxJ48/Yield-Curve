project_lib <- file.path(getwd(), "r_libs")
if (dir.exists(project_lib)) {
  .libPaths(unique(c(normalizePath(project_lib, winslash = "/", mustWork = FALSE), .libPaths())))
}

user_lib <- Sys.getenv("R_LIBS_USER", unset = "")
if (nzchar(user_lib) && dir.exists(user_lib)) {
  .libPaths(unique(c(normalizePath(user_lib, winslash = "/", mustWork = FALSE), .libPaths())))
}

library(shiny)
library(ggplot2)
library(naniar)
library(plotly)
library(scales)
library(DT)

source("analysis_helpers.R")

fred_dark <- list(
  page_bg = "#0f1724",
  panel_bg = "#2b3f57",
  paper_bg = "#1a2940",
  accent_blue = "#2f8cff",
  accent_blue_light = "#8ec5ff",
  accent_red = "#ff7a7a",
  accent_green = "#59d98e",
  text = "#e8eff8",
  muted_text = "#9fb0c3",
  grid = "#314256",
  axis = "#6f8198",
  zero = "#dce6f2"
)

theme_fred_dark <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.background = element_rect(fill = fred_dark$panel_bg, color = NA),
      panel.background = element_rect(fill = fred_dark$panel_bg, color = NA),
      panel.grid.major = element_line(color = fred_dark$grid, linewidth = 0.45),
      panel.grid.minor = element_blank(),
      axis.text = element_text(color = fred_dark$text),
      axis.title = element_text(color = fred_dark$text),
      plot.title = element_text(color = fred_dark$text, face = "bold"),
      plot.subtitle = element_text(color = fred_dark$muted_text),
      legend.background = element_rect(fill = fred_dark$panel_bg, color = NA),
      legend.key = element_rect(fill = fred_dark$panel_bg, color = NA),
      legend.text = element_text(color = fred_dark$text),
      legend.title = element_text(color = fred_dark$text),
      strip.background = element_rect(fill = fred_dark$paper_bg, color = NA),
      strip.text = element_text(color = fred_dark$text)
    )
}

fred_plotly_layout <- function(title, xaxis, yaxis) {
  list(
    title = list(text = title, font = list(color = fred_dark$text)),
    paper_bgcolor = fred_dark$paper_bg,
    plot_bgcolor = fred_dark$panel_bg,
    font = list(color = fred_dark$text),
    hoverlabel = list(
      bgcolor = fred_dark$panel_bg,
      bordercolor = fred_dark$accent_blue,
      font = list(color = fred_dark$text)
    ),
    xaxis = utils::modifyList(
      list(
        gridcolor = fred_dark$grid,
        linecolor = fred_dark$axis,
        tickcolor = fred_dark$axis,
        zeroline = FALSE,
        color = fred_dark$text
      ),
      xaxis
    ),
    yaxis = utils::modifyList(
      list(
        gridcolor = fred_dark$grid,
        linecolor = fred_dark$axis,
        tickcolor = fred_dark$axis,
        zerolinecolor = fred_dark$zero,
        zerolinewidth = 1.2,
        color = fred_dark$text
      ),
      yaxis
    ),
    hovermode = "x unified",
    dragmode = "pan",
    legend = list(
      orientation = "h",
      x = 0,
      y = 1.12,
      font = list(color = fred_dark$text),
      bgcolor = "rgba(0,0,0,0)"
    )
  )
}

ui <- fluidPage(
  tags$head(
    tags$style(HTML(paste0(
      "body { background: ", fred_dark$page_bg, "; color: ", fred_dark$text, "; }",
      ".container-fluid { background: ", fred_dark$page_bg, "; min-height: 100vh; }",
      ".title-panel h2, .title-panel h1, h3, h4, label, .control-label { color: ", fred_dark$text, "; }",
      ".well, .tab-content, .nav-tabs, .sidebarPanel, .mainPanel { background: ", fred_dark$panel_bg, "; color: ", fred_dark$text, "; border-color: ", fred_dark$grid, "; }",
      ".well { border: 1px solid ", fred_dark$grid, "; }",
      ".nav-tabs > li > a { background: ", fred_dark$paper_bg, "; color: ", fred_dark$muted_text, "; border: 1px solid ", fred_dark$grid, "; }",
      ".nav-tabs > li.active > a, .nav-tabs > li.active > a:hover, .nav-tabs > li.active > a:focus { background: ", fred_dark$panel_bg, "; color: ", fred_dark$text, "; border-color: ", fred_dark$accent_blue, "; }",
      ".form-control, .irs-single, .irs-line { background: ", fred_dark$panel_bg, "; color: ", fred_dark$text, "; border-color: ", fred_dark$grid, "; }",
      ".irs-bar, .irs-bar-edge, .irs-single { background: ", fred_dark$accent_blue, "; border-color: ", fred_dark$accent_blue, "; }",
      ".irs--shiny .irs-grid-text { font-size: 12px; white-space: nowrap; }",
      ".nsim-slider .irs-grid-text { font-size: 11px; }",
      ".nsim-slider .irs-grid-text:nth-child(even) { display: none !important; }",
      ".btn-default { background: ", fred_dark$accent_blue, "; color: ", fred_dark$text, "; border-color: ", fred_dark$accent_blue, "; }",
      ".btn-default:hover { background: ", fred_dark$accent_blue_light, "; color: ", fred_dark$page_bg, "; }",
      "table { color: ", fred_dark$text, "; background: ", fred_dark$panel_bg, "; }",
      ".table > thead > tr > th, .table > tbody > tr > td { border-top: 1px solid ", fred_dark$grid, "; }",
      ".metric-card { background: ", fred_dark$panel_bg, "; border: 2px solid #203146; border-radius: 10px; padding: 24px 28px; min-height: 150px; box-shadow: 0 0 0 1px rgba(8,12,18,0.35), inset 0 0 0 1px rgba(255,255,255,0.015); }",
      ".metric-card h4 { color: ", fred_dark$text, "; font-size: 20px; margin-top: 0; margin-bottom: 14px; }",
      ".metric-card .metric-value { color: ", fred_dark$text, "; font-size: 22px; font-weight: 600; letter-spacing: 0.2px; }",
      "#app-layout.fullwidth-main .sidebar-panel { display: none; }",
      "#app-layout.fullwidth-main .main-panel { width: 100%; }",
      "#app-layout.fullwidth-main .main-panel .tab-content { width: 100%; }",
      ".dataTables_wrapper .dataTables_info, .dataTables_wrapper .dataTables_paginate, .dataTables_wrapper .dataTables_paginate .paginate_button, .dataTables_wrapper .dataTables_length, .dataTables_wrapper .dataTables_filter label { color: ", fred_dark$text, " !important; }",
      ".dataTables_wrapper .dataTables_paginate .paginate_button.current, .dataTables_wrapper .dataTables_paginate .paginate_button.current:hover { color: ", fred_dark$text, " !important; background: ", fred_dark$paper_bg, " !important; border: 1px solid ", fred_dark$grid, " !important; }",
      ".dataTables_wrapper .dataTables_paginate .paginate_button:hover { color: ", fred_dark$text, " !important; background: ", fred_dark$accent_blue, " !important; border: 1px solid ", fred_dark$accent_blue, " !important; }"
    ))),
    tags$script(HTML("
      $(document).on('shiny:inputchanged', function(event) {
        if (event.name === 'main_tabs') {
          var layout = document.getElementById('app-layout');
          if (!layout) return;
          if (event.value === 'forecast' || event.value === 'inversion_risk') {
            layout.classList.remove('fullwidth-main');
          } else {
            layout.classList.add('fullwidth-main');
          }
        }
      });
      $(function() {
        var layout = document.getElementById('app-layout');
        if (layout) {
          layout.classList.add('fullwidth-main');
        }
      });
    "))
  ),
  titlePanel("Yield Curve Time Series Dashboard"),
  div(
    id = "app-layout",
    sidebarLayout(
    sidebarPanel(
      class = "sidebar-panel",
      style = "margin-top: 140px;",
      conditionalPanel(
        condition = "input.main_tabs == 'forecast' || input.main_tabs == 'inversion_risk'",
        h4("Controls"),
        sliderInput("horizon", "Forecast horizon (weeks)", min = 12, max = 104, value = 52, step = 4),
        div(
          class = "nsim-slider",
          sliderInput("nsim", "Monte Carlo simulations", min = 500, max = 10000, value = 2000, step = 500)
        ),
        actionButton("refresh", "Run analysis"),
        tags$hr(),
        p("Data source: T10Y2Y Treasury spread history")
      )
    ),
    mainPanel(
      class = "main-panel",
      tabsetPanel(
        id = "main_tabs",
        tabPanel(
          "Overview",
          value = "overview",
          h3(textOutput("date_range")),
          fluidRow(
            column(
              4,
              div(
                class = "metric-card",
                h4("Rows"),
                div(class = "metric-value", textOutput("total_rows"))
              )
            ),
            column(
              4,
              div(
                class = "metric-card",
                h4("Missing values"),
                div(class = "metric-value", textOutput("missing_rows"))
              )
            ),
            column(
              4,
              div(
                class = "metric-card",
                h4("Prob. of inversion"),
                div(class = "metric-value", textOutput("inversion_prob"))
              )
            )
          ),
          plotOutput("daily_plot", height = 320)
        ),
        tabPanel(
          "Missingness",
          value = "missingness",
          radioButtons(
            "missing_view",
            "Show points",
            choices = c("Both" = "both", "Observed only" = "observed", "Missing only" = "missing"),
            selected = "both",
            inline = TRUE
          ),
          plotOutput("missing_plot", height = 420),
          tableOutput("missing_weekday_table")
        ),
        tabPanel(
          "Weekly Series",
          value = "weekly_series",
          plotlyOutput("weekly_plot", height = 380),
          fluidRow(
            column(6, plotOutput("acf_plot", height = 280)),
            column(6, plotOutput("pacf_plot", height = 280))
          ),
          fluidRow(
            column(6, plotOutput("diff_acf_plot", height = 280)),
            column(6, plotOutput("diff_pacf_plot", height = 280))
          )
        ),
        tabPanel(
          "Forecast",
          value = "forecast",
          plotlyOutput("forecast_plot", height = 420),
          DTOutput("forecast_table")
        ),
        tabPanel(
          "Inversion Risk",
          value = "inversion_risk",
          plotlyOutput("probability_plot", height = 380),
          DTOutput("probability_table")
        )
      )
    )
    )
  )
)

server <- function(input, output, session) {
  analysis_data <- eventReactive(input$refresh, {
    withProgress(message = "Running time series analysis...", value = 0, {
      incProgress(0.2, detail = "Loading and cleaning data")
      analysis <- load_yield_curve_analysis(
        csv_path = "T10Y2Y.csv",
        forecast_horizon = input$horizon,
        nsim = input$nsim
      )
      incProgress(1)
      analysis
    })
  }, ignoreNULL = FALSE)

  output$date_range <- renderText({
    data <- analysis_data()$yield_curve
    paste(
      format(min(data$observation_date, na.rm = TRUE), "%b %d, %Y"),
      "to",
      format(max(data$observation_date, na.rm = TRUE), "%b %d, %Y")
    )
  })

  output$total_rows <- renderText({
    scales::comma(analysis_data()$missing_summary$total_rows)
  })

  output$missing_rows <- renderText({
    summary_row <- analysis_data()$missing_summary
    paste0(
      scales::comma(summary_row$missing_rows),
      " (",
      summary_row$missing_pct,
      "%)"
    )
  })

  output$inversion_prob <- renderText({
    percent(analysis_data()$prob_inversion, accuracy = 0.1)
  })

  output$daily_plot <- renderPlot({
    daily <- analysis_data()$yield_curve
    ggplot(daily, aes(x = observation_date, y = T10Y2Y)) +
      geom_hline(yintercept = 0, color = fred_dark$zero, linewidth = 0.6) +
      geom_line(color = fred_dark$accent_blue, linewidth = 0.5, na.rm = TRUE) +
      labs(title = "Daily T10Y2Y Spread", x = NULL, y = "Spread") +
      theme_fred_dark()
  })

  output$missing_weekday_table <- renderTable({
    analysis_data()$missing_by_weekday
  })

  output$missing_plot <- renderPlot({
    daily <- analysis_data()$yield_curve
    daily$status <- ifelse(is.na(daily$T10Y2Y), "Missing", "Observed")
    observed_data <- subset(daily, status == "Observed")
    missing_data <- subset(daily, status == "Missing")

    observed_range <- range(observed_data$T10Y2Y, na.rm = TRUE)
    missing_y <- observed_range[1] - 0.08 * diff(observed_range)
    if (!is.finite(missing_y)) {
      missing_y <- 0
    }
    missing_data$display_y <- missing_y

    plot_layers <- ggplot() +
      geom_hline(yintercept = 0, color = fred_dark$zero, linewidth = 0.6)

    if (input$missing_view %in% c("both", "observed") && nrow(observed_data) > 0) {
      plot_layers <- plot_layers +
        geom_point(
          data = observed_data,
          aes(x = observation_date, y = T10Y2Y, color = status),
          alpha = 0.8,
          size = 1.4
        )
    }

    if (input$missing_view %in% c("both", "missing") && nrow(missing_data) > 0) {
      plot_layers <- plot_layers +
        geom_point(
          data = missing_data,
          aes(x = observation_date, y = display_y, color = status),
          alpha = 0.95,
          size = 2.4,
          shape = 17
        )
    }

    plot_layers +
      scale_color_manual(
        values = c(
          "Observed" = fred_dark$accent_blue_light,
          "Missing" = fred_dark$accent_red
        ),
        name = "Observation Status"
      ) +
      labs(
        title = "Missing Observations in the Daily Series",
        x = NULL,
        y = "T10Y2Y"
      ) +
      theme_fred_dark()
  })

  output$weekly_plot <- renderPlotly({
    weekly <- analysis_data()$yield_curve_weekly

    weekly_plot <- plot_ly(source = "weekly") |>
      add_lines(
        data = weekly,
        x = ~week,
        y = ~T10Y2Y_weekly,
        name = "Weekly average",
        line = list(color = "#94c9ff", width = 2.2),
        hovertemplate = paste(
          "Week: %{x|%Y-%m-%d}<br>",
          "Spread: %{y:.3f}<extra></extra>"
        )
      )

    weekly_plot <- do.call(
      layout,
      c(
        list(weekly_plot),
        fred_plotly_layout(
          "Weekly Average Yield Curve",
          xaxis = list(
            title = "",
            rangeslider = list(visible = TRUE),
            type = "date"
          ),
          yaxis = list(
            title = "Spread",
            zeroline = TRUE,
            zerolinecolor = "#f2f7ff",
            zerolinewidth = 1.3
          )
        )
      )
    )

    weekly_plot |>
      layout(
        margin = list(t = 80, r = 30, b = 60, l = 60),
        title = list(
          text = "Weekly Average Yield Curve",
          x = 0.5,
          xanchor = "center",
          y = 0.97,
          font = list(color = fred_dark$text, size = 22)
        ),
        legend = list(
          orientation = "h",
          x = 0,
          y = 1.03,
          xanchor = "left",
          font = list(color = fred_dark$text),
          bgcolor = "rgba(0,0,0,0)"
        )
      ) |>
      config(
        displayModeBar = TRUE,
        scrollZoom = TRUE,
        modeBarButtonsToAdd = c("zoomIn2d", "zoomOut2d", "resetScale2d")
      )
  })

  output$acf_plot <- renderPlot({
    par(
      bg = fred_dark$panel_bg,
      fg = fred_dark$text,
      col.axis = fred_dark$text,
      col.lab = fred_dark$text,
      col.main = fred_dark$text
    )
    acf(
      analysis_data()$ts_weekly_zoo,
      main = "ACF: Weekly Series",
      ci.col = fred_dark$accent_red,
      col = fred_dark$accent_blue,
      lwd = 2
    )
  }, bg = fred_dark$panel_bg)

  output$pacf_plot <- renderPlot({
    par(
      bg = fred_dark$panel_bg,
      fg = fred_dark$text,
      col.axis = fred_dark$text,
      col.lab = fred_dark$text,
      col.main = fred_dark$text
    )
    pacf(
      analysis_data()$ts_weekly_zoo,
      main = "PACF: Weekly Series",
      ci.col = fred_dark$accent_red,
      col = fred_dark$accent_blue,
      lwd = 2
    )
  }, bg = fred_dark$panel_bg)

  output$diff_acf_plot <- renderPlot({
    par(
      bg = fred_dark$panel_bg,
      fg = fred_dark$text,
      col.axis = fred_dark$text,
      col.lab = fred_dark$text,
      col.main = fred_dark$text
    )
    acf(
      analysis_data()$ts_diff,
      main = "ACF: Differenced Series",
      ci.col = fred_dark$accent_red,
      col = fred_dark$accent_blue,
      lwd = 2
    )
  }, bg = fred_dark$panel_bg)

  output$diff_pacf_plot <- renderPlot({
    par(
      bg = fred_dark$panel_bg,
      fg = fred_dark$text,
      col.axis = fred_dark$text,
      col.lab = fred_dark$text,
      col.main = fred_dark$text
    )
    pacf(
      analysis_data()$ts_diff,
      main = "PACF: Differenced Series",
      ci.col = fred_dark$accent_red,
      col = fred_dark$accent_blue,
      lwd = 2
    )
  }, bg = fred_dark$panel_bg)

  output$forecast_plot <- renderPlotly({
    weekly <- analysis_data()$yield_curve_weekly
    forecast_table <- analysis_data()$forecast_table
    forecast_table$hover_text <- paste0(
      "Week: ", format(forecast_table$date, "%Y-%m-%d"),
      "<br>Lower 95%: ", sprintf("%.3f", forecast_table$lower_95),
      "<br>Upper 95%: ", sprintf("%.3f", forecast_table$upper_95),
      "<extra></extra>"
    )

    forecast_plot <- plot_ly(source = "forecast") |>
      add_lines(
        data = weekly,
        x = ~week,
        y = ~T10Y2Y_weekly,
        name = "Weekly average",
        line = list(color = fred_dark$accent_blue_light, width = 1.6),
        hovertemplate = paste(
          "Week: %{x|%Y-%m-%d}<br>",
          "Spread: %{y:.3f}<extra></extra>"
        )
      ) |>
      add_ribbons(
        data = forecast_table,
        x = ~date,
        ymin = ~lower_95,
        ymax = ~upper_95,
        name = "95% interval",
        fillcolor = "rgba(47, 140, 255, 0.18)",
        line = list(color = "transparent"),
        text = ~hover_text,
        hovertemplate = "%{text}"
      ) |>
      add_lines(
        data = forecast_table,
        x = ~date,
        y = ~forecast,
        name = "Forecast",
        line = list(color = fred_dark$accent_red, width = 2.5),
        hovertemplate = paste(
          "Week: %{x|%Y-%m-%d}<br>",
          "Forecast: %{y:.3f}<br>",
          "Lower 95%: %{customdata[1]:.3f}<br>",
          "Upper 95%: %{customdata[2]:.3f}<extra></extra>"
        ),
        customdata = ~cbind(lower_95, upper_95)
      )

    forecast_plot <- do.call(
      layout,
      c(
        list(forecast_plot),
        fred_plotly_layout(
          "ARIMA(0,1,1) Forecast",
          xaxis = list(
            title = "",
            rangeslider = list(visible = TRUE),
            type = "date"
          ),
          yaxis = list(title = "Spread")
        )
      )
    )

    forecast_plot <- layout(
      forecast_plot,
      margin = list(t = 95, r = 30, b = 60, l = 60),
      title = list(
        text = "ARIMA(0,1,1) Forecast",
        x = 0.5,
        xanchor = "center",
        y = 0.97,
        font = list(color = fred_dark$text, size = 22)
      ),
      legend = list(
        orientation = "h",
        x = 0,
        y = 1.03,
        xanchor = "left",
        font = list(color = fred_dark$text),
        bgcolor = "rgba(0,0,0,0)"
      )
    )

    forecast_plot |>
      config(
        displayModeBar = TRUE,
        scrollZoom = TRUE,
        modeBarButtonsToAdd = c("zoomIn2d", "zoomOut2d", "resetScale2d")
      )
  })

  output$forecast_table <- renderDT({
    forecast_table <- analysis_data()$forecast_table
    forecast_table$date <- format(forecast_table$date, "%Y-%m-%d")

    datatable(
      forecast_table,
      rownames = FALSE,
      options = list(
        pageLength = 12,
        autoWidth = TRUE,
        scrollX = TRUE
      )
    )
  })

  output$probability_plot <- renderPlotly({
    pointwise <- analysis_data()$pointwise_table

    probability_plot <- plot_ly(
      data = pointwise,
      x = ~week,
      y = ~prob_inversion,
      type = "scatter",
      mode = "lines+markers",
      name = "Inversion probability",
      line = list(color = fred_dark$accent_blue, width = 2.5),
      marker = list(size = 6, color = fred_dark$accent_blue_light),
      hovertemplate = paste(
        "Week ahead: %{x}<br>",
        "Probability: %{y:.2%}<extra></extra>"
      )
    )

    probability_plot <- do.call(
      layout,
      c(
        list(probability_plot),
        fred_plotly_layout(
          "Probability of Inversion by Forecast Week",
          xaxis = list(
            title = "Weeks ahead",
            rangeslider = list(visible = TRUE)
          ),
          yaxis = list(title = "Probability", tickformat = ".0%")
        )
      )
    )

    probability_plot <- layout(
      probability_plot,
      margin = list(t = 95, r = 30, b = 60, l = 60),
      title = list(
        text = "Probability of Inversion by Forecast Week",
        x = 0.5,
        xanchor = "center",
        y = 0.97,
        font = list(color = fred_dark$text, size = 22)
      ),
      legend = list(
        orientation = "h",
        x = 0,
        y = 1.03,
        xanchor = "left",
        font = list(color = fred_dark$text),
        bgcolor = "rgba(0,0,0,0)"
      )
    )

    probability_plot |>
      config(
        displayModeBar = TRUE,
        scrollZoom = TRUE,
        modeBarButtonsToAdd = c("zoomIn2d", "zoomOut2d", "resetScale2d")
      )
  })

  output$probability_table <- renderDT({
    datatable(
      analysis_data()$pointwise_table,
      rownames = FALSE,
      options = list(
        pageLength = 12,
        autoWidth = TRUE,
        scrollX = TRUE
      )
    )
  })
}

shinyApp(ui, server)
