output "aws_security_group_common-internal" {
  value = aws_security_group.common-internal.id
}

//  Security group which allows SSH/RDP access to a host from specific internal servers
resource "aws_security_group" "common-internal" {
  name        = "${local.name_prefix_short}-common-internal"
  description = "Security group for common internal rules (ssh, rdp)"
  vpc_id      = aws_vpc.main.id

  depends_on = [aws_instance.bastion-linux]

  //  SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = aws_subnet.COMMON_MGT.*.cidr_block
  }

  //RDP
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = aws_subnet.COMMON_MGT.*.cidr_block
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
      "Name" = "${local.name_prefix_long}-Common Internal"
      "az"   = "all"
    },
  )
}

resource "aws_security_group" "main-public-alb" {
  name        = "${local.name_prefix_short}-main-public-alb"
  description = "Incoming public web traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-main-public-alb"
      "az"   = var.azs[var.region]
    },
  )
}

###### Management Server ###### 
### Security group for the management server: allow any egress within the VPC
######
resource "aws_security_group" "devops-management" {
  name        = "${local.name_prefix_short}-devops-management"
  description = "Management server"
  vpc_id      = data.aws_vpc.main.id

  //  SSH
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = formatlist("%s/32", aws_instance.bastion-linux.private_ip)
  }

  // Allow all TCP egress because we need to monitor ports from ansible etc...
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  lifecycle {
    create_before_destroy = true
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-devops-management"
      "az"   = "all"
    },
  )
}