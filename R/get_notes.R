#' extract external note fields
#' @param data list of dataframes from get_data
#' @param meta metadata from get_meta
#' @importFrom dplyr select ends_with any_of where
#' @export
get_notes <- function(data, meta){

  vals <- lapply(data, function(x){
    if(nrow(x) > 0){
      tmp <- x |>
        select(any_of("dml_notes_standard"), ends_with("notes"), any_of("dmf_notes_2"))
      if(nrow(tmp) > 0) tmp <- tmp |> select(where(~any(!is.na(.x))))
      if(ncol(tmp) > 1) tmp <- paste(tmp, collapse = "\n\n")
      if("fte_notes" %in% names(x)) tmp <- paste(paste(x$fte_role, x$fte_notes, sep = "\n\n"), collapse = "\n\n")
      unlist(tmp)
    }
  })

  tmp <- vals[unlist(sapply(vals, function(x) length(x) > 0 && !is.na(x)))]

  if("generic" %in% names(tmp)){
    gendat <- data$generic |>
      mutate(service = specific_option(meta$metadata, data$generic, "gen_div"))

    divname <- divnames$division[match(gendat$service, divnames$div)]
    attr(tmp$generic, "div") <- divname
  }


  tmp

}

#' concatenate external note fields with division/workpackage
#' @param notes list of notes from get_notes
#' @param header_sep separater between workpackage and note
#' @param collapse line break between notes
#' @export
concat_notes <- function(notes,
                         header_sep = "\n\n",
                         collapse = "\n\n"){

  if(length(notes) > 0){
    notes <- notes[!sapply(notes, function(x) x %in% c("NA", "NA\n\nNA"))]

    servnames <- servicenames

    if("generic" %in% names(notes)){
      # names(notes)[names(notes) == "generic"] <- attr(notes$generic, "div")

      servnames <- rbind(servnames,
                         data.frame(
                           service = "",
                           Service = attr(notes$generic, "div"),
                           div = "",
                           form = "generic"
                         ))
    }

    paste0("**", servnames$Service[match(names(notes), servnames$form)], "**",
                   header_sep, notes, collapse = collapse)

  }
}

# d <- get_data(2,1,token)
# n <- get_notes(d)
# concat_notes(n)

#' filter notes based on selected workpackages
#' @param notes list of notes from get_notes
#' @param selected_workpackages which packages have been selected
#' @param fte logical - whether to include full time equivalent
#' @param generic logical - whether to include the generic form
#' @export
notes_filter <- function(notes, selected_workpackages, fte, generic = TRUE){
  if(length(notes) > 0){
    wps <- selected_workpackages
    services <- servicenames |>
      filter(Service %in% wps) |>
      filter(form %in% names(notes)) |>
      pull(form) |>
      unique() |>
      na.omit()
    print(paste("NOTESFILTER: ", services))
    if(fte & "full_time_equivalent" %in% names(notes)) services <- c(services, "full_time_equivalent")
    if(generic & "generic" %in% names(notes)) services <- c(services, "generic")
    out <- notes[services]
    print("filtered notes names")
    print(names(out))
  } else {
    out <- notes
  }
  return(out)
}
