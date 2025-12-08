resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]
}

resource "aws_iam_role" "fred_ball_api_github_actions_role" {
  name = "FredBallApiGitHubActionsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : aws_iam_openid_connect_provider.github.arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : "repo:lukasb27/fred-ball-backend:*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "fred_ball_api_github_actions_policy" {
  name = "FredBallApiGitHubActionsPolicy"
  role = aws_iam_role.fred_ball_api_github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "lambda:UpdateFunctionCode"
        ],
        Resource = [
          "${module.s3_bucket_backend.s3_bucket_arn}/*",
          aws_lambda_function.fred_ball_api.arn
        ]
      }
    ]
  })

}

resource "aws_iam_role" "fred_ball_front_end_github_actions_role" {
  name = "FredBallApiGitHubActionsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : aws_iam_openid_connect_provider.github.arn
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "token.actions.githubusercontent.com:aud" : "sts.amazonaws.com"
          },
          "StringLike" : {
            "token.actions.githubusercontent.com:sub" : "repo:lukasb27/fred-ball-frontend :*"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "fred_ball_front_end_github_actions_policy" {
  name = "FredBallApiGitHubActionsPolicy"
  role = aws_iam_role.fred_ball_api_github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
        ],
        Resource = [
          "${module.s3_bucket.s3_bucket_arn}/*"
        ]
      }
    ]
  })

}
