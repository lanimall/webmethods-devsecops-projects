data "template_file" "inventory-ansible" {
  template = file("${path.cwd}/helper_scripts/ansible-inventory.template")

  vars = {
    commandcentral1_dns_internal = length(aws_instance.commandcentral)>0 ? aws_instance.commandcentral[0].private_dns : "null"
    commandcentral1_dns_custom = length(aws_route53_record.webmethods_commandcentral-a-record)>0 ? aws_route53_record.webmethods_commandcentral-a-record.0.name : "null"
    commandcentral1_private_ip = length(aws_instance.commandcentral)>0 ? aws_instance.commandcentral[0].private_ip : "null"
  }
}

resource "local_file" "inventory-ansible" {
  content  = data.template_file.inventory-ansible.rendered
  filename = "${path.cwd}/tfexpanded/ansible-inventory"
}