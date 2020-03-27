########################################################################
############ Security groups for the current solutions
########################################################################

###### INTEGRATION SERVER ###### 
resource "aws_security_group" "integrationserver" {
  name        = "${local.name_prefix_unique_short}-integrationserver"
  description = "Integration Server"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port = 5555
    to_port   = 5555
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9999
    to_port   = 9999
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ##SPM communication
  ingress {
    from_port   = 8092
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = data.aws_subnet.COMMON_MGT.*.cidr_block
  }

  ### TODO: Need to figure out what exact port to allow in egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  lifecycle {
    create_before_destroy = true
  }

  //Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-webMethods Integration Server"
      "az"   = "all"
    },
  )
}

###### TERRACOTTA ###### 
resource "aws_security_group" "terracotta" {
  name        = "${local.name_prefix_unique_short}-terracotta"
  description = "Terracotta"
  vpc_id      = data.aws_vpc.main.id

  ## Terracotta ports
  ingress {
    from_port = 9510
    to_port   = 9510
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9520
    to_port   = 9520
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9530
    to_port   = 9530
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9540
    to_port   = 9540
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ## TMC ports
  ingress {
    from_port = 9443
    to_port   = 9443
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9889
    to_port   = 9889
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ##SPM communication
  ingress {
    from_port   = 8092
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = data.aws_subnet.COMMON_MGT.*.cidr_block
  }

  ### TODO: Need to figure out what exact port to allow in egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  lifecycle {
    create_before_destroy = true
  }

  //Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-Terracotta"
      "az"   = "all"
    },
  )
}

###### UNIVERSAL MESSAGING ###### 
resource "aws_security_group" "universalmessaging" {
  name        = "${local.name_prefix_unique_short}-universalmessaging"
  description = "Universal Messaging"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port = 9000
    to_port   = 9000
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ingress {
    from_port = 8888
    to_port   = 8888
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9999
    to_port   = 9999
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9001
    to_port   = 9004
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ##SPM communication
  ingress {
    from_port   = 8092
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = data.aws_subnet.COMMON_MGT.*.cidr_block
  }

  ### TODO: Need to figure out what exact port to allow in egress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  lifecycle {
    create_before_destroy = true
  }

  //Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-webmethods Universal Messaging"
      "az"   = "all"
    },
  )
}

###### API GATEWAY ###### 
resource "aws_security_group" "apigateway" {
  name        = "${local.name_prefix_unique_short}-apigateway"
  description = "Software AG API Gateway Server"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port = 5555
    to_port   = 5555
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9999
    to_port   = 9999
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9072
    to_port   = 9073
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ##SPM communication
  ingress {
    from_port   = 8092
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = data.aws_subnet.COMMON_MGT.*.cidr_block
  }

  ### TODO: Need to figure out what exact port to allow in egress
  ### likely the elastic search node to node communication
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-apigateway"
      "az"   = "all"
    },
  )
}

###### API GATEWAY INTERNAL DATASTORE ###### 
resource "aws_security_group" "apigw-internaldatastore" {
  name        = "${local.name_prefix_unique_short}-apigw-internaldatastore"
  description = "Software AG API Gateway Internal Data Store"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port = 9240
    to_port   = 9240
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ingress {
    from_port = 9340
    to_port   = 9340
    protocol  = "tcp"
    cidr_blocks = flatten(
      [
        local.common_access_cidrs, 
        data.aws_vpc.main.cidr_block
      ]
    )
  }

  ##SPM communication
  ingress {
    from_port   = 8092
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = data.aws_subnet.COMMON_MGT.*.cidr_block
  }

  ### TODO: Need to figure out what exact port to allow in egress
  ### likely the elastic search node to node communication
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-apigw-internaldatastore"
      "az"   = "all"
    },
  )
}