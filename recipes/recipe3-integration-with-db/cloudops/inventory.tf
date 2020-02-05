
data "template_file" "inventory-ansible" {
  template = "${file("${path.cwd}/helper_scripts/inventory-ansible")}"

  vars {
    dns_integration1 = "${aws_route53_record.integration-a-record.0.name}"
    hostname_integration1 = "${aws_instance.integration.0.private_dns}"

    dns_terracotta1 = "${aws_route53_record.terracotta-a-record.0.name}"
    hostname_terracotta1 = "${aws_instance.terracotta.0.private_dns}"

    dns_universalmessaging1 = "${aws_route53_record.universalmessaging-a-record.0.name}"
    hostname_universalmessaging1 = "${aws_instance.universalmessaging.0.private_dns}"
  }
}

resource "local_file" "inventory-ansible" {
  content     = "${data.template_file.inventory-ansible.rendered}"
  filename = "${path.cwd}/tfexpanded/inventory-ansible"
}