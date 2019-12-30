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