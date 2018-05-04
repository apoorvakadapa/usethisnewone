resource "openstack_blockstorage_volume_v2" "vol" {
  count = "${var.count}"
  name = "${var.instance_name}-k8node-${var.node_az1}-${format("%02d", count.index+1)}"
  size = "${var.size}"
}


resource "openstack_compute_instance_v2" "Instance" {
  count = "${var.count}"
  name = "${var.instance_name}-k8node-${var.node_az1}-${format("%02d", count.index+1)}"
  image_id = "${var.image_id}"
  flavor_id = "${var.flavor_id}"
  key_pair = "${var.key}"
  security_groups = ["${var.security_group}"]
  availability_zone ="${var.node_az1}"

  network {
    name = "${var.network_name}"
    uuid = "${var.network}"
    access_network = true
  }

  metadata = {
    serverType = "k8-node"
    name = "${var.instance_name}-${format("%02d", count.index+1)}-${var.node_az1}"
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

resource "openstack_compute_volume_attach_v2" "vol"{
  count = "${var.count}"
  instance_id = "${element(openstack_compute_instance_v2.Instance.*.id, count.index)}"
  volume_id = "${element(openstack_blockstorage_volume_v2.vol.*.id, count.index)}"
}
