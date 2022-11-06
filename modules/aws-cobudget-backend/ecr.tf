resource "aws_ecr_repository" "ecr_cobudget" {
  name = "cobudget-backend"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_iam_user" "github_actions" {
  name = "github-actions"
}

data "aws_iam_policy_document" "ecr_cobudget_upload" {
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetLifecyclePolicy",
      "ecr:PutImage"
    ]
    resources = [aws_ecr_repository.ecr_cobudget.arn]
  }
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecr_cobudget" {
  name        = "ecr-cobudget-upload"
  description = "Policy to write images to ecr"
  policy      = data.aws_iam_policy_document.ecr_cobudget_upload.json
}

resource "aws_iam_user_policy_attachment" "github_actions_ecr_cobudget_upload" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.ecr_cobudget.arn
}

resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

resource "aws_ecr_lifecycle_policy" "cobudget" {
  repository = aws_ecr_repository.ecr_cobudget.name
  policy     = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the newest images of CoBudget"
        selection    = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 2
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}