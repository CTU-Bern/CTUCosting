

d <- get_testdata_r1()
meta <- get_testdata_meta()
#
notes <- get_notes(d, meta)
#
# concat_notes(notes)



test_that("get_notes extracts correct variables", {

  dfs <- list(
    tibble::tribble(
      ~foo, ~bar, ~foobar_notes,
      "a", "b", "c"
    ),
    tibble::tribble(
      ~flibble, ~fribble, ~dml_notes_standard,
      "aa", "bb", "cc"
    ),
    tibble::tribble(
      ~flobble, ~frobble, ~dmf_notes_2, ~dmf_notes,
      "aa", "bb", "ccc", "ddd"
    )
  )

  x <- get_notes(dfs)
  expect_true("foobar_notes" %in% names(x[[1]]))
  expect_true("dml_notes_standard" %in% names(x[[2]]))
  # concatenation of multiple columns to a single value
  expect_true(x[[3]] == "ddd\n\nccc")

})





