output "standard_bucket" {
  value       = aws_s3_bucket.standard.id
  description = "Standard S3 bucket ID"
}

output "glacier_bucket" {
  value       = aws_s3_bucket.glacier.id
  description = "Glacier S3 bucket ID"
}
