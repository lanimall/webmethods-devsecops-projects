
data "template_file" "inventory-ansible" {
  template = "${file("${path.cwd}/helper_scripts/inventory-ansible")}"

  vars {
    dns_server1 = "${aws_instance.server1.0.private_dns}"
    hostname_server1 = "${aws_instance.server1.0.private_ip}"

    dns_server2 = "${aws_instance.server2.0.private_dns}"
    hostname_server2 = "${aws_instance.server2.0.private_ip}"
  }
}

resource "local_file" "inventory-ansible" {
  content     = "${data.template_file.inventory-ansible.rendered}"
  filename = "${path.cwd}/tfexpanded/inventory-ansible"
}