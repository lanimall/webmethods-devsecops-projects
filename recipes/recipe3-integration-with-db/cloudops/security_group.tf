########################################################################
############ Security groups for the current solutions
########################################################################

###### INTEGRATION SERVER ###### 
resource "aws_security_group" "integrationserver" {
  name        = "${local.name_prefix_unique_short}-integrationserver"
  description = "Integration Server"
  vpc_id        = "${data.aws_vpc.main.id}"

  ingress {
    from_port   = 5555
    to_port     = 5555
    protocol    = "tcp"
    cidr_blocks = [
      "${concat(
        "${local.common_access_cidrs}",
        "${list(data.aws_vpc.main.cidr_block)}"
      )}"
    ]
  }

  ingress {
    from_port   = 9999
    to_port     = 9999
    protocol    = "tcp"
    cidr_blocks = [
      "${concat(
        "${local.common_access_cidrs}",
        "${list(data.aws_vpc.main.cidr_block)}"
      )}"
    ]
  }

  ##SPM communication
  ingress {
    from_port   = 8092
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = [
      "${data.aws_subnet.COMMON_MGT.*.cidr_block}"
    ]
  }

  ### TODO: Need to figure out what exact port to allow in egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${list(data.aws_vpc.main.cidr_block)}"]
  }

  lifecycle {
    create_before_destroy = true
  }

  //Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-webMethods Integration Server",
      "az", "all"
    )
  )}"
}

###### TERRACOTTA ###### 
resource "aws_security_group" "terracotta" {
  name        = "${local.name_prefix_unique_short}-terracotta"
  description = "Terracotta"
  vpc_id        = "${data.aws_vpc.main.id}"

  ## Terracotta ports
  ingress {
    from_port   = 9510
    to_port     = 9510
    protocol    = "tcp"
    cidr_blocks = [
      "${concat(
        "${local.common_access_cidrs}",
        "${list(data.aws_vpc.main.cidr_block)}"
      )}"
    ]
  }

  ingress {
    from_port   = 9520
    to_port     = 9520
    protocol    = "tcp"
    cidr_blocks = [
      "${concat(
        "${local.common_access_cidrs}",
        "${list(data.aws_vpc.main.cidr_block)}"
      )}"
    ]
  }

  ingress {
    from_port   = 9530
    to_port     = 9530
    protocol    = "tcp"
    cidr_blocks = [
      "${concat(
        "${local.common_access_cidrs}",
        "${list(data.aws_vpc.main.cidr_block)}"
      )}"
    ]
  }

  ingress {
    from_port   = 9540
    to_port     = 9540
    protocol    = "tcp"
    cidr_blocks = [
      "${concat(
        "${local.common_access_cidrs}",
        "${list(data.aws_vpc.main.cidr_block)}"
      )}"
    ]
  }

  ## TMC ports
  ingress {
    from_port   = 9443
    to_port     = 9443
    protocol    = "tcp"
    cidr_blocks = [
      "${concat(
        "${local.common_access_cidrs}",
        "${list(data.aws_vpc.main.cidr_block)}"
      )}"
    ]
  }

  ingress {
    from_port   = 9889
    to_port     = 9889
    protocol    = "tcp"
    cidr_blocks = [
      "${concat(
        "${local.common_access_cidrs}",
        "${list(data.aws_vpc.main.cidr_block)}"
      )}"
    ]
  }

  ##SPM communication
  ingress {
    from_port   = 8092
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = [
      "${data.aws_subnet.COMMON_MGT.*.cidr_block}"
    ]
  }

  ### TODO: Need to figure out what exact port to allow in egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${list(data.aws_vpc.main.cidr_block)}"]
  }

  lifecycle {
    create_before_destroy = true
  }

  //Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-Terracotta",
      "az", "all"
    )
  )}"
}

###### MY WEBMETHODS SERVER ###### 
resource "aws_security_group" "mws" {
  name        = "${local.name_prefix_unique_short}-mws"
  description = "My webMethods Server"
  vpc_id        = "${data.aws_vpc.main.id}"

  ingress {
    from_port   = 8585
    to_port     = 8587
    protocol    = "tcp"
    cidr_blocks = [
      "${concat(
        "${local.common_access_cidrs}",
        "${list(data.aws_vpc.main.cidr_block)}"
      )}"
    ]
  }

  ##SPM communication
  ingress {
    from_port   = 8092
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = [
      "${data.aws_subnet.COMMON_MGT.*.cidr_block}"
    ]
  }

  ### TODO: Need to figure out what exact port to allow in egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${list(data.aws_vpc.main.cidr_block)}"]
  }

  lifecycle {
    create_before_destroy = true
  }

  //Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-My webMethods Server",
      "az", "all"
    )
  )}"
}

###### UNIVERSAL MESSAGING ###### 
resource "aws_security_group" "universalmessaging" {
  name        = "${local.name_prefix_unique_short}-universalmessaging"
  description = "Universal Messaging"
  vpc_id        = "${data.aws_vpc.main.id}"

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = [
      "${concat(
        "${local.common_access_cidrs}",
        "${list(data.aws_vpc.main.cidr_block)}"
      )}"
    ]
  }

  ingress {
    from_port   = 8888
    to_port     = 8888
    protocol    = "tcp"
    cidr_blocks = [
      "${concat(
        "${local.common_access_cidrs}",
        "${list(data.aws_vpc.main.cidr_block)}"
      )}"
    ]
  }

  ingress {
    from_port   = 9999
    to_port     = 9999
    protocol    = "tcp"
    cidr_blocks = [
      "${concat(
        "${local.common_access_cidrs}",
        "${list(data.aws_vpc.main.cidr_block)}"
      )}"
    ]
  }

  ingress {
    from_port   = 9001
    to_port     = 9004
    protocol    = "tcp"
    cidr_blocks = [
      "${concat(
        "${local.common_access_cidrs}",
        "${list(data.aws_vpc.main.cidr_block)}"
      )}"
    ]
  }

  ##SPM communication
  ingress {
    from_port   = 8092
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = [
      "${data.aws_subnet.COMMON_MGT.*.cidr_block}"
    ]
  }

  ### TODO: Need to figure out what exact port to allow in egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${list(data.aws_vpc.main.cidr_block)}"]
  }

  lifecycle {
    create_before_destroy = true
  }

  //Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-webmethods Universal Messaging",
      "az", "all"
    )
  )}"
}
