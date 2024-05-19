# Create an s3 bucket for website
resource "aws_s3_bucket" "website_bucket" {
  bucket = "sakarltechwebbucket"
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "website_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.website_bucket,
    aws_s3_bucket_public_access_block.website_bucket,
  ]

  bucket = aws_s3_bucket.website_bucket.id
  acl    = "public-read"
}

# Configure website
resource "aws_s3_bucket_website_configuration" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "docs/"
    }
    redirect {
      replace_key_prefix_with = "documents/"
    }
  }
}

# Create a bucket policy
resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.website_bucket.arn,
      "${aws_s3_bucket.website_bucket.arn}/*",
    ]
  }
}