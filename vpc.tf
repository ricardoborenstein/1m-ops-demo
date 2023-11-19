#############################################

# Creating Virtual Private Cloud (VPC):

#############################################
resource "google_compute_network" "custom_vpc" {
  name                    = lower(replace("${var.custom_name}-vpc", "_", "-"))
  auto_create_subnetworks = false
}

#############################################

# Creating Public subnet:

#############################################

resource "google_compute_subnetwork" "public_subnet" {
  name          = lower(replace("${var.custom_name}-public-subnet", "_", "-"))
  ip_cidr_range = "10.0.1.0/24" # Define the CIDR block for the subnet
  region        = var.gcp_region
  network       = google_compute_network.custom_vpc.self_link
}


#############################################

# Creating Internet Gateway (Cloud Router):

#############################################

resource "google_compute_router" "igw" {
  name                    = lower(replace("${var.custom_name}-router", "_", "-"))
  network = google_compute_network.custom_vpc.name
  region  = var.gcp_region
}

#############################################

# Creating Public Route:

#############################################

resource "google_compute_route" "public_route" {
  name                    = lower(replace("${var.custom_name}-route", "_", "-"))
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.custom_vpc.name
  next_hop_gateway = "default-internet-gateway"
}

#############################################

# Creating VPC Network Peering:

#############################################

resource "google_compute_network_peering" "network_peering" {
  name         = lower(replace("${var.custom_name}-peering", "_", "-"))
  network      = google_compute_network.custom_vpc.self_link
  peer_network = scylladbcloud_vpc_peering.scylladbcloud.network_link
}