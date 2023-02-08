resource "aws_s3_bucket" "cobudget" {
  bucket = "cobudget-eu-central-1-receipts"
}

resource "aws_s3_bucket_public_access_block" "cobudget" {
  bucket = aws_s3_bucket.cobudget.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}