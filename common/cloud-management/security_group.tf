//  Security group which allows SSH/RDP access to a host from specific internal servers
variable "main_security_group_common_internal_id" {}

data "aws_security_group" "common-internal" {
  id = "${var.main_security_group_common_internal_id}"
}

###### Management Server ###### 
### Security group for the management server: allow any egress within the VPC
######
resource "aws_security_group" "devops-management" {
  name        = "${local.name_prefix}-devops-management"
  description = "Management server"
  vpc_id      = "${data.aws_vpc.main.id}"

  //  SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "${var.main_bastion_private_ip}/32"
    ]
  }

  // Allow all TCP egress because we need to monitor ports from ansible etc...
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["${data.aws_vpc.main.cidr_block}"]
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

###### COMMAND CENTRAL ###### 
resource "aws_security_group" "webmethods-commandcentral" {
  name        = "${local.name_prefix}-wm-commandcentral"
  description = "Command Central"
  vpc_id      = "${data.aws_vpc.main.id}"

  ingress {
    from_port   = 8090
    to_port     = 8091
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.main.cidr_block}"]
  }

  ## SPM communication outbound
  egress {
    from_port   = 8092
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.main.cidr_block}"]
  }

  ## SSH comm outbound for wM component bootstrapping
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${data.aws_vpc.main.cidr_block}"]
  }

  ## need to ideally figure out what port it needs to access...but seems like it needs to access many of the installed products
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.aws_vpc.main.cidr_block}"]
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