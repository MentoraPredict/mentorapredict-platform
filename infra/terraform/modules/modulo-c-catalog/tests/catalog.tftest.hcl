variables {}

run "exposes_catalogue" {
  command = plan

  assert {
    condition     = length(output.services) == 10
    error_message = "Module C has ten services."
  }

  assert {
    condition     = length(output.topics) == 11
    error_message = "Module C owns eleven topics."
  }

  assert {
    condition     = output.services["AUL"].level == 1
    error_message = "AUL is a level 1 service."
  }

  assert {
    condition     = output.services["ANL"].level == 2
    error_message = "ANL is a level 2 service."
  }
}
