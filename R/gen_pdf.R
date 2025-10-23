
#' generate PDF costing report
#'
#' @param output output file name
#' @param inputs list of data passed to rmarkdown (see Rmd file for definitions)
#' @param copy_html binary, whether to copy the html file to the output directory (primarily for testing purposes)
#' @export
gen_pdf <- function(output,
                    inputs,
                    copy_html = FALSE
                    ){

  tempdir <- tempdir()
  Rmd <- file.path(tempdir, "template.Rmd")
  pageparts <- file.path(tempdir, "page-parts.css")
  style <- file.path(tempdir, "style.scss")
  tabs <- file.path(tempdir, "custom_tbls.css")
  file.copy(system.file("ext", "template.Rmd", package = "CTUCosting"), Rmd)
  file.copy(system.file("ext", "page-parts.css", package = "CTUCosting"), pageparts)
  file.copy(system.file("ext", "style.scss", package = "CTUCosting"), style)
  file.copy(system.file("ext", "custom_tbls.css", package = "CTUCosting"), tabs)
  file.copy(system.file("ext", "01_DCR_CMYK_POS.svg", package = "CTUCosting"), tempdir)
  file.copy(system.file("ext", "ub_16pt-cmyk.svg", package = "CTUCosting"), tempdir)
  html <- file.path(tempdir, "costing.html")

  rmarkdown::render(Rmd,
                    pagedown::html_paged(template = system.file("ext", "template.html", package = "CTUCosting")
                                         , css = c(pageparts
                                                 , style
                                                 , tabs
                                         )
                                         ),
                    output_file = html,
                    params = list(
                      studyname = inputs$studyname,
                      acronym = inputs$acronym,
                      projnum = inputs$projnum,
                      consultingnum = inputs$consultingnum,
                      sponsor = inputs$sponsor,
                      contact = inputs$sponsor_responsible,
                      design = inputs$design,
                      intervention = inputs$intervention,
                      n_participants = inputs$participants,
                      n_sites = inputs$sites,
                      location = inputs$location,
                      conduct_time = inputs$duration,
                      # cturep = inputs$cturep,
                      workpackages = inputs$workpackages,
                      internal = inputs$internal,
                      total = inputs$total,
                      discount = inputs$summ_discount,
                      notes = inputs$notes,
                      expenses = inputs$expenses,
                      break_ftes = inputs$break_ftes,
                      break_totals = inputs$break_totals,
                      break_tasks = inputs$break_tasks,
                      break_notes = inputs$break_notes,
                      break_projinfo = inputs$break_projinfo,
                      first_page_text = inputs$costing_txt,
                      initcosting = inputs$initcosting,
                      fte = inputs$fte,
                      include_design = inputs$include_design,
                      include_int = inputs$include_int,
                      include_participants = inputs$include_participants,
                      filename = inputs$filename,
                      vat = inputs$vat
                      ),
                    clean = FALSE
                    )

  tmp <- readLines(html)
  writeLines(gsub("#(.*)(\\.gt_.* \\{)$", "\\2", tmp), html)
  pagedown::chrome_print(html, output,
                         options = list(paperWidth = 8.3, paperHeight = 11.7, box_model = "content"),
                         extra_args = c("--no-sandbox"))
  if(copy_html){
    file.copy(html, sub("pdf", "html", output), overwrite = TRUE)
  }



}

# gen_pdf("~/test.pdf", prepped, TRUE)

