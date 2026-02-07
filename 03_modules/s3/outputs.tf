output "source_bucket_arn" {
  value = {
    for k, v in aws_s3_bucket.source : k => v.arn
  }
}

output "dest_bucket_arn" {
  value = {
    for k, v in aws_s3_bucket.destination : k => v.arn
  }
}
