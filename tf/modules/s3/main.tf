resource "aws_s3_bucket" "mongo_db_backup" {
  bucket = var.bucket_name
  tags   = var.tags
}
