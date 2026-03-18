organization = "dccc"
team         = "sp"
env          = "dev"
aws_region   = "us-gov-west-1"


lambda_artifact_bucket = "dccc-sp-dev-lambda-artifacts" # S3 bucket where CI/CD stores Lambda & layer zips

lambda_functions = {
   digest_index = {
    purpose      = "indexing"
    handler      = "index.handler"
    runtime      = "python3.9"
    role_arn     = "arn:aws-us-gov:iam::352940330073:role/lambda-execution-role"
    environment_variables = {
      STAGE = "dev"
    }
    s3_key            = "lambdas/digest_index.zip"
    #source_code_hash  = "REPLACE BY CICD"
    create_layer      = true
    layer_s3_key      = "layers/digest_index.zip"
    layers            = []
    s3_event          = null
  }
    Hello = {
    purpose      = "HelloVPC"
    handler      = "Hello.handler"
    runtime      = "python3.9"
    role_arn     = "arn:aws-us-gov:iam::352940330073:role/lambda-execution-role"
    environment_variables = {
      STAGE = "dev"
    }
    s3_key            = "lambdas/Hello.zip"
    #source_code_hash  = "REPLACE BY CICD"
    create_layer      = false 
    layers            = []
    s3_event          = null
  }

}
