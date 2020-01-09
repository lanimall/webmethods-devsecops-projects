
data "template_file" "inventory-ansible" {
  template = "${file("${path.cwd}/helper_scripts/inventory-ansible")}"

  vars {
    management1_dns = "${aws_instance.devops-management.0.private_dns}"
    management1_hostname = "${aws_instance.devops-management.0.private_ip}"

    commandcentral1_dns = "${aws_instance.commandcentral.0.private_dns}"
    commandcentral1_hostname = "${aws_instance.commandcentral.0.private_ip}"
  }
}

resource "local_file" "inventory-ansible" {
  content     = "${data.template_file.inventory-ansible.rendered}"
  filename = "${path.cwd}/tfexpanded/inventory-ansible"
}

data "template_file" "inventory-hosts" {
  template = "${file("${path.cwd}/helper_scripts/inventory-hosts")}"
  vars {
    hostname_prefix = "${local.name_prefix}_"
    management1_ip = "${aws_instance.devops-management.0.private_ip}"
    commandcentral1_ip = "${aws_instance.commandcentral.0.private_ip}"
  }
}

resource "local_file" "inventory-hosts" {
  content  = "${data.template_file.inventory-hosts.rendered}"
  filename = "${path.cwd}/tfexpanded/inventory-hosts"
}

data "template_file" "setenv-mgt" {
  template = "${file("${path.cwd}/helper_scripts/setenv-mgt.sh")}"
  vars {
    management1_ip = "${aws_instance.devops-management.0.private_ip}"
    management1_user = "${local.base_ami_linux_user}"
  }
}

resource "local_file" "setenv-mgt" {
  content  = "${data.template_file.setenv-mgt.rendered}"
  filename = "${path.cwd}/tfexpanded/setenv-mgt.sh"
}