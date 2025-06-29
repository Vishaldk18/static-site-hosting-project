# for unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# computed random id for bucket name
locals {
  bucket_name = "my-static-site-${random_id.bucket_suffix.hex}"
}


# Creating a bucket
resource "aws_s3_bucket" "my_host_bucket" {
    bucket = local.bucket_name
    tags = {
        Name="my_host_bucket"
        Environment = var.environment
    }
}

# Disable ACLs and enforce secure ownership
resource "aws_s3_bucket_ownership_controls" "my_host_bucket-ownership"{
   bucket = aws_s3_bucket.my_host_bucket.id 
   rule{
      object_ownership = "BucketOwnerEnforced"
   }
}

# Block All Public Access
resource "aws_s3_bucket_public_access_block" "block_public-access" {
  bucket                  = aws_s3_bucket.my_host_bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Server-side encryption is automatically applied to new objects stored in this bucket.

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.my_host_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# Static File Object
resource "aws_s3_object" "html_file" {
    bucket =  aws_s3_bucket.my_host_bucket.id
    key="index.html"
    source="./website/index.html"
    content_type = "text/html"
}


# Origin Access Control (OAC) – if using private bucket
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-oac-access"
  description                       = "CloudFront OAC for S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


# Cloudfront Distribution (CDN)
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.my_host_bucket.bucket_regional_domain_name
    origin_id   = "s3-origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3-origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100" # Cheapest (US, EU)

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "cloudfront-for-static-site"
  }
}

# Bucket Policy to Allow CloudFront (OAC) to Read S3 Objects

resource "aws_s3_bucket_policy" "allow_cloudfront" {
  bucket = aws_s3_bucket.my_host_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.my_host_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })
}
