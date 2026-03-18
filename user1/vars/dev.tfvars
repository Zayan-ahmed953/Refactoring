organization = "dccc"
team = "sp"
env  = "dev"
aws_region  = "us-gov-west-1"
enable_versioning = true
sse_algorithm = "AES256"

s3_buckets = {
    kics = { purpose = "kics" }
    lambda-artifacts = { purpose = "lambda-artifacts"}
    glue-scripts = { purpose = "glue-scripts"}
}