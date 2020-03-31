data "template_file" "inventory-ansible" {
  template = file("${path.cwd}/helper_scripts/inventory-ansible")

  vars = {
    commandcentral1_dns      = length(aws_instance.commandcentral)>0 ? aws_instance.commandcentral[0].private_dns : "null"
    commandcentral1_hostname = length(aws_instance.commandcentral)>0 ? aws_instance.commandcentral[0].private_ip : "null"
  }
}

resource "local_file" "inventory-ansible" {
  content  = data.template_file.inventory-ansible.rendered
  filename = "${path.cwd}/tfexpanded/inventory-ansible"
}