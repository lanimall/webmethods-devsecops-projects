############# S3 ############

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = "${aws_s3_bucket.main.id}"

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

//create an S3 bucket for the External Load Balancer to stash logs
//remember, the bucket name must be unique across all users of AWS!
resource "aws_s3_bucket" "main" {
  count = "${lookup(var.solution_enable, "storagefile") == "true" ? 1 : 0}"

  bucket = "${local.name_prefix}-main"

  versioning {
    enabled = true
  }

  //  Use our common tags and add a specific name.
  tags = "${merge(
    local.common_tags,
    map(
      "Name", "${local.name_prefix}-main"
    )
  )}"
}

resource "aws_s3_bucket_object" "sag-content-images-fixes" {
    bucket = "${aws_s3_bucket.main.id}"
    acl    = "private"
    key    = "${local.name_prefix}/sag_content/images/fixes/.ignore"
    source = "${file("${path.cwd}/helper_scripts/empty")}"
}

resource "aws_s3_bucket_object" "sag-content-images-products" {
    bucket = "${aws_s3_bucket.main.id}"
    acl    = "private"
    key    = "${local.name_prefix}/sag_content/images/products/.ignore"
    source = "${file("${path.cwd}/helper_scripts/empty")}"
}

resource "aws_s3_bucket_object" "sag-content-installers" {
    bucket = "${aws_s3_bucket.main.id}"
    acl    = "private"
    key    = "${local.name_prefix}/sag_content/installers/.ignore"
    source = "${file("${path.cwd}/helper_scripts/empty")}"
}

resource "aws_s3_bucket_object" "sag-content-licenses" {
    bucket = "${aws_s3_bucket.main.id}"
    acl    = "private"
    key    = "${local.name_prefix}/sag_content/licenses/.ignore"
    source = "${file("${path.cwd}/helper_scripts/empty")}"
}

resource "aws_s3_bucket_object" "devops-content" {
    bucket = "${aws_s3_bucket.main.id}"
    acl    = "private"
    key    = "${local.name_prefix}/devops_content/.ignore"
    source = "${file("${path.cwd}/helper_scripts/empty")}"
}