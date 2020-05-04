variable "sre_team_email" {
  type = string
  default = "gcp-consult@ikala.tv" # CHANGE ME
}

resource "google_monitoring_notification_channel" "sre_team_channel" {
  display_name = "SRE Team"
  type         = "email"
  labels = {
    email_address = var.sre_team_email
  }
}
