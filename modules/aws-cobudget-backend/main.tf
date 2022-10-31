resource "aws_ecr_repository" "aws_ecr_cobudget" {
  name = "cobudget-backend"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_user" "github_actions" {
  name = "github-actions"
}

resource "aws_iam_policy" "ecr_cobudget" {
  name_prefix = "ecr-policy"
  description = "Policy to write images to ecr"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetLifecyclePolicy",
          "ecr:PutImage"
        ]
        Resource = aws_ecr_repository.aws_ecr_cobudget.arn
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "github_actions_ecr_cobudget" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.ecr_cobudget.arn
}

resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

resource "github_repository" "cobudget" {
  name                 = "CoBudget-backend"
  allow_merge_commit   = false
  allow_rebase_merge   = false
  allow_squash_merge   = false
  has_downloads        = true
  has_issues           = true
  has_projects         = true
  has_wiki             = true
  vulnerability_alerts = true
}

resource "github_repository_environment" "cobudget" {
  environment = "cobudget-backend"
  repository  = github_repository.cobudget.name
}

resource "github_actions_secret" "aws_access_key_id" {
  repository      = github_repository.cobudget.name
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = aws_iam_access_key.github_actions.id
}

resource "github_actions_secret" "aws_access_key_secret" {
  repository      = github_repository.cobudget.name
  secret_name     = "AWS_ACCESS_KEY_SECRET"
  plaintext_value = aws_iam_access_key.github_actions.secret
}