output "vpccid" {
  value = "${aws_vpc.main.id}"
}

output "ami_linux" {
  value = "${local.base_ami_linux}"
}

output "amiuser_linux" {
  value = "${local.base_ami_linux_user}"
}

output "ami_windows" {
  value = "${local.base_ami_windows}"
}

output "amiuser_windows" {
  value = "${local.base_ami_windows_user}"
}

output "aws_key_pair_internalnode" {
  value = "${aws_key_pair.internalnode.id}"
}

data "template_file" "setenv-main" {
  template = "${file("${path.cwd}/helper_scripts/setenv-main.sh")}"

  vars {
    main_vpc_id = "${aws_vpc.main.id}"
    main_bastion_private_ip = "${aws_instance.bastion-linux.0.private_ip}"
    main_security_group_common-internal_id = "${aws_security_group.common-internal.id}"
    internalnode_key_name = "${aws_key_pair.internalnode.id}"
  }
}

resource "local_file" "setenv-main" {
  content     = "${data.template_file.setenv-main.rendered}"
  filename = "${path.cwd}/tfexpanded/setenv-main.sh"
}