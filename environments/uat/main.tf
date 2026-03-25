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

  # Lambda configuration from sanitized JSON.
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
#How do I add multiple IAM roles to a single Lambda function, since we have multiple IAM roles attached to a lambda function as you can see in lambda-config.json
#We need the sample created lambda function to be attached to an API gateway for demo
#We should use terraform lambda module from https://github.com/Zayan-ahmed953/github-refactoring/blob/main/modules/lambda/main.tf, since it doesnt have unnessasary requirments, but its missing AWS IAM attachment to lambda function
#We also need a module for creating IAM roles which will then be attached to the lambda function
#We need to suggest a code scanning tool which will be approved by gov and only then will be implemented, our team tried Sonarqube which was rejected, the best one seems for be AWS Inspector (but needs to be tested if it scans code) We are not talking about terraform code here