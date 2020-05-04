variable "gcp_project" {
  type = "string"
}

provider "google" {
  project = var.gcp_project
}

resource "google_compute_firewall" "allow-icmp" {
  name    = "allow-icmp-by-tf"
  network = "default"

  allow {
    protocol = "icmp"
  }
}
