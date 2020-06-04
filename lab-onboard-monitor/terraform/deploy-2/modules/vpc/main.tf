data "google_project" "project" {
}

data "google_monitoring_notification_channel" "channel" {
  display_name = "SRE Team"
}

resource "google_logging_metric" "vpc_new_fwrule_metric" {
  name   = "user/vpc/fwrule/new"
  filter = format("resource.type=\"gce_firewall_rule\" AND logName=\"projects/%s/logs/cloudaudit.googleapis.com%%2Factivity\" AND protoPayload.methodName=(\"beta.compute.firewalls.insert\" OR \"v1.compute.firewalls.insert\") AND operation.last=true severity=\"NOTICE\"", data.google_project.project.id)
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "vpc_new_fwrule_warning" {
  display_name = "VPC new fwrule event"
  combiner     = "OR"
  conditions {
    display_name = "VPC new fwrule event"
    condition_threshold {
      filter     = format("metric.type=\"logging.googleapis.com/user/%s\" resource.type=\"global\"", google_logging_metric.vpc_new_fwrule_metric.name)
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
    data.google_monitoring_notification_channel.channel.id
  ]

  depends_on = [
    google_logging_metric.vpc_new_fwrule_metric
  ]
}