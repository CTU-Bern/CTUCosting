
library(CTUCosting)
library(magrittr)
library(bslib)
library(DT)
library(dplyr)
library(shinybusy)
library(shinyalert)

options(shiny.reactlog=TRUE)
# try(sink())
# try(sink())
# tmpfile <- tempfile(fileext = ".txt")
# tmpcon <- file(tmpfile, open = "wt")
# sink(tmpcon, append = TRUE, type = "output")
# sink(tmpcon, append = TRUE, type = "message")
# print(Sys.time())
# print(paste("log file:", tmpfile))

function(input, output, session){

  # output$console <- renderPrint({
  #   readLines(tmpfile)
  # }) |>
  #   bindEvent(input$updateLog)

  output$pkgVersion <- paste("Package version:",
                             packageVersion("CTUCosting") |>
                               as.character()) |>
    renderText()

  # check valid record and costing
  record_ok <- reactive(
    record_costing_exists(record = input$record_id,
                          costing = input$costing,
                          token = input$token)
  )

  output$bad_record <- renderUI({
    req(input$go)
    if(!record_ok()){
      # showNotification(ui = "Check record and costing IDs - at least one of them does not exist in REDCap",
      #                  type = "error",
      #                  )
      shinyalert("Oops!", "Please check your record and costing IDs... at least one does not exist in REDCap", type = "error")
      fluidRow(span("Check your record and costing IDs", style="color:red; margin-left: 15px;"))
    }
  })


  output$rc_link <- renderUI({
    req(input$token)
    #print(paste("TOKEN:", input$token))
    req(record_ok())
    cat(file=stderr(), "Link to redcap done", "\n")
    actionButton("toRedcap", HTML("Click here to go to this <br/>costing in REDCap"),
                 onclick = paste0("window.open('",
                                  create_rc_link(record = input$record_id,
                                 costing = input$costing,
                                 token = input$token), "', '_blank')"))
    # tags$a(href = create_rc_link(record = input$record_id,
    #                              costing = input$costing,
    #                              token = input$token),
    #        "Click here to go to this costing in REDCap", target = "_blank")
  })

  observe({
    query <- parseQueryString(session$clientData$url_search)
    if (!is.null(query[['record']])) {
      updateTextInput(session, "record_id", value = query[['record']])
    }
  })
  observe({
    query <- parseQueryString(session$clientData$url_search)
    if (!is.null(query[['costing']])) {
      updateTextInput(session, "costing", value = query[['costing']])
    }
  })

  d <- reactive({
    req(input$token)
    req(record_ok())
    cat(file=stderr(), "Downloading data", "\n")
    print(paste("RECORD =", input$record_id, "COSTING =", input$costing))
    show_modal_spinner(text = "Downloading data")
    x <- get_data(record = input$record_id, costing = input$costing, token = input$token)
    remove_modal_spinner()
    # print(str(x, 2))
    return(x)
  }) |>
    bindEvent(input$go)

  record_meta_exists <- reactive(
    record_meta_enough(d())
  )
  record_tasks_exist <- reactive(
    record_costings_exist(d())
  )

  output$bad_meta <- renderUI({
    req(input$go)
    message("record_meta_exists:", record_meta_exists())
    cat(file=stderr(), "record_meta_exists:", record_meta_exists(), "\n")
    if(!record_meta_exists()){
      shinyalert("Oops!", "Please check the costing meta information. It must be present.", type = "error")
      fluidRow(span("Check meta information for the costing", style="color:red; margin-left: 15px;"))
    }
  })

  output$bad_costings <- renderUI({
    if(!record_tasks_exist()){
      shinyalert("Oops!", "There don't seem to be any tasks in this record/costing.", type = "error")
      fluidRow(span("Enter tasks to be included in the costing into REDCap.", style="color:red; margin-left: 15px;"))

    }
  })

  meta <- reactive(get_metadata(token = input$token))
  notes <- reactive(get_notes(d(), meta()))
  filter_notes <- reactive(notes_filter(notes(),
                                        input$selected_workpackages,
                                        input$include_fte))

  info <- reactive({
    # print(d()$meta_information)
    req(record_meta_exists())
    ci <- costing_info(d(), meta()$metadata)
    # print(ci)
    ci
  })

  n_downloads <- reactiveValues(n = 0)
  observeEvent(input$go, n_downloads$n <- n_downloads$n  + 1)

  # main page UI ----
  output$costing <- renderUI({
    req(record_meta_exists())
    req(record_tasks_exist())
    # fluidPage(
      layout_columns(
        value_box(title = "Costing",
                  value = textOutput("vb_costing_txt"),
                  showcase = bsicons::bs_icon("folder"),
                  theme = "primary"),
        value_box(title = "Institute",
                  value = textOutput("vb_inst_txt"),
                  showcase = bsicons::bs_icon("bank"),
                  theme = "primary"),
        value_box(title = "Project # / Consulting #",
                  value = textOutput("vb_proj_consulting_txt"),
                  showcase = bsicons::bs_icon("archive"),
                  theme = "primary"),
        value_box(title = "Study duration",
                  value = textOutput("vb_duration_txt"),
                  showcase = bsicons::bs_icon("clock"),
                  "years",
                  theme = "primary"),
        value_box(title = "Rate",
                  value = textOutput("vb_rate_txt"),
                  showcase = bsicons::bs_icon("graph-up-arrow"),
                  theme = "primary"),
        value_box(title = "Total cost",
                  value = textOutput("vb_total_txt"),
                  showcase = bsicons::bs_icon("cash"),
                  theme = "primary"),
        value_box(title = "Discount (%, CHF)",
                  value = textOutput("vb_discount_txt"),
                  showcase = bsicons::bs_icon("percent"),
                  "(as entered in REDCap)",
                  theme = "primary"),


      accordion(
        open = "Total",
        accordion_panel(
          "Work packages",
          dataTableOutput("dt_workpackages"),
          width = 12
        ),
      accordion_panel(
          "Expenses",
          dataTableOutput("dt_expenses"),
          width = 12
        ),
      accordion_panel(
          "Full time equivalents",
          dataTableOutput("dt_fte"),
          width = 12
      ),
      accordion_panel(
          "Total",
          dataTableOutput("dt_totals"),
          width = 12
        )

      ),
      # fluidRow(

      col_widths = c(12, 12, 4, 4,4,4,4, 12,12,12, 12)

    )
  })



  output$vb_costing_txt <- renderText({
    req(record_meta_exists())
    print(paste("ACRONYM:", info()$acronym))
    paste0(info()$acronym, " (", info()$study, ")")
  })
  output$vb_inst_txt <- renderText({
    req(record_meta_exists())
    info()$sponsor
  })
  # output$vb_costingtxt <- renderInfoBox({
  #   req(record_meta_exists())
  #   infoBox(info()$init_or_amendment_txt,
  #           title = "Consulting or Project",
  #           icon = icon(ifelse(info()$initcosting, "ticket", "folder-open")),
  #           color = "red")
  # })
  output$vb_rate_txt <- renderText({
    req(record_meta_exists())
    print(paste("RATE LAB:", info()$ratelab))
    info()$ratelab
  })
  output$vb_duration_txt <- renderText({
    req(record_meta_exists())
    info()$duration
  })
  output$vb_total_txt <- renderText({
    req(record_meta_exists())
    req(record_tasks_exist())
    req(total_cost())
    total_cost()$`Cost (CHF)`[nrow(total_cost())]
  })
  output$vb_discount_txt <- renderText({
    req(record_meta_exists())
    req(record_tasks_exist())
    req(discount())
    # ifelse(!info()$snf, discount()$discount_perc, "N/A - SNF rates apply")
    paste0(discount()$discount_perc, "%, ", info()$discount_chf, " CHF")
  })
  output$vb_proj_consulting_txt <- renderText({
    req(record_meta_exists())
    req(record_tasks_exist())
    req(discount())
    print(paste("PROJNUM:", info()$rpojnum))
    paste0(info()$projnum, " / ", info()$consultingnum)
  })


  # work packages ----
  wp <- reactive(get_workpackage_data(d(), meta()))

  output$bad_workpackage <- renderUI({
    if(any(is.na(as.numeric(wp()$wp)))){
      bad_services <- wp() |>
        filter(is.na(as.numeric(wp))) |>
        pull(Service) |> unique() |> paste(collapse = ", ")
      shinyalert("Oops!", "Check that all work packages are entered.", type = "error")
      fluidRow(span(paste("At least one work package seems to be missing. Please go back to REDCap and enter it/them. See Service(s)", bad_services),
                    style="color:red; margin-left: 15px;"))

    }
  })

  output$select_workpackages <- renderUI({
    req(record_tasks_exist())
    # print(summ_workpackages()$Service)
    print(paste("N SERVICES:", length(unique(wp()$Service))))
    selectInput("selected_workpackages",
                label = "Services in the following box will be included in the costing",
                choices = unique(wp()$Service),
                selected = unique(wp()$Service),
                multiple = TRUE
    )
  })

  output$select_tasks <- renderUI({
    req(record_tasks_exist())
    # print(summ_workpackages()$Service)
    tmp <- wp() |>
      dplyr::filter(Service %in% input$selected_workpackages)
    print(paste("N TASKS:", nrow(tmp)))
    selectInput("selected_tasks",
                label = "Tasks in the following box will be included in  the costing",
                choices = unique(tmp$desc),
                selected = unique(tmp$desc),
                multiple = TRUE
    )
  })

  selected_workpackages <- reactive({
    req(record_tasks_exist())
    # print(summ_workpackages() |> names())
    wp() |>
      filter(Service %in% input$selected_workpackages) |>
      filter(desc %in% input$selected_tasks)
  })

  summ_workpackages <- reactive({
    req(record_tasks_exist())
    wp() |>
      filter(Service %in% input$selected_workpackages) |>
      filter(desc %in% input$selected_tasks) |>
      summarize_by_wp()
  })

  output$dt_workpackages <- renderDataTable({
    if(nrow(summ_workpackages()) > 0){
      print(head(summ_workpackages()))
      out <- summ_workpackages() |>
      rename("Work Package" = wp,
             "Label" = wp_lab) |>
      # select(-c(div, form, rate_name, service)) |>
      relocate(Service) |>
      datatable(rownames = FALSE) |>
      formatCurrency("Cost",
                     currency = "",
                     interval = 3,
                     mark = ",")
    } else {
      out <- tribble(~Service, ~'Work Package', ~Label, ~Description,
              ~Hours, ~Rate, ~Cost) |>
        datatable() |>
        formatCurrency("Cost",
                       currency = "",
                       interval = 3,
                       mark = ",")
    }
    out
  }, server = FALSE)

  # expenses ----
  expenses <- reactive({
    # print(d()$expenses)
    d()$expenses |> #names
      expenses_prep(meta()) #%>%
    # filter(exp_desc %in% expenses_to_keep)
  })
  output$select_expenses <- renderUI({
    # print(expenses() |> names())
    if(nrow(expenses()) > 0){
      selectInput("selected_expenses",
                  label = 'Expenses in the following box will be included in the costing',
                  choices = unique(expenses()$Description),
                  selected = unique(expenses()$Description),
                  multiple = TRUE
      )
    }
  })
  selected_expenses <- reactive({
    expenses() |>
      dplyr::filter(Description %in% input$selected_expenses)
  })
  output$dt_expenses <- renderDataTable(
    selected_expenses() |>
      select(Division, Description, Amount, wp_lab) |>
      rename("Work Package" = wp_lab),
    rownames = FALSE,
    server = FALSE
  )

  # Full time equivalents ----
  fte <- reactive({
    d() |> get_ftes(meta = meta(),
                    include = input$include_fte)
  })

  output$bad_fte_role <- renderUI({
    if(fte()$fte){
      if(length(unique(fte()$role)) < length(fte()$role)){
        shinyalert("Oops!", "Duplicate FTE job title found", type = "error")
        fluidRow(span("FTE Job Titles should be unique to avoid confusion in the costing",
                      style="color:red; margin-left: 15px;"))

      }
    }
  })

  output$dt_fte <- renderDataTable({
    fte()$costs |>
      rename(Description = desc,
             Cost = cost,
             Units = units,
             FTEs = prop) |>
      datatable(rownames = FALSE) |>
      formatCurrency("Cost",
                     currency = "",
                     interval = 3,
                     mark = ",")
  }, server = FALSE)

  # calculate discount ----
  discount <- reactive({
    # req(record_tasks_exist())
    # out <- NA
    # print(paste("Costing: ", info()$initcosting))
    # print(paste("discount_db: ", info()$discount_db))
    # print(paste("snf: ", info()$snf))
    # print(paste("dlf: ", info()$dlf))
    # if(nrow(selected_workpackages()) > 0){
      # print(selected_workpackages())
      out <- calc_discount(selected_workpackages(),
                           initcosting = info()$initcosting,
                           discount_db = info()$discount_db,
                           snf = info()$snf,
                           dlf = info()$dlf)
      # print(paste("DISCOUNT:", out))
    # }
    out
  })
  output$dt_discount <- renderDataTable({
      req(record_tasks_exist())
      # print(discount())
      discount()
    },
    rownames = FALSE,
    server = FALSE
  )
  overhead_tab <- reactive(overhead(discount()))

  # totals ----
  total_cost <- reactive({
    req(record_tasks_exist())
    totals(workpackages = selected_workpackages(),
           expenses = selected_expenses(),
           discount = discount(),
           discount_chf = info()$discount_chf,
           overhead = overhead_tab(),
           fte = fte(),
           snf = info()$snf,
           rate = info()$rate,
           dlf = info()$dlf)
  })
  output$dt_totals <- renderDataTable({
    # print(total_cost())
    total_cost()
  },
  rownames = FALSE,
  server = FALSE
  )

  # SNF format ----
  ## init tables (these store the data to be used elsewhere) ----
  snf_table <- reactiveValues(data = NULL,
                              expenses = NULL)
  observe({
    req(record_tasks_exist())
    snf_table$data <- create_snf_proportions_table(selected_workpackages(), info()$duration)
  })
  observe({
    req(record_tasks_exist())
    snf_table$expenses <- create_snf_expense_proportions_table(selected_expenses(), info()$duration)
  })
  ## work packages ----
  # update the snf_table object when the table is edited
  observeEvent(input$snf_proportions_cell_edit, {
    print("updating cost proportions table")
    # print(snf_table$data)
    info <- input$snf_proportions_cell_edit
    i <- info$row
    j <- info$col
    v <- info$value
    snf_table$data[i, j] <- isolate(coerceValue(v, snf_table$data[i, j]))
    # update rowsums?
    snf_table$data[, "Row sum"] <- apply(snf_table$data[, 1:info()$duration], 1, sum)
  })
  # editable proportions table
  output$snf_proportions <- renderDataTable({
    print("snf_proportions")
    snf_table$data |>
      datatable(editable = TRUE,
                options = list(paging = FALSE)) |>
      formatStyle("Row sum",
                  backgroundColor = styleInterval(c(0.999, 1.001),
                                                  c("#fc4c4c", "#60fa48", "#fc4c4c")))
    },
    editable = TRUE)
  # reactive containing the workpackage time/cost distributed through time
  snf_costs <- reactive({
    print("updating costs")
    # print(snf_table$data)
    # print(snf_table$data |> str())
    snf_cost_table(summ_workpackages(), snf_table$data)
  })
  # print the table
  output$snf_cost <- renderDataTable({
    # print(snf_costs())
    snf_costs()$shiny |>
      datatable(options = list(paging = FALSE),
                escape = FALSE)
    })

  ## expenses ----
  # update the snf_table object when the table is edited
  observeEvent(input$snf_expenses_proportions_cell_edit, {
    print("updating expenses proportions table")
    # print(snf_table$expenses)
    info <- input$snf_expenses_proportions_cell_edit
    i <- info$row
    j <- info$col
    v <- info$value
    print(v)
    print(snf_table$expenses[i, j])
    snf_table$expenses[i, j] <- isolate(coerceValue(v, snf_table$expenses[i, j]))
    print("value set")
    # update rowsums?
    snf_table$expenses[, "Row sum"] <- apply(snf_table$expenses[, 1:info()$duration], 1, sum)
  })
  # editable proportions table
  output$snf_expenses_proportions <- renderDataTable({
    print("snf_expenses_proportions")
    snf_table$expenses |>
      datatable(editable = TRUE,
                options = list(paging = FALSE)) |>
      formatStyle("Row sum",
                  backgroundColor = styleInterval(c(0.999, 1.001),
                                                  c("#fc4c4c", "#60fa48", "#fc4c4c")))
    },
    editable = TRUE)
  # reactive containing the expenses distributed through time
  snf_expenses <- reactive({
    print("updating expenses")
    # print(snf_table$expenses)
    # print(snf_table$expenses |> str())
    snf_expenses_cost_table(selected_expenses(), snf_table$expenses)
  })
  # print the table
  output$snf_expense <- renderDataTable({
    print("snf_expense")
    snf_expenses()$shiny |>
      datatable(options = list(paging = FALSE),
                escape = FALSE)
    })

  ## UI ----
  output$snf_ui <- renderUI({
    req(record_tasks_exist())

    accordion(
      open = TRUE,
      accordion_panel(
        "Distribute working time across the project time",
        "Enter proportion of hours expected for each year and each work package.",
        "Click the yearly values and enter a value below 0 and 1. Each row should sum to 1. The right hand column will turn green when it does.",
        dataTableOutput("snf_proportions"),
        "Those proportions equate to the following amounts per year:",
        dataTableOutput("snf_cost"),
        width = 12
      ),
      accordion_panel(
        "Distribute expenses across the project time",
        dataTableOutput("snf_expenses_proportions"),
        "Those proportions equate to the following amounts per year:",
        dataTableOutput("snf_expense"),
        width = 12
      ),
      accordion_panel(
        "Download SNF style budget",
        "The excel file returned here is to be provided to the sponsor for submission to the SNF.",
        "Please make sure to open the file and click 'enable editing', so that Excel can evaluate the formulae.",
        downloadButton("snf_excel", "Download SNF budget")
      )
      )

  })

  # pass snf_cost into pdf function, together with input$costing_type

  # downloads ----
  ## PDF ----
  fname <- function(cons_num,
                    proj_num,
                    studyname){
      num <- cons_num
      if(!is.na(proj_num)) num <- paste0("Amendment_P", proj_num)
      paste0("Costing_", num, "_", studyname, "_", Sys.Date(), ".pdf")
  }

  output$pdf <- downloadHandler(
    filename = function(cons_num = info()$consultingnum,
                        proj_num = info()$projnum,
                        studyname = info()$acronym){
      num <- cons_num
      if(!is.na(proj_num)) num <- paste0("Amendment_P", proj_num)
      paste0("Costing_", num, "_", studyname, "_", Sys.Date(), ".pdf")
    },
    content = function(file){

      # print(info())
      # dot <- reactiveValuesToList(info())
      print("preparing PDF inputs")
      inputs <- info()
      inputs$workpackages <- summ_workpackages()
      inputs$summ_discount <- discount()
      inputs$discount <- max(0, try(sum(discount()$discount_amount)), na.rm = TRUE)
      print("   tables")
      inputs$expenses <- selected_expenses() |> select_expenses_for_pdf()
      inputs$total <- total_cost()
      # inputs$cturep <- input$cturep
      print("   texts")
      print("     first page")
      inputs$first_page_text <- info()$costing_txt
      print("     notes")
      inputs$notes <- concat_notes(filter_notes())
      print("   breaks")
      inputs$break_ftes <- input$break_ftes
      inputs$break_totals <- input$break_totals
      inputs$break_notes <- input$break_notes
      inputs$break_projinfo <- input$break_projinfo
      # print(concat_notes(notes()))
      print("fte input")
      inputs$fte <- fte()
      inputs$include_design <- input$include_design
      inputs$include_int <- input$include_int
      inputs$include_participants <- input$include_participants
      inputs$filename <- fname(info()$consultingnum, info()$projnum, info()$acronym)

      inputs$break_tasks <- unlist(strsplit(input$break_tasks, ","))

      # print(str(inputs))

      show_modal_spinner(text = "Compiling PDF",
                         spin = "pixel")
      print("gen_pdf():")
      gen_pdf(
        output = file,
        inputs = inputs,
        copy_html = TRUE
      )

      remove_modal_spinner()
    }
  )

  ## admin ----
  output$admin <- downloadHandler(
    filename = function(cons_num = info()$consultingnum,
                        proj_num = info()$projnum,
                        studyname = info()$acronym){
      num <- cons_num
      if(!is.na(proj_num)) num <- paste0("Amendment_P", proj_num)
      paste0("Costing_", num, "_", studyname, "_", Sys.Date(), ".xlsx")
    },
    content = function(file){

      print("ADMIN INFO, FTE:")
      print(fte())

      dfs <- list(
        info = info() |> info_to_dataframe()
        , workpackages = summ_workpackages() |> select_for_admin()
        # , discount <- sum(discount()$discount_amount)
        , FTE = fte()$costs |> select_fte_for_admin()
        , expenses = selected_expenses() |> select_expenses_for_admin()
        , total = total_cost()
        , all_tasks = selected_workpackages() |>
            select(div, Service, item, desc, Hours, Units, Cost, wp_lab)
      )

      # print(str(inputs))

      # show_modal_spinner(text = "Compiling file")
      # print("xl")

      writexl::write_xlsx(dfs, file)

      # remove_modal_spinner()
    }
  )

  ## SNF ----
  output$snf_excel <- downloadHandler(
    filename = function(cons_num = info()$consultingnum,
                        studyname = info()$acronym){
      paste0("SNF_Costing_", cons_num, "_", studyname, "_", Sys.Date(), ".xlsx")
    },
    content = function(file){

      output <- snf_iict_yearly_budget(
        hours = snf_costs()$hours,
        expenses = snf_expenses()$cost,
        info = info(),
        debug = TRUE
      )

      file.copy(output, file)

    }
  )

}


