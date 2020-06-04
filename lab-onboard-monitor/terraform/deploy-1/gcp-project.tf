variable "gcp_project" {
  type = string
}

provider "google" {
  project     = var.gcp_project
}
