################################################
################ Bastions
################################################

output "bastion-linux-public_ip" {
  value = aws_instance.bastion-linux.*.public_ip
}

output "bastion-linux-private_dns" {
  value = aws_instance.bastion-linux.*.private_dns
}

output "bastion-linux-private_ip" {
  value = aws_instance.bastion-linux.*.private_ip
}

variable "instancesize_bastion-linux" {
  description = "instance type for api gateway"
  default     = "t3.small"
}

variable "instancecount_bastion" {
  description = "number of cbastion nodes"
  default     = "1"
}

// create eip for bastion
resource "aws_eip" "bastion" {
  #count         = "${length(split(",", lookup(var.azs, var.region)))}"
  count = var.instancecount_bastion

  vpc = true

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-bastion-${aws_subnet.COMMON_DMZ[count.index].availability_zone}"
      "az"   = aws_subnet.COMMON_DMZ[count.index].availability_zone
    },
  )
}

resource "aws_eip_association" "bastion" {
  instance_id   = aws_instance.bastion-linux[0].id
  allocation_id = aws_eip.bastion[0].id
}

//  Security group which allows SSH/RDP access to a host from anywhere (used for bastion generally)
resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Security group for bastion ingress/egress (ssh, rdp)"
  vpc_id      = aws_vpc.main.id

  //  SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  //  HTTP
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  HTTPS
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-bastion"
    },
  )
}

//Create the bastion userdata script.
data "template_file" "setup-bastion" {
  #count         = "${length(split(",", lookup(var.azs, var.region)))}"
  count    = var.instancecount_bastion
  template = file("./helper_scripts/setup-bastion.sh")
  vars = {
    availability_zone = element(split(",", var.azs[var.region]), count.index)
  }
}

//  Launch configuration for the bastion
resource "aws_instance" "bastion-linux" {
  #count         = "${length(split(",", lookup(var.azs, var.region)))}"
  count = var.instancecount_bastion

  subnet_id                   = aws_subnet.COMMON_DMZ[count.index].id
  ami                         = local.base_ami_linux
  instance_type               = var.instancesize_bastion-linux
  user_data                   = data.template_file.setup-bastion[count.index].rendered
  key_name                    = aws_key_pair.bastion.id
  associate_public_ip_address = "true"

  vpc_security_group_ids = [
    aws_security_group.bastion.id,
  ]

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    local.common_instance_tags,
    {
      "Name" = "${local.name_prefix_long}-bastion-${aws_subnet.COMMON_DMZ[count.index].availability_zone}"
      "az"   = aws_subnet.COMMON_DMZ[count.index].availability_zone
    },
  )
}

