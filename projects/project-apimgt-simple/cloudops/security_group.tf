########################################################################
############ Security groups for the current solutions
########################################################################

###### API GATEWAY ###### 
resource "aws_security_group" "apigateway" {
  name        = "${local.name_prefix}-apigateway-sg"
  description = "Software AG API Gateway Server"
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

  ingress {
    from_port   = 9072
    to_port     = 9073
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
  ### likely the elastic search node to node communication
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${list(data.aws_vpc.main.cidr_block)}"]
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-apigateway",
      "az", "all"
    )
  )}"
}

###### API GATEWAY INTERNAL DATASTORE ###### 
resource "aws_security_group" "apigw-internaldatastore" {
  name        = "${local.name_prefix}-apigw-internaldatastore-sg"
  description = "Software AG API Gateway Internal Data Store"
  vpc_id        = "${data.aws_vpc.main.id}"

  ingress {
    from_port   = 9240
    to_port     = 9240
    protocol    = "tcp"
    cidr_blocks = [
      "${concat(
        "${local.common_access_cidrs}",
        "${list(data.aws_vpc.main.cidr_block)}"
      )}"
    ]
  }

  ingress {
    from_port   = 9340
    to_port     = 9340
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
  ### likely the elastic search node to node communication
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${list(data.aws_vpc.main.cidr_block)}"]
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-apigw-internaldatastore",
      "az", "all"
    )
  )}"
}

###### API PORTAL ###### 
resource "aws_security_group" "apiportal" {
  name        = "${local.name_prefix}-apiportal-sg"
  description = "Software AG API Portal Server"
  vpc_id        = "${data.aws_vpc.main.id}"

  ingress {
    from_port   = 18101
    to_port     = 18101
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

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-apiportal",
      "az", "all"
    )
  )}"
}

###### INTEGRATION SERVER ###### 
resource "aws_security_group" "webmethods-integrationserver" {
  name        = "${local.name_prefix}-wm-integrationserver"
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

  //Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-webMethods Integration Server",
      "az", "all"
    )
  )}"
}