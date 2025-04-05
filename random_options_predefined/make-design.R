design <- data.frame(
  id = rep(1:10, each = 3),
  numbers = unlist(lapply(1:10, function(x) sample(seq(100), 3)))
)

head(design)

readr::write_csv(design, "design.csv")
