data "template_file" "inventory-ansible" {
  template = file("${path.cwd}/helper_scripts/inventory-ansible")

  vars = {
    management1_dns          = length(aws_instance.devops-management)>0 ? aws_instance.devops-management[0].private_dns : "null"
    management1_hostname     = length(aws_instance.devops-management)>0 ? aws_instance.devops-management[0].private_ip : "null"
    commandcentral1_dns      = length(aws_instance.commandcentral)>0 ? aws_instance.commandcentral[0].private_dns : "null"
    commandcentral1_hostname = length(aws_instance.commandcentral)>0 ? aws_instance.commandcentral[0].private_ip : "null"
  }
}

resource "local_file" "inventory-ansible" {
  content  = data.template_file.inventory-ansible.rendered
  filename = "${path.cwd}/tfexpanded/inventory-ansible"
}

data "template_file" "setenv-mgt" {
  template = file("${path.cwd}/helper_scripts/setenv-mgt.sh")
  vars = {
    management1_ip   = length(aws_instance.devops-management)>0 ? aws_instance.devops-management[0].private_ip : "null"
    management1_user = local.base_ami_linux_user
    main_public_alb_dns_name = local.base_main_public_alb_dns_name
    commandcentral_external_dns_name   = local.commandcentral_external_hostname
  }
}

resource "local_file" "setenv-mgt" {
  content  = data.template_file.setenv-mgt.rendered
  filename = "${path.cwd}/tfexpanded/setenv-mgt.sh"
}