# lookup tables

rateopts <- tibble::tribble(
~code, ~label,
1, "Internal",
2, "External non-profit",
3, "External for-profit",
4, "SNF",
5, "SNF 2026"
)

# lookup table of service to service name to division and formname
servicenames <- read.csv(system.file("intdata/servicenames.csv", package = "CTUCosting"))
#   tibble::tribble(
#   ~service, ~Service,                    ~div ,   ~form,
#   "docdev", "Document development",      "MON",   "document_development",
#   "dml",    "Data management (light)",   "DM",    "dm_redcap_light",
#   "dmf",    "Data management (full)",    "DM",    "dm_full_services",
#   "sta",    "Statistics",                "STA",   "statistics",
#   "csm",    "Clinical study management", "CSM",   "clinical_study_management",
#   "qm",     "Quality management",        "QM",    "quality_management",
#   "ci",     "Clinical investigation",    "CI",    NA,
#   "admin",  "Administration",            "ADMIN", NA,
#   "sen",    "Seniors",                   "SEN",   NA,
#   "rs",     "Regulatory services",       "MON",   "regulatory_support",
#   "sw",     "Study website",             "DM",    "study_website",
#   "cloud",  "ShareFile cloud",           "DM",    "sharefile_cloud",
#   "mon",    "Monitoring",                "MON",   "monitoring_onsite_remote",
#   "cdm",    "Central data monitoring",   "MON",   "central_data_monitoring",
#   "cdmra",  "Central data monitoring",   "MON",   "central_data_monitoring",
#   "ra",     "Research assistant",        NA,      NA
# )

# lookup table of division abbreviation and full name
divnames <- read.csv(system.file("intdata/divisionnames.csv", package = "CTUCosting"))
#   tibble::tribble(
#   ~div, ~division,
#   "ADMIN", "Administration",
#   "CI", "Clinical Investigation",
#   "CSM", "Clinical Study Management",
#   "DM", "Data Management",
#   "MON", "Monitoring",
#   "QM", "Quality Management",
#   "SEN", "Seniours",
#   "STA", "Statistics",
# )

# lookup table of variable prefixes and applicable rates
ratenames <- tibble::tribble(
  ~service, ~rate_name,
  "docdev", "rate_csm",
  "dml",    "rate_dm",
  "dmf",    "rate_dm",
  "dmr",    "rate_dm",
  "dm",     "rate_dm",
  "sta",    "rate_sta",
  "csm",    "rate_csm",
  "qm",     "rate_qm",
  "ci",     "rate_ci",
  "admin",  "rate_admin",
  "sen",    "rate_senior",
  "rs",     "rate_csm",
  "sw",     "rate_dm",
  "cloud",  "rate_dm",
  "mon",    "rate_mon",
  "cdm",    "rate_mon",
  "ra",     "rate_ra",
  "cdmra",  "rate_ra",
  "gen",    "rate_mon"

)

# clinic/institute heads
clinic_heads <- read.csv(system.file("intdata/clinic_heads.csv", package = "CTUCosting"))

# snf division lookup
snf_division_lkup <- read.csv(system.file("intdata/snfworkpackagelookup.csv", package = "CTUCosting"))
