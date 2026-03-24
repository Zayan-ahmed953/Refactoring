locals {
  lambda_config = jsondecode(file("${path.module}/../../lambda-configs/sanitized/app-function-uat.json"))
}

# Existing role looked up by name and passed as ARN to module input.
data "aws_iam_role" "lambda_execution_role" {
  name = "Backend-lambda-role-krrmjq13"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../../lambda-code/hello-world/lambda_function.py"
  output_path = "${path.module}/app-function-uat.zip"
}

resource "aws_s3_object" "lambda_artifact" {
  bucket = "demo-terraform-state-bucket-7832"
  key    = "artifacts/app-function-uat.zip"
  source = data.archive_file.lambda_zip.output_path
  etag   = filemd5(data.archive_file.lambda_zip.output_path)
}

module "lambda" {
  source = "../../modules/lambda"

  # Required module context inputs.
  aws_region   = "us-east-1"
  organization = "shared"
  team         = "app"
  env          = "uat"
  purpose      = "function"

  # Lambda configuration from sanitized JSON.
  lambda_name           = local.lambda_config.FunctionName
  # Local artifact contains lambda_function.py, so handler must match that module.
  handler               = "lambda_function.lambda_handler"
  runtime               = local.lambda_config.Runtime
  timeout               = local.lambda_config.Timeout
  memory_size           = local.lambda_config.MemorySize
  role_arn              = data.aws_iam_role.lambda_execution_role.arn
  environment_variables = try(local.lambda_config.Environment.Variables, {})

  lambda_s3_bucket  = aws_s3_object.lambda_artifact.bucket
  lambda_s3_key     = aws_s3_object.lambda_artifact.key
  source_code_hash  = data.archive_file.lambda_zip.output_base64sha256
}

resource "aws_lambda_invocation" "invoke_app_function_uat" {
  function_name = module.lambda.function_name
  input         = jsonencode({ stage = "uat" })

  depends_on = [module.lambda]
}