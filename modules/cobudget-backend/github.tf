data "github_repository" "cobudget" {
  name = "CoBudget-backend"
}

resource "github_repository_file" "cobudget_workflow_ecr" {
  repository = data.github_repository.cobudget.name
  file       = ".github/workflows/build-image.yml"
  content = yamlencode({
    name = "Build and publish image"
    on = {
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
        env = {
          REGISTRY   = "registry.vm.stasiak.xyz"
          IMAGE_NAME = "cobudget"
        }
        name    = "Build Image"
        runs-on = "ubuntu-latest"
        permissions = {
          id-token = "write"
          contents = "read"
        }
        steps = [
          {
            name = "Login to private registry"
            uses = "docker/login-action@v2"
            with = {
              registry = "$${{ env.REGISTRY }}"
              username = "$${{ secrets.${github_actions_secret.registry_username.secret_name} }}"
              password = "$${{ secrets.${github_actions_secret.registry_password.secret_name} }}"
            }
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
            run  = "./mvnw spring-boot:build-image -Dspring-boot.build-image.imageName=$REGISTRY/$IMAGE_NAME"
          },
          {
            name = "Push image"
            run  = "docker push $REGISTRY/$IMAGE_NAME"
          },
        ]
      }
    }
  })
  commit_message = "Managed by Terraform"
}

resource "github_actions_secret" "registry_username" {
  repository      = data.github_repository.cobudget.name
  secret_name     = "REGISTRY_USERNAME"
  plaintext_value = var.registry_username
}

resource "github_actions_secret" "registry_password" {
  repository      = data.github_repository.cobudget.name
  secret_name     = "REGISTRY_PASSWORD"
  plaintext_value = var.registry_password
}
