############# RDS ############

variable "rds_root_username" {
  description = "Root username for main RDS instance"
  default     = "root"
}

variable "rds_root_password" {
  description = "Root password for main RDS instance"
  default     = "changeme"
}

## some locals here
## fyi express edition = "sqlserver-ex"
locals {
  db-name                   = "maindb"
  db-engine-name            = "sqlserver-se"
  db-engine-major-version   = "13.00"
  db-engine-full-version    = "13.00.5366.0.v1"
  db-engine-family          = "sqlserver-se-13.0"
  db-identifier-prefix      = "${local.name_prefix_unique_short}-${local.db-name}"
  db-identifier-prefix-long = "${local.name_prefix_long}-${local.db-name}"
}

resource "random_id" "maindb-optiongroup" {
  count = var.solution_enable["storagedb"] == "true" ? 1 : 0

  keepers = {
    engine-name          = local.db-engine-name
    engine-major-version = local.db-engine-major-version
    engine-family        = local.db-engine-family
    vpc_id               = aws_vpc.main.id
  }
  byte_length = 3
}

//  Security group which allows SSH/RDP access to a host, strictly from the bastion
resource "aws_security_group" "maindb" {
  count = var.solution_enable["storagedb"] == "true" ? 1 : 0

  name        = "${local.db-identifier-prefix}-${random_id.maindb-optiongroup[0].hex}"
  description = "Security group that allows access to db from specific subnets"
  vpc_id      = aws_vpc.main.id

  //  SSH
  ingress {
    from_port = 1433
    to_port   = 1433
    protocol  = "tcp"
    cidr_blocks = [
      aws_subnet.COMMON_DATA.*.cidr_block,
      aws_subnet.COMMON_APPS[0].cidr_block,
    ]
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.db-identifier-prefix-long}-${random_id.maindb-optiongroup[0].hex}"
    },
  )
}

resource "aws_db_option_group" "maindb" {
  count = var.solution_enable["storagedb"] == "true" ? 1 : 0

  name                     = "${local.db-identifier-prefix}-${random_id.maindb-optiongroup[0].hex}"
  option_group_description = "Option group for ${local.name_prefix_unique_short}-${local.db-name}"

  engine_name          = local.db-engine-name
  major_engine_version = local.db-engine-major-version

  #option {
  #  option_name = "SQLSERVER_BACKUP_RESTORE"
  #
  #
  #  option_settings {
  #    name  = "IAM_ROLE_ARN"
  #    value = "${aws_iam_role.example.arn}"
  #  }
  #}

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.db-identifier-prefix-long}-${random_id.maindb-optiongroup[0].hex}"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_subnet_group" "maindb" {
  count = var.solution_enable["storagedb"] == "true" ? 1 : 0

  name        = "${local.db-identifier-prefix}-${random_id.maindb-optiongroup[0].hex}"
  description = "Database subnet group for ${local.name_prefix_unique_short}-${local.db-name}"
  subnet_ids = [
    aws_subnet.COMMON_DATA.*.id,
    aws_subnet.COMMON_APPS[0].id,
  ]

  //Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = local.db-identifier-prefix-long
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_parameter_group" "maindb" {
  count = var.solution_enable["storagedb"] == "true" ? 1 : 0

  name        = "${local.db-identifier-prefix}-${random_id.maindb-optiongroup[0].hex}"
  description = "Database param group for ${local.name_prefix_unique_short}-${local.db-name}"
  family      = local.db-engine-family

  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.db-identifier-prefix-long}-${random_id.maindb-optiongroup[0].hex}"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_kms_key" "maindb" {
  count = var.solution_enable["storagedb"] == "true" ? 1 : 0

  description             = "KMS key for RDS encryption of instance ${local.db-identifier-prefix}-${random_id.maindb-optiongroup[0].hex}"
  deletion_window_in_days = 10

  tags = merge(local.common_tags)
}

resource "aws_db_instance" "maindb" {
  count = var.solution_enable["storagedb"] == "true" ? 1 : 0

  identifier = "${local.db-identifier-prefix}-${random_id.maindb-optiongroup[0].hex}"

  ## sql server 2016
  engine_version = local.db-engine-full-version
  engine         = local.db-engine-name
  license_model  = "license-included"

  instance_class        = "db.m5.large"
  allocated_storage     = 20
  max_allocated_storage = 100

  ### only available with SE
  storage_encrypted = true
  kms_key_id        = aws_kms_key.maindb[0].arn

  username = var.rds_root_username
  password = var.rds_root_password

  port = "1433"

  iam_database_authentication_enabled = false

  #### only needed if creating from a snapshot
  ##snapshot_identifier = "${local.name_prefix_unique_short}-maindb"

  vpc_security_group_ids = [
    aws_security_group.maindb[0].id,
  ]

  db_subnet_group_name = aws_db_subnet_group.maindb[0].name
  parameter_group_name = aws_db_option_group.maindb[0].name
  option_group_name    = aws_db_parameter_group.maindb[0].name

  availability_zone   = element(split(",", var.azs[var.region]), 0)
  multi_az            = false
  publicly_accessible = false

  ##The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0
  monitoring_interval = 0

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  apply_immediately           = true
  maintenance_window          = "Sat:03:00-Sat:06:00"
  skip_final_snapshot         = false
  copy_tags_to_snapshot       = true
  final_snapshot_identifier   = "${local.name_prefix_unique_short}-${local.db-name}-predestroy-final-snapshot"

  performance_insights_enabled = false

  backup_retention_period = "7"

  ## note: backup window and maintenance window cannot overlap
  backup_window = "00:00-02:00"

  timezone = "Eastern Standard Time"

  deletion_protection = false

  tags = merge(
    local.common_tags,
    local.instance_tags_schedule_stop,
    local.instance_tags_schedule_start,
    local.instance_tags_retention,
    {
      "Name" = "${local.db-identifier-prefix-long}-${random_id.maindb-optiongroup[0].hex}"
    },
  )

  timeouts {
    create = var.timeouts["create"]
    delete = var.timeouts["delete"]
    update = var.timeouts["update"]
  }
}

