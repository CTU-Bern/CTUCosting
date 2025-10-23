test_that("get_notes extracts correct variables", {

  dfs <- list(
    statistics = tibble::tribble(
      ~foo, ~bar, ~foobar_notes,
      "a", "b", "c"
    ),
    dm_redcap_light = tibble::tribble(
      ~flibble, ~fribble, ~dml_notes_standard,
      "aa", "bb", "cc"
    ),
    dm_full_services = tibble::tribble(
      ~flobble, ~frobble, ~dmf_notes_2, ~dmf_notes,
      "aa", "bb", "ccc", "ddd"
    )
  )

  x <- get_notes(dfs, NA)
  cx <- concat_notes(x)
  expect_equal(cx, "**Statistics**\n\nc\n\n**Data management (light)**\n\ncc\n\n**Data management (full)**\n\nddd\n\nccc")
  expect_equal(length(cx), 1)

  dfs <- list(
    statistics = tibble::tribble(
      ~foo, ~bar, ~foobar_notes,
      "a", "b", NA
    ),
    dm_redcap_light = tibble::tribble(
      ~flibble, ~fribble, ~dml_notes_standard,
      "aa", "bb", NA
    ),
    dm_full_services = tibble::tribble(
      ~flobble, ~frobble, ~dmf_notes_2, ~dmf_notes,
      "aa", "bb", NA, "ddd"
    )
  )

  x <- get_notes(dfs)
  cx <- concat_notes(x)

  expect_equal(cx, "**Data management (full)**\n\nddd")
  expect_equal(length(cx), 1)
})
