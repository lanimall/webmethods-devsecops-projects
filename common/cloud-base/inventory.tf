data "template_file" "inventory-ansible" {
  template = file("${path.cwd}/helper_scripts/inventory-ansible")

  vars = {
    bastion1_dns          = length(aws_instance.bastion-linux)>0 ? aws_instance.bastion-linux[0].private_dns : "null"
    bastion1_hostname     = length(aws_instance.bastion-linux)>0 ? aws_instance.bastion-linux[0].private_ip : "null"
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
    bastion_ssh_publickey_path   = replace(local.awskeypair_bastion_keypath, "~/", "$HOME/")
    internal_ssh_publickey_path  = replace(local.awskeypair_internal_keypath, "~/", "$HOME/")
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