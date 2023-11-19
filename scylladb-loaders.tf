resource "google_os_login_ssh_public_key" "default" {
  user = data.google_client_openid_userinfo.me.email
  key  = file(var.ssh_public_key) 
}
# Creating 3 GCP Instances:
resource "google_compute_instance" "instance" {
  count        = length(data.google_compute_zones.available.names)
  name         = lower(replace("${var.custom_name}-loader-${count.index}", "_", "-"))
  machine_type = var.instance_type
  zone         = element(data.google_compute_zones.available.names, count.index)

  boot_disk {
    initialize_params {
      image = "projects/${var.image_project}/global/images/${var.image_name}"
    }
  }

  network_interface {
    subnetwork = element(google_compute_subnetwork.public_subnet.*.self_link, count.index)
    access_config {
      # This block is empty, so an ephemeral public IP will be used
    }
  }
metadata = {
  #enable-oslogin = "TRUE"
  ssh-keys = "${var.your_name}:${replace(file(var.ssh_public_key), "\n", "")}"

}

  # Provision files to each instance. Copy three files from the current directory 
  # to the remote instance: stress-0.yml, cassandra-stress.service, and cassandra-stress-benchmark.service.

  provisioner "file" {
    source      = "./profile/stress-${count.index}.yml"
    destination = "/home/${var.your_name}/stress.yml"

  }
  provisioner "file" {
    source      = "./service/cassandra-stress.service"
    destination = "/home/${var.your_name}/cassandra-stress.service"

  }

    provisioner "file" {
    source      = "./service/cassandra-stress-benchmark.service"
    destination = "/home/${var.your_name}/cassandra-stress-benchmark.service"

  }

  # Run remote-exec commands on each instance. It stops the scylla-server, creates a start.sh script, 
  # creates a benchmark.sh script, sets permissions on the scripts, moves two files to /etc/systemd/system/, 
  # runs daemon-reload, and starts the cassandra-stress service.

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl stop scylla-server |tee scylla.log",
      "echo '/usr/bin/cassandra-stress user profile=./stress.yml n=${var.num_of_ops} cl=local_quorum no-warmup \"ops(insert=1)\" -rate threads=${var.num_threads} fixed=450000/s -mode native cql3 user=${var.scylla_user} password=${local.scylla_pass} -log file=populating.log  -node ${local.scylla_ips}' > start.sh",
      "echo '/usr/bin/cassandra-stress user profile=./stress.yml duration=24h no-warmup cl=local_quorum \"ops(insert=4,simple1=2)\" -rate threads=${var.num_threads} fixed=${var.throttle} -mode native cql3 user=${var.scylla_user} password=${local.scylla_pass} -log file=benchmarking.log -node ${local.scylla_ips}' > benchmark.sh",
      "sudo chmod +x start.sh benchmark.sh",
      "sudo mv /home/${var.your_name}/cassandra-stress.service /etc/systemd/system/cassandra-stress.service ",
      "sudo mv /home/${var.your_name}/cassandra-stress-benchmark.service /etc/systemd/system/cassandra-stress-benchmark.service ", "sudo systemctl daemon-reload ",
      "sudo systemctl start cassandra-stress.service",
    ]
  }

  # Set up an SSH connection to each EC2 instance using the scyllaadm user and the private key. 
  # The coalesce function is used to select the public IP address of ScyllaDB Nodes.
  connection {
    type        = "ssh"
    user        = "${var.your_name}"
    private_key = file(var.ssh_private_key)
    host        = coalesce(self.network_interface[0].access_config[0].nat_ip, self.network_interface[0].network_ip)
    agent       = true
  }

}

output "zone_output" {
  value = [for i in range(length(data.google_compute_zones.available.names)) : element(data.google_compute_zones.available.names, i)]
  description = "Prints the zones."
}


