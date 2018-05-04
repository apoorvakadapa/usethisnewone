
resource "openstack_blockstorage_volume_v2" "mastervol" {
  name = "${var.instance_name}_k8_${var.az}"
  size = "${var.size}"
}

resource "openstack_compute_instance_v2" "master" {
  name = "${var.instance_name}_k8_${var.az}"
  image_id = "${var.image_id}"
  flavor_id = "${var.flavor_id}"
  key_pair = "${var.key}"
  security_groups = ["${var.security_group}"]
  availability_zone ="${var.az}"

  network {
    name = "${var.network_name}"
    uuid = "${var.network}"
    access_network = true
  }

  metadata = {
    serverType = "k8"
    name = "${var.instance_name}_k8_${var.az}"
    createdBy = "${var.user}"
    serverFlavor="${var.flavor_id}"

  }

  connection {
    type     = "ssh"
    user     = "${var.user}"
    private_key = "${file("${var.ssh_key}")}"
    timeout = "10m"
    agent = false
  }

  provisioner "file" {
    source      = "host_update.sh"
    destination = "/tmp/updatehost.sh"
  }


  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/updatehost.sh",
      "/tmp/updatehost.sh",
    ]
  }
}


resource "openstack_compute_volume_attach_v2" "attach" {
  instance_id = "${openstack_compute_instance_v2.master.id}"
  volume_id = "${openstack_blockstorage_volume_v2.mastervol.id}"
}


