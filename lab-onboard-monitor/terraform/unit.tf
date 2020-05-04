resource "google_logging_metric" "gce_new_instance_metric" {
  name   = "user/gce/instance/new"
  filter = "resource.type=\"gce_instance\" AND logName=\"projects/gcp-expert-sandbox-jim/logs/cloudaudit.googleapis.com%2Factivity\" AND protoPayload.methodName=(\"beta.compute.instances.insert\" OR \"v1.compute.instances.insert\") AND operation.last=true severity=\"NOTICE\"" # TBD
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "gce_new_instance_warning" {
  display_name = "GCE new instance event"
  combiner     = "OR"
  conditions {
    display_name = "GCE new instance event"
    condition_threshold {
      filter     = "metric.type=\"logging.googleapis.com/user/user/gce/instance/new\" resource.type=\"gce_instance\"" # TBD
      duration   = "60s"
      comparison = "COMPARISON_GT"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_COUNT"
      }
      threshold_value = 0.0
      trigger {
        count = 1
      }
    }
  }

  notification_channels = [
    google_monitoring_notification_channel.sre_team_channel.id
  ]
}
