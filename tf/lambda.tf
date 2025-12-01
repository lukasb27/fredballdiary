
data "archive_file" "init" {
  type        = "zip"
  source_file = "${path.module}/blah.py"
  output_path = "${path.module}/blah.zip"
}

resource "aws_lambda_function" "fred_ball_api" {
  function_name = "FredBallApi"

  # The bucket name as created earlier with "aws s3api create-bucket"
#   s3_bucket = "terraform-serverless-example"
#   s3_key    = "v1.0.0/example.zip"
  filename = "blah.zip"
  handler = "app.main.handler"
  runtime = "python3.13"

  role = "${aws_iam_role.lambda_exec.arn}"
}

# IAM role which dictates what other AWS services the Lambda function
# may access.
resource "aws_iam_role" "lambda_exec" {
  name = "serverless_example_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}