
###### COMMAND CENTRAL ###### 
resource "aws_security_group" "webmethods-commandcentral" {
  name        = "${local.name_prefix_unique_short}-wm-commandcentral"
  description = "Command Central"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port   = 8090
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  ## SPM communication outbound
  egress {
    from_port   = 8092
    to_port     = 8093
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  ## SSH comm outbound for wM component bootstrapping
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }

  ## need to ideally figure out what port it needs to access...but seems like it needs to access many of the installed products
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
      "Name" = "${local.name_prefix_long}-webMethods Command Central"
      "az"   = "all"
    },
  )
}

