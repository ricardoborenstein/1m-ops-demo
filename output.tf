output "PublicIP" {
  value       = [for instance in google_compute_instance.instance : instance.network_interface[0].access_config[0].nat_ip if length(instance.network_interface[0].access_config) > 0]
}
output "CQL_PASS" {
  value     = data.scylladbcloud_cql_auth.scylla.password
  sensitive = true
}