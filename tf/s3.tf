module "s3" {
  source      = "./modules/s3"
  bucket_name = var.db_backup_bucket
  tags        = var.common_tags
}