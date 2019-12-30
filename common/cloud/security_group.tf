//  Security group which allows SSH/RDP access to a host from specific internal servers
resource "aws_security_group" "common-internal" {
  name        = "${local.name_prefix}-common-internal"
  description = "Security group for common internal rules (ssh, rdp)"
  vpc_id      = "${aws_vpc.main.id}"

  depends_on = [
    "aws_instance.bastion-linux"
  ]

  //  SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "${aws_instance.bastion-linux.*.private_ip[0]}/32",
      "${aws_subnet.COMMON_MGT.*.cidr_block}"
    ]
  }

  //RDP
  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = [
      "${aws_subnet.COMMON_MGT.*.cidr_block}"
    ]
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
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-Common Internal",
      "az", "all"
    )
  )}"
}

//  Security group which allows SSH/RDP access to a host from anywhere (used for bastion generally)
resource "aws_security_group" "devops-management" {
  name        = "${local.name_prefix}-devops-management"
  description = "SManagement server"
  vpc_id      = "${aws_vpc.main.id}"

  //  SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.main.cidr_block}"]
  }

  // Allow all TCP egress because we need to monitor ports from ansible etc...
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["${aws_vpc.main.cidr_block}"]
  }

  lifecycle {
    create_before_destroy = true
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-devops-management",
      "az", "all"
    )
  )}"
}

resource "aws_security_group" "main-public" {
  name        = "${local.name_prefix}-main-public"
  description = "Incoming public web traffic"
  vpc_id      = "${aws_vpc.main.id}"

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
    cidr_blocks = ["${aws_vpc.main.cidr_block}"]
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-main-public",
      "az", lookup(var.azs, var.region)
    )
  )}"
}

###### COMMAND CENTRAL ###### 
resource "aws_security_group" "webmethods-commandcentral" {
  name        = "${local.name_prefix}-wm-commandcentral"
  description = "Command Central"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 8090
    to_port     = 8091
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.main.cidr_block}"]
  }

  ## SPM communication outbound
  egress {
    from_port   = 8092
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.main.cidr_block}"]
  }

  ## SSH comm outbound for wM component bootstrapping
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.main.cidr_block}"]
  }

  ## need to ideally figure out what port it needs to access...but seems like it needs to access many of the installed products
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_vpc.main.cidr_block}"]
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-webMethods Command Central",
      "az", "all"
    )
  )}"
}