resource "google_logging_metric" "iam_set_policy_metric" {
  name   = "user/iam/policy/set"
  filter = format("resource.type=\"project\" AND logName=\"projects/%s/logs/cloudaudit.googleapis.com%%2Factivity\" AND protoPayload.methodName=\"SetIamPolicy\" AND severity=\"NOTICE\"", var.gcp_project)
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "iam_set_policy_warning" {
  display_name = "IAM set policy event"
  combiner     = "OR"
  conditions {
    display_name = "IAM set policy event"
    condition_threshold {
      filter     = format("metric.type=\"logging.googleapis.com/user/%s\" resource.type=\"global\"", google_logging_metric.iam_set_policy_metric.name)
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