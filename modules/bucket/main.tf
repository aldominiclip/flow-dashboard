# The bucket that stores the site files.
# Exists because CloudFront needs an origin to fetch the files from.
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

# Blocks every kind of public access to the bucket.
# Exists so visitors can only reach the files through CloudFront, never straight from S3.
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}
