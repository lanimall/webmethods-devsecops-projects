############# S3 ############

output "main_s3_bucket" {
  value = aws_s3_bucket.main.*.id
}

output "policy_sagcontent_s3_readwrite_arn" {
  value = aws_iam_policy.sagcontent-s3-readwrite.arn
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

//create an S3 bucket for the External Load Balancer to stash logs
//remember, the bucket name must be unique across all users of AWS, which should be achieved with the name_prefix_long
resource "aws_s3_bucket" "main" {
  bucket        = "${local.name_prefix_long}-main"
  force_destroy = true
  versioning {
    enabled = true
  }

  //  Use our common tags and add a specific name.
  tags = merge(
    local.common_tags,
    {
      "Name" = "${local.name_prefix_long}-main"
    },
  )
}

resource "aws_iam_policy" "sagcontent-s3-readwrite" {
  name        = "${local.name_prefix_short}-sagcontent-s3-readwrite"
  path        = "/"
  description = "s3 read write policy"

  lifecycle {
    create_before_destroy = true
  }

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement":
    [
        {
        "Effect": "Allow",
        "Action":
            [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
        "Resource": "${aws_s3_bucket.main.arn}"
        },
        {
        "Effect": "Allow",
        "Action":
            [
                "s3:GetObject",
                "s3:PutObject",
                "s3:ListMultipartUploadParts",
                "s3:AbortMultipartUpload"
            ],
        "Resource": "${aws_s3_bucket.main.arn}/*"
        }
    ]
}
  
EOF

}

resource "aws_s3_bucket_object" "sag-content-images-fixes" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
  key    = "${local.name_prefix_long}/sag_content/images/fixes/.ignore"
  source = file("${path.cwd}/helper_scripts/empty")
}

resource "aws_s3_bucket_object" "sag-content-images-products" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
  key    = "${local.name_prefix_long}/sag_content/images/products/.ignore"
  source = file("${path.cwd}/helper_scripts/empty")
}

resource "aws_s3_bucket_object" "sag-content-installers" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
  key    = "${local.name_prefix_long}/sag_content/installers/.ignore"
  source = file("${path.cwd}/helper_scripts/empty")
}

resource "aws_s3_bucket_object" "sag-content-licenses" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
  key    = "${local.name_prefix_long}/sag_content/licenses/.ignore"
  source = file("${path.cwd}/helper_scripts/empty")
}

resource "aws_s3_bucket_object" "devops-content" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
  key    = "${local.name_prefix_long}/devops_content/.ignore"
  source = file("${path.cwd}/helper_scripts/empty")
}