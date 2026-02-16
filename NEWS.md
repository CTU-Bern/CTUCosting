# CTUCosting 0.7.17 (2026-02-16)

* update new head of ISPM

# CTUCosting 0.7.16 (2026-02-04)

* update new head of Notfallmedizin

# CTUCosting 0.7.15 (2025-12-11)

* update new head of gastroenterologie

# CTUCosting 0.7.14 (2025-11-06)

* Support for R&R matrix
* 'cost estimate' rather than 'cost proposal'

# CTUCosting 0.7.13 (2025-10-29)

* Correct the discount for the new SNF rate

# CTUCosting 0.7.12 (2025-10-28)

* Add SNF 2026 rate

# CTUCosting 0.7.11 (2025-10-23)

* ensure that notes field from generic form is included in the PDF
* UNIBE projects are not subject to VAT

# CTUCosting 0.7.10 (2025-09-24)

* switch email addresses to operations.dcr

# CTUCosting 0.7.9 (2025-08-21)

* adding a rounding (ceiling) of hours and costs to prevent partial amounts that mess up the formatting

# CTUCosting 0.7.8 (2025-06-03)

* bug fix for costings erroring without FTEs

# CTUCosting 0.7.7 (2025-05-26)

* Add role name to admin info

# CTUCosting 0.7.6 (2025-05-21)

* Support for multiple FTEs in a costing

# CTUCosting 0.7.5 (2025-05-15)

* Addition of "Zentrum für Rehabilitation und Sportmedizin" (which is not technically a clinic, so was previously missed)

# CTUCosting 0.7.4 (2025-03-17)

* update new head of gastroenterologie

# CTUCosting 0.7.3 (2025-03-13)

* added one clinic with its director

# CTUCosting 0.7.2 (2025-01-17)

* updated clinic director names, updated clinic names

# CTUCosting 0.7.1 (2024-11-27)

* Added a comment column for admin about fixed costs for DB closure.

# CTUCosting 0.7.0 (2024-11-01)

* Discounts are no longer calculated based on the number of hours. Discounts are defined in REDCap.
* Support for CHF value discount
* Add rate for Regulatory Affairs in the SNF template

# CTUCosting 0.6.1 (2024-10-09)

* bug fix: notes were stopping the PDF from being generated

# CTUCosting 0.6.0 (2024-09-27)

* restyle to approximate DCR letterhead, including DCR logo
* switch email addresses to admin.dcr
* improve header alignment in FTE table in PDF
* refer to operating costs instead of internal project management
* bug fix: FTEs notes are now included in the PDF
* bug fix: fix location of page break prior to notes section

# CTUCosting 0.5.4 (2024-07-16)

* update SNF template to 2024 rates
* add number of units and cost per unit to the expenses form in admin info excel file

# CTUCosting 0.5.3 (2024-06-03)

* update head of intensive medicine

# CTUCosting 0.5.2 (2024-06-03)

* change sponsor to customer in admin info
* include task level info in admin info
* update neurology head to Urs Fischer

# CTUCosting 0.5.1 (2024-05-21)

* bug fix: xlsx files for SNF projects with expenses failed (8415b16).
* Universitätsklinik für Viszerale Chirurgie und Medizin split into two units: 'Viszerale und transplantationschirurgie' and 'Gastroenterologie' with separate clinic directors.

# CTUCosting 0.5.0 (2024-04-18)

* Add support for costings from the DM reporting group.
* Refer to Institution rather than Sponsor on the costing PDF.
* MZ noticed that the filename in adobe is sometimes shown as "A test document". This update changes it to the filename instead.

# CTUCosting 0.4.9 (2024-04-10)

* Bug fix: app crashed if only FTEs were entered.

# CTUCosting 0.4.8

* Changes to clinic names:
  * Pneumologie -> Pneumologie, Allergologie und klinische Immunologie
  * Rheumatology, immunologie und allergology -> rheumatologie und immunologie

# CTUCosting 0.4.7

* document development and regulatory affairs should use CSM rate rather than the MON rate

# CTUCosting 0.4.6

* bug fix: filtering of notes did not work correctly when there were no notes (bug introduced in v0.4.5).
* bug fix: discount row should not be shown for SNF projects.
* Improved alignment of cost column in PDF output

# CTUCosting 0.4.5

* University overhead only relevant for EXTERNAL FOR-PROFIT projects.
* Filter notes when work packages are filtered.

# CTUCosting 0.4.4

* Bug fix: Shiny app errored if the number of years was missing.
* Add filter for FTE positions. 
* Add signatories for a few institutes.
* Include FTE info in admin information.
* Support for General Support work package. Improved support for generic form.
* Styling of the cost column in the PDF adapted - right align, rounding, and consistent thousands separator.
* All costs rounded to the nearest CHF, note added to PDF.
* Note that the discount is not applied to all packages added to PDF.
* App now generates an error message if a work package is not entered (which previously resulted in the app crashing).
* Include 'Amendment_project number' in PDF and admin file names if the project number is available.
* Bug fix: SNF table generation failed when a single work package was involved.
* Improve test coverage from ca 50% to >80% (according to `covr`)

# CTUCosting 0.4.3

* `totals` updated (Internal PM not relevant for SNF projects).
* Option to add remove page break between first and second page added to UI/Rmd template.
* No notes resulted in a horizontal rule in PDF. That has been fixed.

# CTUCosting 0.4.2

* Setting Urs as clinic head was premature. Reset to Claudio.
* Minor internal documentation changes to pass `R CMD CHECK`.
* Add UNIBE favicon.
* Add the version number to the bottom of the sidebar.

# CTUCosting 0.4.1

* Update Neurology clinic head (Urs Fischer).

# CTUCosting 0.4.0

* Initial version.
