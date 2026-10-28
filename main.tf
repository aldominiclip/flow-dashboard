# The bucket that stores and serves the site files.
# Exists because S3 website hosting serves the files straight from the bucket.
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
}

# Keeps every old version of a file when it is overwritten or deleted.
# Exists so a bad index.html can be looked up and restored.
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Deletes old versions after 90 days.
# Exists because every change adds a version, and old versions are billed like normal files.
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  # AWS rejects noncurrent-version rules until versioning is on.
  depends_on = [aws_s3_bucket_versioning.this]
}

# Still blocks ACLs, but allows a public bucket policy.
# Exists because S3 website hosting needs anonymous read access through the policy below.
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false
  restrict_public_buckets = false
}

# Turns on the S3 website endpoint.
# Exists so / serves index.html and missing paths serve error.html.
resource "aws_s3_bucket_website_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Lets anyone read the files.
# Exists because the S3 website endpoint only serves objects that are publicly readable.
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "PublicReadGetObject"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.this.arn}/*"
    }]
  })

  # AWS rejects a public policy while block_public_policy is still on.
  depends_on = [aws_s3_bucket_public_access_block.this]
}