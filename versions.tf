terraform {
  required_version = ">= 0.12.0, < 0.14.0"

  required_providers {
    local  = "~> 1.2"
    random = "~> 2.2"
    template = "~> 1.0"
  }
}
