resource "aws_s3_bucket" "mongo_db_backup" {
  bucket = var.bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_policy" "mongo_db_backup_policy" {
  bucket = aws_s3_bucket.mongo_db_backup.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadList"
        Effect    = "Allow"
        Principal = "*"
        Action    = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.mongo_db_backup.id}",
          "arn:aws:s3:::${aws_s3_bucket.mongo_db_backup.id}/*"
        ]
      }
    ]
  })
}