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