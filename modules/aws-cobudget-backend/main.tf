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

resource "aws_iam_policy" "ecr_token_cobudget" {
  name_prefix = "ecr-token-policy"
  description = "Policy to get auth token for registry"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "github_actions_ecr_cobudget" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.ecr_cobudget.arn
}

resource "aws_iam_user_policy_attachment" "github_actions_ecr_token_cobudget" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.ecr_token_cobudget.arn
}

resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

resource "github_repository" "cobudget" {
  name                 = "CoBudget-backend"
  allow_merge_commit   = true
  allow_rebase_merge   = true
  allow_squash_merge   = true
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

resource "github_repository_file" "cobudget_workflow_ecr" {
  repository = github_repository.cobudget.name
  file       = ".github/workflows/ecr.yml"
  content = yamlencode({
    name = "Deploy to ECR"
    on = {
      push = {
        branches = ["main"]
      }
    }
    jobs = {
      build = {
        name    = "Build Image"
        runs-on = "ubuntu-latest"
        steps = [
          {
            name = "Configure AWS credentials"
            uses = "aws-actions/configure-aws-credentials@v1"
            with = {
              aws-access-key-id     = "$${{ secrets.AWS_ACCESS_KEY_ID }}"
              aws-region            = "${var.region}"
              aws-secret-access-key = "$${{ secrets.AWS_ACCESS_KEY_SECRET }}"
            }
          },
          {
            id   = "login-ecr"
            name = "Login to Amazon ECR"
            uses = "aws-actions/amazon-ecr-login@v1"
          },
          {
            name = "Check out code"
            uses = "actions/checkout@v2"
          },
          {
            name = "Configure Java"
            uses = "actions/setup-java@v3"
            with = {
              distribution = "adopt"
              java-version = 17
            }
          },
          {
            name = "Build image"
            env = {
              IMAGE_NAME = "$${{ steps.login-ecr.outputs.registry }}/${aws_ecr_repository.aws_ecr_cobudget.name}"
            }
            run = "./mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=$IMAGE_NAME"
          },
          {
            name = "Push image to Amazon ECR"
            env = {
              ECR_REGISTRY   = "$${{ steps.login-ecr.outputs.registry }}"
              ECR_REPOSITORY = aws_ecr_repository.aws_ecr_cobudget.name
              IMAGE_TAG      = "latest"
            }
            run = "docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"
          },
        ]
      }
    }
  })
  commit_message = "Managed by Terraform"
}