data "template_file" "inventory-ansible" {
  template = file("${path.cwd}/helper_scripts/inventory-ansible")

  vars = {
    bastion1_dns          = length(aws_instance.bastion-linux)>0 ? aws_instance.bastion-linux[0].private_dns : "null"
    bastion1_hostname     = length(aws_instance.bastion-linux)>0 ? aws_instance.bastion-linux[0].private_ip : "null"
    management1_dns          = length(aws_instance.devops-management)>0 ? aws_instance.devops-management[0].private_dns : "null"
    management1_hostname     = length(aws_instance.devops-management)>0 ? aws_instance.devops-management[0].private_ip : "null"
  }
}

resource "local_file" "inventory-ansible" {
  content  = data.template_file.inventory-ansible.rendered
  filename = "${path.cwd}/tfexpanded/inventory-ansible"
}

data "template_file" "setenv-base" {
  template = file("${path.cwd}/helper_scripts/setenv-base.sh")

  vars = {
    bastion_public_ip      = aws_eip.bastion.0.public_ip
    bastion_user           = var.linux_ami_user
    bastion_ssh_privatekey_path   = replace(var.bastion_privatekey_path, "~/", "$HOME/")
    bastion_ssh_publickey_path   = replace(var.bastion_publickey_path, "~/", "$HOME/")
    internal_ssh_privatekey_path  = replace(var.internalnode_privatekey_path, "~/", "$HOME/")
    internal_ssh_publickey_path  = replace(var.internalnode_publickey_path, "~/", "$HOME/")
    dns_main_external_apex       = local.dns_main_external_apex
  }
}

resource "local_file" "setenv-base" {
  content  = data.template_file.setenv-base.rendered
  filename = "${path.cwd}/tfexpanded/setenv-base.sh"
}

data "template_file" "setenv-s3" {
  template = file("${path.cwd}/helper_scripts/setenv-s3.sh")

  vars = {
    s3_bucket_name               = aws_s3_bucket.main.id
    s3_bucket_prefix             = local.name_prefix_long
  }
}

resource "local_file" "setenv-s3" {
  content  = data.template_file.setenv-s3.rendered
  filename = "${path.cwd}/tfexpanded/setenv-s3.sh"
}

data "template_file" "setenv-mgt" {
  template = file("${path.cwd}/helper_scripts/setenv-mgt.sh")
  vars = {
    management1_ip   = length(aws_instance.devops-management)>0 ? aws_instance.devops-management[0].private_ip : "null"
    management1_user = var.linux_ami_user
    main_public_alb_dns_name = aws_lb.main-public-alb.dns_name
  }
}

resource "local_file" "setenv-mgt" {
  content  = data.template_file.setenv-mgt.rendered
  filename = "${path.cwd}/tfexpanded/setenv-mgt.sh"
}