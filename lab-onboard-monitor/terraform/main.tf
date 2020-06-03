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

resource "google_logging_metric" "gce_new_instance_metric" {
  name   = "user/gce/instance/new"
  filter = format("resource.type=\"gce_instance\" AND logName=\"projects/%s/logs/cloudaudit.googleapis.com%%2Factivity\" AND protoPayload.methodName=(\"beta.compute.instances.insert\" OR \"v1.compute.instances.insert\") AND operation.last=true severity=\"NOTICE\"", var.gcp_project)
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
      filter     = format("metric.type=\"logging.googleapis.com/user/%s\" resource.type=\"gce_instance\"", google_logging_metric.gce_new_instance_metric.name)
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

resource "google_logging_metric" "project_activate_service_metric" {
  name   = "user/project/service/activate"
  filter = format("resource.type=\"audited_resource\" AND logName=\"projects/%s/logs/cloudaudit.googleapis.com%%2Factivity\" AND protoPayload.methodName=(\"google.api.servicemanagement.v1beta1.ServiceManager.ActivateServices\" OR \"google.api.servicemanagement.v1.ServiceManager.ActivateServices\") AND operation.last=true severity=\"NOTICE\"", var.gcp_project)
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}

resource "google_monitoring_alert_policy" "project_activate_service_warning" {
  display_name = "PROJECT activate service event"
  combiner     = "OR"
  conditions {
    display_name = "PROJECT activate service event"
    condition_threshold {
      filter     = format("metric.type=\"logging.googleapis.com/user/%s\" resource.type=\"audited_resource\"", google_logging_metric.project_activate_service_metric.name)
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
