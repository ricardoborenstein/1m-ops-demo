locals {
  ingress_rules = [
    { name = "HTTPS", port = 443 },
    { name = "HTTP", port = 80 },
    { name = "SSH", port = 22 },
    { name = "CQL", port = 9042 },
    { name = "SSL CQL", port = 9142 },
    { name = "rpc", port = 7000 },
    { name = "RPC SSL", port = 7001 },
    { name = "JMX", port = 7199 },
    { name = "REST", port = 10000 },
    { name = "Prometheus", port = 9180 },
    { name = "Node exp", port = 9100 },
    { name = "Thirft", port = 9160 },
    { name = "shard-aware", port = 19042 }
  ]
}

resource "google_compute_firewall" "firewall" {
  name                    = lower(replace("${var.custom_name}-firewall", "_", "-"))
  network = google_compute_network.custom_vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  dynamic "allow" {
    for_each = local.ingress_rules
    content {
      protocol = "tcp"
      ports    = [format("%d", allow.value.port)]
    }
  }

  source_ranges = ["0.0.0.0/0"]
  description   = "Allow inbound traffic"
}