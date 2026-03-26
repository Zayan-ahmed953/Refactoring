## App Lambda
locals {
  app_lambda_config = jsondecode(file("${path.module}/../../lambda-configs/sanitized/app-function-uat.json"))
}

# # Existing role looked up by name and passed as ARN to module input.
# data "aws_iam_role" "lambda_execution_role" {
#   name = "Backend-lambda-role-krrmjq13"
# }

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
  aws_region   = var.region
  organization = var.organization
  team         = var.team
  env          = var.env
  purpose      = "function"

  # Lambda configuration from sanitized JSON.
  lambda_name = local.app_lambda_config.FunctionName
  # Local artifact contains lambda_function.py, so handler must match that module.
  handler               = "lambda_function.lambda_handler"
  runtime               = local.app_lambda_config.Runtime
  timeout               = local.app_lambda_config.Timeout
  memory_size           = local.app_lambda_config.MemorySize
  role_arn              = module.iam_roles.role_arns["app-function-uat-role"]
  environment_variables = try(local.app_lambda_config.Environment.Variables, {})

  lambda_s3_bucket = aws_s3_object.lambda_artifact.bucket
  lambda_s3_key    = aws_s3_object.lambda_artifact.key
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

resource "aws_lambda_invocation" "invoke_app_function_uat" {
  function_name = module.lambda.function_name
  input         = jsonencode({ stage = "uat" })

  depends_on = [module.lambda]
}

module "iam_roles" {
  source = "../../modules/iam"

  tags = {
    Environment = var.env
    Team        = var.team
  }

  roles = {
    "app-function-uat-role" = {
      description          = "Execution role for UAT Lambda"
      assume_role_services = ["lambda.amazonaws.com"]

      # Attach already-created policies by name only
      managed_policy_names = [
        "AdministratorAccess"
      ]
    }
  }
}

## Sample Lambda Function
locals {
  sample_lambda_function_config = jsondecode(file("${path.module}/../../lambda-configs/sanitized/sample-function-uat.json"))
}

data "archive_file" "sample_lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda-code/sample-two-file-function"
  output_path = "${path.module}/sample-function-uat.zip"
}

resource "aws_s3_object" "sample_lambda_artifact" {
  bucket = "demo-terraform-state-bucket-7832"
  key    = "artifacts/sample-function-uat.zip"
  source = data.archive_file.sample_lambda_zip.output_path
  etag   = filemd5(data.archive_file.sample_lambda_zip.output_path)
}

module "sample_lambda" {
  source = "../../modules/lambda"

  # Required module context inputs.
  aws_region   = var.region
  organization = var.organization
  team         = var.team
  env          = var.env
  purpose      = "function"

  # Lambda configuration from sanitized JSON..
  lambda_name = local.sample_lambda_function_config.FunctionName
  # Local artifact contains lambda_function.py, so handler must match that module.
  handler               = "lambda_function.lambda_handler"
  runtime               = local.sample_lambda_function_config.Runtime
  timeout               = local.sample_lambda_function_config.Timeout
  memory_size           = local.sample_lambda_function_config.MemorySize
  role_arn              = module.sample_iam_roles.role_arns["sample-function-uat-role"]
  environment_variables = try(local.sample_lambda_function_config.Environment.Variables, {})

  lambda_s3_bucket = aws_s3_object.sample_lambda_artifact.bucket
  lambda_s3_key    = aws_s3_object.sample_lambda_artifact.key
  source_code_hash = data.archive_file.sample_lambda_zip.output_base64sha256
}

resource "aws_lambda_invocation" "invoke_sample_function_uat" {
  function_name = module.sample_lambda.function_name
  input         = jsonencode({ stage = "uat" })

  depends_on = [module.sample_lambda]
}

module "sample_iam_roles" {
  source = "../../modules/iam"

  tags = {
    Environment = var.env
    Team        = var.team
  }

  roles = {
    "sample-function-uat-role" = {
      description          = "Execution role for Sample UAT Lambda"
      assume_role_services = ["lambda.amazonaws.com"]

      # Attach already-created policies by name only
      managed_policy_names = [
        "AdministratorAccess"
      ]
    }
  }
}

## API Gateway
# Shared HTTP API that can route to one or many Lambda aliases
module "http_api" {
  source   = "../../modules/api-gateway"
  api_name = "shared-http-api-uat"

  # Start with two routes; add more entries here as you create additional Lambda modules.
  routes = {
    app_root = {
      route_key         = local.sample_lambda_function_config.ApiGatewayPaths[1]
      lambda_name       = module.sample_lambda.lambda_function_name
      lambda_alias_name = module.sample_lambda.lambda_alias_name
      lambda_alias_arn  = module.sample_lambda.lambda_alias_arn
    }
    api_root = {
      route_key         = local.app_lambda_config.ApiGatewayPaths[1]
      lambda_name       = module.lambda.lambda_function_name
      lambda_alias_name = module.lambda.lambda_alias_name
      lambda_alias_arn  = module.lambda.lambda_alias_arn
    }
  }

}