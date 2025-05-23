
wp <- tibble::tribble(
  ~wp, ~Hours, ~Cost, ~Units,
  "045.0",  100,  1000, 1,
  "100.0",  100,  1000, 1,
  "100.1",  100,  1000, 1,
  "100.2",  100,  1000, 1,
)

exp <- tibble::tribble(
  ~wp, ~Amount,
  "045.0",  1000,
)

disc <- calc_discount(wp, TRUE, 3, FALSE)
disc2 <- calc_discount(wp, FALSE, 5, FALSE)
disc3 <- calc_discount(wp, FALSE, 0, FALSE)

fte <- list(fte = FALSE)
fte2 <- list(fte = TRUE,
             costs = tibble::tribble(
               ~desc, ~prop, ~units, ~cost,
               "A", 0.5, 1, 100,
             ))

oh <- overhead(disc)
oh3 <- overhead(disc3)

test_that("internal totals", {
  tot <- totals(wp,
                expenses = exp,
                discount = disc,
                overhead = oh,
                rate = "Internal",
                snf = FALSE,
                fte = fte)

  expect_equal(nrow(tot), 5)
  expect_equal(unlist(tot[grepl("Discount \\(3%\\)", tot$Description),2]),
               "  -90", ignore_attr = TRUE)
  expect_equal(unlist(tot[grepl("Total", tot$Description),2]), "5'301", ignore_attr = TRUE)
  expect_true("Operating costs (10%)" %in% tot$Description)
  expect_true(!"University overhead (10%)" %in% tot$Description)

  tot2 <- totals(wp,
                 expenses = exp,
                 discount = disc2,
                 overhead = oh,
                 rate = "External non-profit",
                 snf = FALSE,
                 fte = fte)
  expect_equal(nrow(tot2), 5)
  expect_equal(unlist(tot2[grepl("Discount \\(5%\\)", tot2$Description),2]), " -150", ignore_attr = TRUE)
  expect_equal(unlist(tot2[grepl("Total", tot2$Description),2]), "5'241", ignore_attr = TRUE)
  expect_true("Operating costs (10%)" %in% tot2$Description)
  expect_true(!"University overhead (10%)" %in% tot2$Description)


  tot3 <- totals(wp,
                 expenses = exp,
                 discount = disc3,
                 discount_chf = 1000,
                 overhead = oh3,
                 rate = "External non-profit",
                 snf = FALSE,
                 fte = fte)
  expect_equal(unlist(tot3[grepl("Discount", tot3$Description),2]), "-1'000", ignore_attr = TRUE)
})

test_that("external totals", {
  tot3 <- totals(wp,
                expenses = exp,
                discount = disc,
                overhead = oh,
                rate = "External for-profit",
                snf = FALSE,
                fte = fte)
  expect_equal(nrow(tot3), 6)
  expect_equal(unlist(tot3[grepl("Discount \\(3%\\)", tot3$Description),2]), "  -90", ignore_attr = TRUE)
  expect_equal(unlist(tot3[grepl("Total", tot3$Description),2]), "5'692", ignore_attr = TRUE)
  expect_equal(unlist(tot3[grepl("University overhead", tot3$Description),2]),
               unlist(tot3[grepl("Operating costs", tot3$Description),2]), ignore_attr = TRUE)
  expect_true("Operating costs (10%)" %in% tot3$Description)
  expect_true("University overhead (10%)" %in% tot3$Description)


  tot4 <- totals(wp,
                 expenses = exp,
                 discount = disc2,
                 overhead = oh,
                 rate = "External for-profit",
                 snf = FALSE,
                 fte = fte)
  expect_equal(nrow(tot4), 6)
  expect_equal(unlist(tot4[grepl("Discount \\(5%\\)", tot4$Description),2]), " -150", ignore_attr = TRUE)
  expect_equal(unlist(tot4[grepl("Total", tot4$Description),2]), "5'632", ignore_attr = TRUE)
  expect_equal(unlist(tot4[grepl("University overhead", tot4$Description),2]), unlist(tot4[3,2]), ignore_attr = TRUE)
  expect_true("Operating costs (10%)" %in% tot4$Description)
  expect_true("University overhead (10%)" %in% tot4$Description)


})

test_that("fte totals", {
  tot3 <- totals(wp,
                expenses = exp,
                discount = disc,
                overhead = oh,
                rate = "External for-profit",
                snf = FALSE,
                fte = fte2)
  expect_equal(nrow(tot3), 7)
  expect_equal(unlist(tot3[grepl("Discount \\(3%\\)", tot3$Description),2]), "  -90", ignore_attr = TRUE)
  expect_equal(unlist(tot3[grepl("Total", tot3$Description),2]), "5'792", ignore_attr = TRUE)
  expect_equal(unlist(tot3[grepl("University overhead", tot3$Description),2]),
               unlist(tot3[grepl("Operating costs", tot3$Description),2]), ignore_attr = TRUE)
  expect_equal(unlist(tot3[grepl("FTE", tot3$Description),2]), "  100", ignore_attr = TRUE)
  expect_true("Operating costs (10%)" %in% tot3$Description)
  expect_true("University overhead (10%)" %in% tot3$Description)


  tot4 <- totals(wp,
                 expenses = exp,
                 discount = disc2,
                 overhead = oh,
                 rate = "Internal",
                 snf = FALSE,
                 fte = fte2)
  expect_equal(nrow(tot4), 6)
  expect_equal(unlist(tot4[grepl("Discount \\(5%\\)", tot4$Description),2]), " -150", ignore_attr = TRUE)
  expect_equal(unlist(tot4[grepl("Total", tot4$Description),2]), "5'341", ignore_attr = TRUE)
  expect_equal(unlist(tot4[grepl("FTE", tot4$Description),2]), "  100", ignore_attr = TRUE)
  expect_true("Operating costs (10%)" %in% tot4$Description)
  expect_true(!"University overhead (10%)" %in% tot4$Description)
  expect_true("FTE costs" %in% tot4$Description)

})

test_that("snf totals", {
  tot3 <- totals(wp,
                expenses = exp,
                discount = disc,
                overhead = oh,
                rate = "SNF",
                snf = TRUE,
                fte = fte2)

  expect_true(!"Operating costs (10%)" %in% tot3$Description)
  expect_true(!"University overhead (10%)" %in% tot3$Description)

})
