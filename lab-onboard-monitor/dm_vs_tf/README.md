# DM

```bash
gcloud deployment-manager deployments create allow-icmp --config new-fw.dm
```
```bash
gcloud deployment-manager deployments delete allow-icmp
```

```yaml
resources:
- name: allow-icmp-by-dm
  type: compute.v1.firewall
  properties:
    network: "global/networks/default"
    allowed:
    - IPProtocol: ICMP
```

# TF

```bash
terraform apply
```
```bash
terraform destroy
```

```
resource "google_compute_firewall" "allow-icmp" {
  name    = "allow-icmp-by-tf"
  network = "default"

  allow {
    protocol = "icmp"
  }
}
```
