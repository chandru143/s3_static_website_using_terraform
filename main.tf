##### Creating a Random String #####
resource "random_string" "random" {
  length = 6
  special = false
  upper = false
} 

##### Creating an S3 Bucket #####
resource "aws_s3_bucket" "static-bucket" {
  bucket = "static-2024-${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "blog" {
  bucket = aws_s3_bucket.static-bucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.static-bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

##### will upload all the files present under HTML folder to the S3 bucket #####
resource "aws_s3_object" "upload_object" {
  for_each      = fileset("s3_files/html/", "*")
  bucket        = aws_s3_bucket.static-bucket.id
  key           = each.value
  source        = "s3_files/html/${each.value}"
  etag          = filemd5("s3_files/html/${each.value}")
  content_type  = "text/html"
}

