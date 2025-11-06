resource "aws_s3_bucket" "db_backup" {
  bucket = var.bucket_name
  tags   = var.tags
}

