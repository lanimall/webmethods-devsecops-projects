
output "main-vpc" {
  value = "${data.aws_vpc.main.id}"
}

output "subnets-COMMON_DMZ" {
  value = "${data.aws_subnet.COMMON_DMZ.*.id}"
}

output "subnets-COMMON_WEB" {
  value = "${data.aws_subnet.COMMON_WEB.*.id}"
}

output "subnets-COMMON_APPS" {
  value = "${data.aws_subnet.COMMON_APPS.*.id}"
}

output "subnets-COMMON_MGT" {
  value = "${data.aws_subnet.COMMON_MGT.*.id}"
}

output "subnets-COMMON_DATA" {
  value = "${data.aws_subnet.COMMON_DATA.*.id}"
}

###################### get the VPC from ID
data "aws_vpc" "main" {
  id = "${var.main_vpc_id}"
}

###################### DMZ subnets ######

data "aws_subnet_ids" "COMMON_DMZ" {
  vpc_id = "${data.aws_vpc.main.id}"

  tags = {
    ShortName = "${var.subnet_shortname_dmz}"
  }
}

data "aws_subnet" "COMMON_DMZ_unsorted" {
  count = "${length(data.aws_subnet_ids.COMMON_DMZ.ids)}"
  id    = "${data.aws_subnet_ids.COMMON_DMZ.ids[count.index]}"
}

###################### WEB subnets ######

data "aws_subnet_ids" "COMMON_WEB" {
  vpc_id = "${data.aws_vpc.main.id}"

  tags = {
    ShortName = "${var.subnet_shortname_web}"
  }
}

data "aws_subnet" "COMMON_WEB_unsorted" {
  count = "${length(data.aws_subnet_ids.COMMON_WEB.ids)}"
  id    = "${data.aws_subnet_ids.COMMON_WEB.ids[count.index]}"
}

###################### APPS subnets ######

data "aws_subnet_ids" "COMMON_APPS" {
  vpc_id = "${data.aws_vpc.main.id}"

  tags = {
    ShortName = "${var.subnet_shortname_apps}"
  }
}

data "aws_subnet" "COMMON_APPS_unsorted" {
  count = "${length(data.aws_subnet_ids.COMMON_APPS.ids)}"
  id    = "${data.aws_subnet_ids.COMMON_APPS.ids[count.index]}"
}

###################### Management subnets ######

data "aws_subnet_ids" "COMMON_MGT" {
  vpc_id = "${data.aws_vpc.main.id}"

  tags = {
    ShortName = "${var.subnet_shortname_management}"
  }
}

data "aws_subnet" "COMMON_MGT_unsorted" {
  count = "${length(data.aws_subnet_ids.COMMON_MGT.ids)}"
  id    = "${data.aws_subnet_ids.COMMON_MGT.ids[count.index]}"
}

###################### DATA subnets ######

data "aws_subnet_ids" "COMMON_DATA" {
  vpc_id = "${data.aws_vpc.main.id}"

  tags = {
    ShortName = "${var.subnet_shortname_data}"
  }
}

data "aws_subnet" "COMMON_DATA_unsorted" {
  count = "${length(data.aws_subnet_ids.COMMON_DATA.ids)}"
  id    = "${data.aws_subnet_ids.COMMON_DATA.ids[count.index]}"
}

###################### Sort subnets by AZ for predictable ordering ######

locals {
  subnet_dmz_ids_sorted_by_az   = "${values(zipmap(data.aws_subnet.COMMON_DMZ_unsorted.*.availability_zone, data.aws_subnet.COMMON_DMZ_unsorted.*.id))}"
  subnet_web_ids_sorted_by_az   = "${values(zipmap(data.aws_subnet.COMMON_WEB_unsorted.*.availability_zone, data.aws_subnet.COMMON_WEB_unsorted.*.id))}"
  subnet_apps_ids_sorted_by_az   = "${values(zipmap(data.aws_subnet.COMMON_APPS_unsorted.*.availability_zone, data.aws_subnet.COMMON_APPS_unsorted.*.id))}"
  subnet_mgt_ids_sorted_by_az   = "${values(zipmap(data.aws_subnet.COMMON_MGT_unsorted.*.availability_zone, data.aws_subnet.COMMON_MGT_unsorted.*.id))}"
  subnet_data_ids_sorted_by_az   = "${values(zipmap(data.aws_subnet.COMMON_DATA_unsorted.*.availability_zone, data.aws_subnet.COMMON_DATA_unsorted.*.id))}"
}

data "aws_subnet" "COMMON_DMZ" {
  count = "${length(local.subnet_dmz_ids_sorted_by_az)}"
  id    = "${element(local.subnet_dmz_ids_sorted_by_az,count.index)}"
}

data "aws_subnet" "COMMON_WEB" {
  count = "${length(local.subnet_web_ids_sorted_by_az)}"
  id    = "${element(local.subnet_web_ids_sorted_by_az,count.index)}"
}

data "aws_subnet" "COMMON_APPS" {
  count = "${length(local.subnet_apps_ids_sorted_by_az)}"
  id    = "${element(local.subnet_apps_ids_sorted_by_az,count.index)}"
}

data "aws_subnet" "COMMON_MGT" {
  count = "${length(local.subnet_mgt_ids_sorted_by_az)}"
  id    = "${element(local.subnet_mgt_ids_sorted_by_az,count.index)}"
}

data "aws_subnet" "COMMON_DATA" {
  count = "${length(local.subnet_data_ids_sorted_by_az)}"
  id    = "${element(local.subnet_data_ids_sorted_by_az,count.index)}"
}