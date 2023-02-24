data "github_repository" "cobudget" {
  name = "CoBudget-backend"
}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:dawids21/CoBudget-backend:*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr_cobudget_upload" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.ecr_cobudget.arn
}

resource "github_repository_file" "cobudget_workflow_ecr" {
  repository = data.github_repository.cobudget.name
  file       = ".github/workflows/ecr.yml"
  content    = yamlencode({
    name = "Deploy to ECR"
    on   = {
      push = {
        branches = ["main"]
      }
    }
    concurrency = {
      group              = "$${{ github.workflow }}-$${{ github.event.pull_request.number || github.ref }}"
      cancel-in-progress = true
    }
    jobs = {
      build = {
        name        = "Build Image"
        runs-on     = "ubuntu-latest"
        permissions = {
          id-token = "write"
          contents = "read"
        }
        steps = [
          {
            name = "Configure AWS credentials"
            uses = "aws-actions/configure-aws-credentials@v1"
            with = {
              role-to-assume = aws_iam_role.github_actions.arn
              aws-region     = var.region
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
              cache        = "maven"
            }
          },
          {
            name = "Build image"
            env  = {
              IMAGE_NAME = "$${{ steps.login-ecr.outputs.registry }}/${aws_ecr_repository.ecr_cobudget.name}"
            }
            run = "./mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=$IMAGE_NAME"
          },
          {
            name = "Push image to Amazon ECR"
            env  = {
              ECR_REGISTRY   = "$${{ steps.login-ecr.outputs.registry }}"
              ECR_REPOSITORY = aws_ecr_repository.ecr_cobudget.name
              IMAGE_TAG      = "latest"
            }
            run = "docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG"
          },
          {
            name = "Deploy new container on ECS"
            env  = {
              ECS_CLUSTER = aws_ecs_cluster.cobudget.name
              ECS_SERVICE = aws_ecs_service.cobudget.name
            }
            run = "aws ecs update-service --cluster $ECS_CLUSTER --service $ECS_SERVICE --force-new-deployment"
          },
        ]
      }
    }
  })
  commit_message = "Managed by Terraform"
}
