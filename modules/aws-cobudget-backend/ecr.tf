resource "aws_ecr_repository" "ecr_cobudget" {
  name = "cobudget-backend"
  image_scanning_configuration {
    scan_on_push = true
  }
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