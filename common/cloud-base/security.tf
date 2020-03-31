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
  awskeypair_internal_node    = "${local.name_prefix_short}-${var.internalnode_key_name}"

  lb_ssl_cert_key = var.ssl_cert_mainlb_key_path
  lb_ssl_cert_pub = var.ssl_cert_mainlb_pub_path
  lb_ssl_cert_ca  = var.ssl_cert_mainlb_ca_path
}

## key creation for internal nodes
resource "aws_key_pair" "internalnode" {
  key_name   = local.awskeypair_internal_node
  public_key = file(var.internalnode_publickey_path)
}

## key creation for bastion nodes
resource "aws_key_pair" "bastion" {
  key_name   = local.awskeypair_bastion_node
  public_key = file(var.bastion_publickey_path)
}

resource "aws_iam_role" "devops-management" {
  name = "${local.name_prefix_short}-devops-management-role"

  assume_role_policy = <<EOF
{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
}
EOF
}

resource "aws_iam_instance_profile" "devops-management" {
  name = "${local.name_prefix_short}-devops-management-profile"
  role = aws_iam_role.devops-management.name
}

resource "aws_iam_role_policy_attachment" "devops-management-s3policy" {
  role       = aws_iam_role.devops-management.name
  policy_arn = aws_iam_policy.sagcontent-s3-readwrite.arn
}