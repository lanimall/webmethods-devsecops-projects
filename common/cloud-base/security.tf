output "main_security_group_common_internal_id" {
  value = aws_security_group.common-internal.id
}

output "main_bastion_private_ip" {
  value = aws_instance.bastion-linux.*.private_ip
}

output "internalnode_key_name" {
  value = aws_key_pair.internalnode.id
}

locals {
  awskeypair_bastion_node     = "${local.name_prefix_short}-${var.bastion_key_name}"
  awskeypair_bastion_keypath  = var.bastion_publickey_path
  awskeypair_bastion_privatekeypath  = var.bastion_privatekey_path

  awskeypair_internal_node    = "${local.name_prefix_short}-${var.internalnode_key_name}"
  awskeypair_internal_keypath = var.internalnode_publickey_path
  awskeypair_internal_privatekeypath = var.internalnode_privatekey_path

  lb_ssl_cert_key = var.ssl_cert_mainlb_key_path
  lb_ssl_cert_pub = var.ssl_cert_mainlb_pub_path
  lb_ssl_cert_ca  = var.ssl_cert_mainlb_ca_path
}

## key creation for internal nodes
resource "aws_key_pair" "internalnode" {
  key_name   = local.awskeypair_internal_node
  public_key = file(local.awskeypair_internal_keypath)
}

## key creation for bastion nodes
resource "aws_key_pair" "bastion" {
  key_name   = local.awskeypair_bastion_node
  public_key = file(local.awskeypair_bastion_keypath)
}