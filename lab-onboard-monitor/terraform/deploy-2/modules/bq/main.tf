data "google_project" "project" {
}

data "google_monitoring_notification_channel" "channel" {
  display_name = "SRE Team"
}

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
    data.google_monitoring_notification_channel.channel.id
  ]
}

resource "google_logging_metric" "bq_bigdata_query_metric" {
  name   = "user/bq/query/bigdata"
  filter = format("resource.type=\"bigquery_resource\" AND logName=\"projects/%s/logs/cloudaudit.googleapis.com%%2Fdata_access\" AND protoPayload.methodName=\"jobservice.jobcompleted\" AND severity=\"INFO\" AND protoPayload.serviceData.jobCompletedEvent.job.jobStatistics.totalBilledBytes>1073741824", data.google_project.project.id)
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "bq_bigdata_query_warning" {
  display_name = "BQ over 1 GiB query event"
  combiner     = "OR"
  conditions {
    display_name = "BQ bigdata query event"
    condition_threshold {
      filter     = format("metric.type=\"logging.googleapis.com/user/%s\" resource.type=\"global\"", google_logging_metric.bq_bigdata_query_metric.name)
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
    google_logging_metric.bq_bigdata_query_metric
  ]
}