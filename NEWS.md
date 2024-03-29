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
