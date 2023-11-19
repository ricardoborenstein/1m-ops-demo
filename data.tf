###################################################

# Fetching all zones in var.region

###################################################

data "google_compute_zones" "available" {
  project = var.project
  region  = var.gcp_region
}

data "google_project" "project" {
  project_id = var.project
}

data "scylladbcloud_cql_auth" "scylla" {
	cluster_id = scylladbcloud_cluster.scylladbcloud.id
}

data "google_compute_network" "current" {
  name    = "default"  # replace 'default' with your actual network name if it's not 'default'
  project = var.project
}

data "google_client_openid_userinfo" "me" {
}
