################################################
################ Bastion
################################################

output "devops-management-public_ip" {
  value = aws_instance.devops-management.*.public_ip
}

output "devops-management-private_dns" {
  value = aws_instance.devops-management.*.private_dns
}

output "devops-management-private_ip" {
  value = aws_instance.devops-management.*.private_ip
}

variable "instancesize_devops-management" {
  description = "instance type for api gateway"
  default     = "t3.small"
}

resource "aws_iam_role" "devops-management" {
  name = "${local.name_prefix_unique_short}-devops-management-role"

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
  name = "${local.name_prefix_unique_short}-devops-management-profile"
  role = aws_iam_role.devops-management.name
}

resource "aws_iam_role_policy_attachment" "devops-management-s3policy" {
  role       = aws_iam_role.devops-management.name
  policy_arn = local.base_policy_sagcontent_s3_readwrite_arn
}

//Create the private node general userdata script.
data "template_file" "setup-devops-management" {
  template = file("./helper_scripts/setup-private-node.sh")
  vars = {
    availability_zone = data.aws_subnet.COMMON_MGT[0].availability_zone
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "devops-management" {
  ## only create in primary
  #count         = "${length(data.aws_subnet.COMMON_MGT.*.ids)}"
  count = 1

  ami                         = local.base_ami_linux
  instance_type               = var.instancesize_devops-management
  subnet_id                   = data.aws_subnet.COMMON_MGT[count.index].id
  user_data                   = data.template_file.setup-devops-management.*.rendered[count.index]
  key_name                    = local.awskeypair_internal_node
  iam_instance_profile        = aws_iam_instance_profile.devops-management.name
  associate_public_ip_address = "false"

  vpc_security_group_ids = flatten([
    local.common_secgroups,
    [
      aws_security_group.devops-management.id
    ]
  ])
  
  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    local.common_instance_tags,
    {
      "Name" = "${local.name_prefix_long}-devops-management${count.index + 1}-${data.aws_subnet.COMMON_MGT[count.index].availability_zone}"
      "az"   = data.aws_subnet.COMMON_MGT[count.index].availability_zone
    },
  )
}

