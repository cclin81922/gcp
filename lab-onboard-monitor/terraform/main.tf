resource "google_monitoring_alert_policy" "bq_scanned_bytes_billed_warning" {
  display_name = "BQ scanned bytes billed over 512 MiB in 10 minutes"
  combiner     = "OR"
  conditions {
    display_name = "BQ scanned bytes billed over 512 MiB in 10 minutes"
    condition_threshold {
      filter     = "metric.type=\"bigquery.googleapis.com/query/scanned_bytes_billed\" resource.type=\"global\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "600s"
        per_series_aligner = "ALIGN_SUM"
      }
      threshold_value = 536870912.0
      trigger {
        count = 1
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.sre_team_channel.id
  ]
}

resource "google_monitoring_alert_policy" "vm_egress_bytes_billed_warning" {
  display_name = "VM egress bytes billed over 512 MiB in 10 minutes"
  combiner     = "OR"
  conditions {
    display_name = "VM egress bytes billed over 512 MiB in 10 minutes"
    condition_threshold {
      filter     = "metric.type=\"networking.googleapis.com/vm_flow/egress_bytes_count\" resource.type=\"gce_instance\""
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "600s"
        per_series_aligner = "ALIGN_SUM"
      }
      threshold_value = 536870912.0
      trigger {
        count = 1
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.sre_team_channel.id
  ]
}
