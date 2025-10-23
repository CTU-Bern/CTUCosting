#' extract generic costing information from redcap data
#'
#' @param data dataset from redcap
#' @param metadata dataset from redcap (i.e. meta$metdata)
#'
#' @importFrom dplyr pull
#' @export
costing_info <- function(data, metadata){

  Clinic <- Head.of.clinic <- NULL

  dmf <- data$dm_full_services

  data <- data$meta_information
  # data <- d$meta_information
  consultingnum <- data$consulting_num
  studyname <- data$study
  initcosting <- data$initial_costing == 1
  projnum <- data$initial_projnum

  title_txt <- paste("Costing for consulting",
                     ifelse(is.na(consultingnum),
                            "[not a consulting]",
                            consultingnum),
                     ":", studyname)

  init_or_amendment_txt <- ifelse(initcosting,
                                  "This is the intial costing for the project",
                                  paste("This is an amendment to project", projnum))

  # institute/company
  print(data$sponsor_insel)
  insel <- data$sponsor_insel == 1
  if(insel){
    inst <- specific_option(metadata, data, "institute")
    sign <- clinic_heads |>
      filter(Clinic == inst) |>
      pull(Head.of.clinic)
  } else {
    if(data$institute_noninsel %in% c(7,8,88)){
      inst <- data$company
      sign <- data$institute_auth
    } else {
      inst <- specific_option(metadata, data, "institute_noninsel")
      if(inst %in% c("Department for Biomedical Research (DBMR)",
                     "Direktion Pflege",
                     "Institut f\u00FCr Physiotherapie",
                     "Institute of Social and Preventive Medicine (ISPM)",
                     "Berner Institut f\u00FCr Hausarztmedizin (BIHAM)"
                     )){
        sign <- clinic_heads |>
          filter(Clinic == inst) |>
          pull(Head.of.clinic)
      } else {
        sign <- "UNKNOWN - PLEASE CONFIRM"
      }
    }
  }

  rate <- specific_option(metadata, data, "rate")

  # DLF
  # LOGIC FOR DETERMINING WHETHER DLF FUNDING IS RELEVANT
  dlf <- insel

  # vat
  vat <- !(insel | data$institute_noninsel %in% c(1:6, 8))

  fn <- function(m, d, v){
    if(nrow(d) > 0){
      out <- ifelse(!is.na(d[, v]),
             specific_option(m, d, v),
             NA)
    } else {
      out <- NA
    }
    return(out)
  }


  return(
    list(
      # project
      title_txt =             title_txt,
      projnum =               projnum,
      consultingnum =         consultingnum,
      studyname =             studyname,
      acronym =               data$study_abbr,
      initcosting =           initcosting,
      init_or_amendment_txt = init_or_amendment_txt,
      snf =                   data$rate == 4,
      # dlf =                   dlf,
      # signatories
      sponsor =               inst,
      sponsor_responsible =   data$sponsor,
      customer_function =     ifelse(length(data$sponsor_fun) > 0, data$sponsor_fun, NA),
      sign =                  sign,
      # rate
      ratelab =               rateopts$label[data$rate],
      internal =              data$sponsor_insel == 1,
      # design
      design =                fn(metadata, data, "study_design"),
      design_src =            fn(metadata, data, "study_design_src"),
      complexity =            fn(metadata, data, "study_complexity"),
      # durations
      duration =              data$study_duration,
      duration_src =          fn(metadata, data, "study_duration_src"),
      duration_enrol =        data$study_enrol,
      duration_enrol_src =    fn(metadata, data, "study_enrol_src"),
      # participants/sites
      participants =          data$n_participants,
      participants_src =      fn(metadata, data, "n_participants_src"),
      sites =                 data$n_sites,
      sites_src =             fn(metadata, data, "n_sites_src"),
      location =              fn(metadata, data, "site_location"),
      location_src =          fn(metadata, data, "site_location_src"),
      # visits
      n_visits =              data$n_visits,
      n_visits_src =          fn(metadata, data, "n_visits_src"),
      # variables/database
      n_vars =                data$n_vars,
      n_vars_src =            fn(metadata, data, "n_vars_src"),
      n_database =            data$n_db,
      n_database_src =        fn(metadata, data, "n_db_src"),
      # other
      intervention =          fn(metadata, data, "int_type"),
      discount_db =           ifelse(!is.na(data$discount), data$discount, 0),
      discount_chf =          ifelse(!is.na(data$discount_chf), data$discount_chf, 0),
      costing_txt =           ifelse(initcosting, data$costing_txt_init, data$costing_txt_amend),
      full_service_db =       fn(metadata, dmf, "dmf_cdms"),
      vat =                   vat
    )
  )

}
