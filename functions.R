
# Add a nicely styled and centered label above a given input
labeled_input <- function(id, label, input) {
  div(id = id,
      style = "display: grid; justify-items: center;",
      span(label, style = "font-size: small;"),
      input)
}


previous_region <- function(current_region) {
  current_index = which(region_lookup == current_region)
  
  if (current_index == 1) {
    prev_index = 17
  } else {
    prev_index = current_index - 1
  }
  
  region_lookup$shortname[prev_index]
}
