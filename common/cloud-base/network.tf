//  Define the VPC.
resource "aws_vpc" "main" {
  cidr_block           = local.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-main"
    },
  )
}

###################
# Internet Gateway
###################

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-main"
    },
  )
}

################
# Publiс routes
################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-public"
    },
  )
}

//  Create a route table allowing all addresses access to the IGW.
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id

  timeouts {
    create = "5m"
  }
}

#################
# Private routes
# There are as many routing tables as the number of NAT gateways
#################

resource "aws_route_table" "private" {
  count  = length(split(",", var.azs[var.region]))
  vpc_id = aws_vpc.main.id

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-private-AZ${count.index + 1}"
      "az"   = element(split(",", var.azs[var.region]), count.index)
    },
  )
}

##########################
# NAT GATEWAYS
##########################

// create eip for nat
resource "aws_eip" "NATGW" {
  count = length(split(",", var.azs[var.region]))
  vpc   = true

  tags = {
    Name = "${local.name_prefix_long}-natgw-az${count.index + 1}"
  }
}

resource "aws_nat_gateway" "NATGW" {
  count         = length(split(",", var.azs[var.region]))
  allocation_id = element(aws_eip.NATGW.*.id, count.index)
  subnet_id     = element(aws_subnet.COMMON_DMZ.*.id, count.index)
  depends_on    = [aws_internet_gateway.main]

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-natgw-az${count.index + 1}"
      "az"   = element(split(",", var.azs[var.region]), count.index)
    },
  )
}

resource "aws_route" "private_nat_gateway" {
  count                  = length(split(",", var.azs[var.region]))
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.NATGW.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

########################### SUBNETS - xsmall ####################################

###### COMMON DMZ ######
resource "aws_subnet" "COMMON_DMZ" {
  count                   = length(split(",", var.azs[var.region]))
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(split(",", var.azs[var.region]), count.index)
  map_public_ip_on_launch = false

  cidr_block = cidrsubnet(
    format(
      "%s.%s",
      var.vpc_cidr_prefix,
      var.subnet_allocation_map_suffixes["xsmall"],
    ),
    var.newbit_size["xsmall"],
    0 * length(split(",", var.azs[var.region])) + count.index,
  )

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name"      = "${local.name_prefix_long}-${var.subnet_shortname_dmz}-AZ${count.index + 1}"
      "ShortName" = var.subnet_shortname_dmz
      "az"        = element(split(",", var.azs[var.region]), count.index)
    },
  )
}

###### COMMON DATA ######
resource "aws_subnet" "COMMON_DATA" {
  count                   = length(split(",", var.azs[var.region]))
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(split(",", var.azs[var.region]), count.index)
  map_public_ip_on_launch = false

  cidr_block = cidrsubnet(
    format(
      "%s.%s",
      var.vpc_cidr_prefix,
      var.subnet_allocation_map_suffixes["xsmall"],
    ),
    var.newbit_size["xsmall"],
    1 * length(split(",", var.azs[var.region])) + count.index,
  )

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name"      = "${local.name_prefix_long}-${var.subnet_shortname_data}-AZ${count.index + 1}"
      "ShortName" = var.subnet_shortname_data
      "az"        = element(split(",", var.azs[var.region]), count.index)
    },
  )
}

########################### SUBNETS - small ####################################

###### COMMON MANAGEMENT ######
resource "aws_subnet" "COMMON_MGT" {
  count                   = length(split(",", var.azs[var.region]))
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(split(",", var.azs[var.region]), count.index)
  map_public_ip_on_launch = false

  //cidr_block            = "${cidrsubnet(local.vpc_cidr, 10, count.index + 3 )}"

  cidr_block = cidrsubnet(
    format(
      "%s.%s",
      var.vpc_cidr_prefix,
      var.subnet_allocation_map_suffixes["small"],
    ),
    var.newbit_size["small"],
    0 * length(split(",", var.azs[var.region])) + count.index,
  )

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name"      = "${local.name_prefix_long}-${var.subnet_shortname_management}-AZ${count.index + 1}"
      "ShortName" = var.subnet_shortname_management
      "az"        = element(split(",", var.azs[var.region]), count.index)
    },
  )
}

########################### SUBNETS - medium ####################################

resource "aws_subnet" "COMMON_WEB" {
  count                   = length(split(",", var.azs[var.region]))
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(split(",", var.azs[var.region]), count.index)
  map_public_ip_on_launch = false

  cidr_block = cidrsubnet(
    format(
      "%s.%s",
      var.vpc_cidr_prefix,
      var.subnet_allocation_map_suffixes["medium"],
    ),
    var.newbit_size["medium"],
    0 * length(split(",", var.azs[var.region])) + count.index,
  )

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name"      = "${local.name_prefix_long}-${var.subnet_shortname_web}-AZ${count.index + 1}"
      "ShortName" = var.subnet_shortname_web
      "az"        = element(split(",", var.azs[var.region]), count.index)
    },
  )
}

resource "aws_subnet" "COMMON_APPS" {
  count                   = length(split(",", var.azs[var.region]))
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(split(",", var.azs[var.region]), count.index)
  map_public_ip_on_launch = false

  cidr_block = cidrsubnet(
    format(
      "%s.%s",
      var.vpc_cidr_prefix,
      var.subnet_allocation_map_suffixes["medium"],
    ),
    var.newbit_size["medium"],
    1 * length(split(",", var.azs[var.region])) + count.index,
  )

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name"      = "${local.name_prefix_long}-${var.subnet_shortname_apps}-AZ${count.index + 1}"
      "ShortName" = var.subnet_shortname_apps
      "az"        = element(split(",", var.azs[var.region]), count.index)
    },
  )
}

##########################
# Route table association
##########################

//  Now associate the route table with the public subnet
resource "aws_route_table_association" "COMMON_DMZ" {
  count          = length(split(",", var.azs[var.region]))
  subnet_id      = aws_subnet.COMMON_DMZ[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "COMMON_DATA" {
  count          = length(split(",", var.azs[var.region]))
  subnet_id      = element(aws_subnet.COMMON_DATA.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "COMMON_MGT" {
  count          = length(split(",", var.azs[var.region]))
  subnet_id      = element(aws_subnet.COMMON_MGT.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "COMMON_APPS" {
  count          = length(split(",", var.azs[var.region]))
  subnet_id      = element(aws_subnet.COMMON_APPS.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "COMMON_WEB" {
  count          = length(split(",", var.azs[var.region]))
  subnet_id      = element(aws_subnet.COMMON_WEB.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

