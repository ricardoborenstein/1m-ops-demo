#
# Set the following variables (mandatory)
#

# ScyllaDB Cloud API token
variable "scylla_cloud_token" {
  description = "ScyllaDB Cloud API token"
  type        = string
  default     = "xxxx"
}

# ScyllaDB Cloud region
variable "scylla_cloud_region" {
  description = "ScyllaDB Cloud region of the cluster"
  type        = string
  default     = "us-west1"
}

# Compute Engine region
variable "gcp_region" {
  description = "Compute Engine region of the Loaders"
  type        = string
  default     = "us-west1"
}

# SSH public key for Compute Engine instance access
variable "ssh_public_key" {
  description = "SSH public key for Compute Engine instance access"
  type        = string
  default     = "/Users/ricardo/.ssh/terraform.pub"
}

# SSH private key for Compute Engine instance access
variable "ssh_private_key" {
  description = "SSH private key for Compute Engine instance access"
  type        = string
  default     = "/Users/ricardo/.ssh/terraform"
}
# GCP Project name ID
variable "project" {
  description = "Project-Name-ID where terraform will deploy the loaders"
  type        = string
  default     = "skilled-adapter-452"
} 

# Your Login Name
variable "your_name" {
  description = "user that will login intoter GCP instances"
  type        = string
  default     = "ricardo"
}


################################################

#
# The following variables are not required to be modified to run the demo
# but you can still modify them if you want to try a different setup
#

# Number of threads for the Cassandra stress tool
variable "num_threads" {
  description = "Number of threads for the Cassandra stress tool"
  type        = string
  default     = "8"
}

# Total number of operations to run
variable "num_of_ops" {
  description = "Total number of operations to run"
  type        = string
  default     = "1M"
}

# Throttling for the Cassandra stress tool
variable "throttle" {
  description = "Throttling for the Cassandra stress tool (in ops/sec)"
  type        = string
  default     = "20000/s "
}

# Compute Engine instance type
variable "instance_type" {
  description = "Type of the Compute Engine instance"
  type        = string
  default     = "n2-highmem-2"
}

variable "image_name" {
  description = "The name of the image to use for the instances"
  type        = string
  default     = "scylladb-enterprise-2023-1-2"
}

variable "image_project" {
  description = "The image project ID where the image is hosted"
  type        = string
  default     = "scylla-images"
}

# Virtual Private Cloud (VPC) IP range
variable "subnet_cidrs" {
  description = "List of CIDR blocks for the subnets"
  type        = string
  default     = "10.0.1.0/16" # Add more if needed
}

# ScyllaDB Cloud instance type
variable "scylla_node_type" {
  description = "Type of ScyllaDB Cloud instance"
  type        = string
  default     = "n2-highmem-2"
}



# ScyllaDB Cloud user
variable "scylla_user" {
  description = "ScyllaDB Cloud user"
  type        = string
  default     = "scylla"
}

# Environment name
variable "custom_name" {
  description = "Name for the ScyllaDB Cloud environment"
  type        = string
  default     = "ScyllaDB-Cloud-Demo-Ricardo"
}


# Number of ScyllaDB Cloud instances to create
variable "scylla_node_count" {
  description = "Number of ScyllaDB Cloud instances to create"
  type        = string
  default     = "3"
}

locals {
  scylla_ips  = (join(",", [for s in scylladbcloud_cluster.scylladbcloud.node_private_ips : format("%s", s)]))
  scylla_pass = data.scylladbcloud_cql_auth.scylla.password
}
